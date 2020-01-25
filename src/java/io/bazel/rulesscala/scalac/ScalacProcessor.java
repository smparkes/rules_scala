package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.jar.JarCreator;
import io.bazel.rulesscala.worker.GenericWorker;
import io.bazel.rulesscala.worker.Processor;
import java.io.*;
import java.lang.reflect.Field;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.*;
import java.util.Map.Entry;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import org.apache.commons.io.IOUtils;
import scala.tools.nsc.Driver;
import scala.tools.nsc.MainClass;
import scala.tools.nsc.reporters.ConsoleReporter;

class ScalacProcessor implements Processor {
  private static boolean isWindows = System.getProperty("os.name").toLowerCase().contains("windows");

  /** This is the reporter field for scalac, which we want to access */
  private static Field reporterField;

  static {
    try {
      reporterField = Driver.class.getDeclaredField("reporter"); // NoSuchFieldException
      reporterField.setAccessible(true);
    } catch (NoSuchFieldException ex) {
      throw new RuntimeException("could not access reporter field on Driver", ex);
    }
  }

  @Override
  public void processRequest(List<String> args) throws Exception {
    Path tmpPath = null;
    try {
      CompileOptions ops = new CompileOptions(args);

      Path outputPath = FileSystems.getDefault().getPath(ops.outputName);
      tmpPath = Files.createTempDirectory(outputPath.getParent(), "tmp");

      List<File> jarFiles = extractSourceJars(ops, outputPath.getParent());
      List<File> scalaJarFiles = filterFilesByExtension(jarFiles, ".scala");
      List<File> javaJarFiles = filterFilesByExtension(jarFiles, ".java");

      if (!ops.expectJavaOutput && !javaJarFiles.isEmpty()) {
        throw new RuntimeException(
            "Found java files in source jars but expect Java output is set to false");
      }

      String[] scalaSources = collectSrcJarSources(ops.files, scalaJarFiles, javaJarFiles);

      String[] javaSources = GenericWorker.appendToString(ops.javaFiles, javaJarFiles);
      if (scalaSources.length == 0 && javaSources.length == 0) {
        throw new RuntimeException("Must have input files from either source jars or local files.");
      }

      /**
       * Compile scala sources if available (if there are none, we will simply compile java
       * sources).
       */
      if (scalaSources.length > 0) {
        compileScalaSources(ops, scalaSources, tmpPath);
      }

      /** Copy the resources */
      copyResources(ops.resourceFiles, tmpPath);

      /** Extract and copy resources from resource jars */
      copyResourceJars(ops.resourceJars, tmpPath);

      /** Copy classpath resources to root of jar */
      copyClasspathResourcesToRoot(ops.classpathResourceFiles, tmpPath);

      /** Now build the output jar */
      String[] jarCreatorArgs = {"-m", ops.manifestPath, outputPath.toString(), tmpPath.toString()};
      JarCreator.main(jarCreatorArgs);
    } finally {
      removeTmp(tmpPath);
    }
  }

  private static String[] collectSrcJarSources(
      String[] files, List<File> scalaJarFiles, List<File> javaJarFiles) {
    String[] scalaSources = GenericWorker.appendToString(files, scalaJarFiles);
    return GenericWorker.appendToString(scalaSources, javaJarFiles);
  }

  private static List<File> filterFilesByExtension(List<File> files, String extension) {
    List<File> filtered = new ArrayList<File>();
    for (File f : files) {
      if (f.toString().endsWith(extension)) {
        filtered.add(f);
      }
    }
    return filtered;
  }

  private static String[] sourceExtensions = {".scala", ".java"};

  private static List<File> extractSourceJars(CompileOptions opts, Path tmpParent)
      throws IOException {
    List<File> sourceFiles = new ArrayList<File>();

    for (String jarPath : opts.sourceJars) {
      if (jarPath.length() > 0) {
        Path tmpPath = Files.createTempDirectory(tmpParent, "tmp");
        sourceFiles.addAll(extractJar(jarPath, tmpPath.toString(), sourceExtensions));
      }
    }

    return sourceFiles;
  }

  private static List<File> extractJar(String jarPath, String outputFolder, String[] extensions)
      throws IOException, FileNotFoundException {

    List<File> outputPaths = new ArrayList<File>();
    JarFile jar = new JarFile(jarPath);
    Enumeration<JarEntry> e = jar.entries();
    while (e.hasMoreElements()) {
      JarEntry file = e.nextElement();
      String thisFileName = file.getName();
      // we don't bother to extract non-scala/java sources (skip manifest)
      if (extensions != null && !matchesFileExtensions(thisFileName, extensions)) continue;
      File f = new File(outputFolder + File.separator + file.getName());

      if (file.isDirectory()) { // if its a directory, create it
        f.mkdirs();
        continue;
      }

      File parent = f.getParentFile();
      parent.mkdirs();
      outputPaths.add(f);

      InputStream is = jar.getInputStream(file); // get the input stream
      OutputStream fos = new FileOutputStream(f);
      IOUtils.copy(is, fos);
      fos.close();
      is.close();
    }
    return outputPaths;
  }

  private static boolean matchesFileExtensions(String fileName, String[] extensions) {
    for (String e : extensions) {
      if (fileName.endsWith(e)) {
        return true;
      }
    }
    return false;
  }

  private static String[] encodeBazelTargets(String[] targets) {
    return Arrays.stream(targets).map(ScalacProcessor::encodeBazelTarget).toArray(String[]::new);
  }

  private static String encodeBazelTarget(String target) {
    return target.replace(":", ";");
  }

  private static boolean isModeEnabled(String mode) {
    return !"off".equals(mode);
  }

  private static String[] getPluginParamsFrom(CompileOptions ops) {
    ArrayList<String> pluginParams = new ArrayList<>(0);

    if (isModeEnabled(ops.dependencyAnalyzerMode)) {
      String[] indirectTargets = encodeBazelTargets(ops.indirectTargets);
      String currentTarget = encodeBazelTarget(ops.currentTarget);

      String[] dependencyAnalyzerParams = {
        "-P:dependency-analyzer:direct-jars:" + String.join(":", ops.directJars),
        "-P:dependency-analyzer:indirect-jars:" + String.join(":", ops.indirectJars),
        "-P:dependency-analyzer:indirect-targets:" + String.join(":", indirectTargets),
        "-P:dependency-analyzer:mode:" + ops.dependencyAnalyzerMode,
        "-P:dependency-analyzer:current-target:" + currentTarget,
      };
      pluginParams.addAll(Arrays.asList(dependencyAnalyzerParams));
    } else if (isModeEnabled(ops.unusedDependencyCheckerMode)) {
      String[] directTargets = encodeBazelTargets(ops.directTargets);
      String[] ignoredTargets = encodeBazelTargets(ops.ignoredTargets);
      String currentTarget = encodeBazelTarget(ops.currentTarget);

      String[] unusedDependencyCheckerParams = {
        "-P:unused-dependency-checker:direct-jars:" + String.join(":", ops.directJars),
        "-P:unused-dependency-checker:direct-targets:" + String.join(":", directTargets),
        "-P:unused-dependency-checker:ignored-targets:" + String.join(":", ignoredTargets),
        "-P:unused-dependency-checker:mode:" + ops.unusedDependencyCheckerMode,
        "-P:unused-dependency-checker:current-target:" + currentTarget,
      };
      pluginParams.addAll(Arrays.asList(unusedDependencyCheckerParams));
    }

    return pluginParams.toArray(new String[pluginParams.size()]);
  }

  private static void compileScalaSources(CompileOptions ops, String[] scalaSources, Path tmpPath)
      throws IllegalAccessException {

    String[] pluginParams = getPluginParamsFrom(ops);

    String[] constParams = {"-classpath", ops.classpath, "-d", tmpPath.toString()};

    String[] compilerArgs =
        GenericWorker.merge(ops.scalaOpts, ops.pluginArgs, constParams, pluginParams, scalaSources);

    MainClass comp = new MainClass();
    long start = System.currentTimeMillis();
    try {
      comp.process(compilerArgs);
    } catch (Throwable ex) {
      if (ex.toString().contains("scala.reflect.internal.Types$TypeError")) {
        throw new RuntimeException("Build failure with type error", ex);
      } else {
        throw ex;
      }
    }
    long stop = System.currentTimeMillis();
    if (ops.printCompileTime) {
      System.err.println("Compiler runtime: " + (stop - start) + "ms.");
    }

    try {
      Files.write(
          Paths.get(ops.statsfile), Arrays.asList("build_time=" + Long.toString(stop - start)));
    } catch (IOException ex) {
      throw new RuntimeException("Unable to write statsfile to " + ops.statsfile, ex);
    }

    ConsoleReporter reporter = (ConsoleReporter) reporterField.get(comp);

    if (reporter.hasErrors()) {
      reporter.printSummary();
      reporter.flush();
      throw new RuntimeException("Build failed");
    }
  }

  private static void removeTmp(Path tmp) throws IOException {
    if (tmp != null) {
      Files.walkFileTree(
          tmp,
          new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
                throws IOException {
              if (isWindows) file.toFile().setWritable(true);
              Files.delete(file);
              return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult postVisitDirectory(Path dir, IOException exc)
                throws IOException {
              Files.delete(dir);
              return FileVisitResult.CONTINUE;
            }
          });
    }
  }

  private static void copyResources(List<Resource> resources, Path dest) throws IOException {
    for (Resource r : resources) {
      Path source = Paths.get(r.source);
      Path target = dest.resolve(r.target);
      target.getParent().toFile().mkdirs();
      Files.copy(source, target);
    }
  }

  private static void copyClasspathResourcesToRoot(String[] classpathResourceFiles, Path dest)
      throws IOException {
    for (String s : classpathResourceFiles) {
      Path source = Paths.get(s);
      Path target = dest.resolve(source.getFileName());

      if (Files.exists(target)) {
        System.err.println(
            "Classpath resource file "
                + source.getFileName()
                + " has a namespace conflict with another file: "
                + target.getFileName());
      } else {
        Files.copy(source, target);
      }
    }
  }

  private static void copyResourceJars(String[] resourceJars, Path dest) throws IOException {
    for (String jarPath : resourceJars) {
      extractJar(jarPath, dest.toString(), null);
    }
  }
}
