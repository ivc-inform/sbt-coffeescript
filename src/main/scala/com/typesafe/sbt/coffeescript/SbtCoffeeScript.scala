package com.typesafe.sbt.coffeescript

import java.nio.charset.StandardCharsets

import com.typesafe.sbt.jse.SbtJsTask
import sbt.Keys._
import sbt._
import spray.json.{JsBoolean, JsObject}

object Import {

    object CoffeeScriptKeys {
        val coffeeScript = TaskKey[Seq[File]]("coffeescript", "Invoke the CoffeeScript compiler.")
        val makeIndexFile = TaskKey[Seq[File]]("makeIndexFile", "")

        val bare = SettingKey[Boolean]("coffeescript-bare", "Compiles JavaScript that isn't wrapped in a function.")
        val sourceMap = SettingKey[Boolean]("coffeescript-source-map", "Outputs a v3 sourcemap.")
        val writeIncludeModules = SettingKey[Boolean]("Записывать ли файл-список генеренных JS-ков из CoffeeScript ов", "")
        val indexFileName = settingKey[String]("JavaScript index file name")
    }

    implicit class fltrOpts(val strings: List[String]) {
        def withOutComment = strings.filter(_.substring(0, 2) != "##")
    }

}

object SbtCoffeeScript extends AutoPlugin {

    override def requires = SbtJsTask

    override def trigger = AllRequirements

    val autoImport = Import

    import SbtJsTask.autoImport.JsTaskKeys._
    import com.typesafe.sbt.web.SbtWeb.autoImport._
    import WebKeys._
    import autoImport.CoffeeScriptKeys._

    val coffeeScriptUnscopedSettings = Seq(

        includeFilter := "*.coffee" | "*.litcoffee",

        jsOptions := JsObject(
            "bare" -> JsBoolean(bare.value),
            "sourceMap" -> JsBoolean(sourceMap.value)
        ).toString()
    )

    override def buildSettings = inTask(coffeeScript)(
        SbtJsTask.jsTaskSpecificUnscopedBuildSettings ++ Seq(
            moduleName := "coffeescript",
            shellFile := getClass.getClassLoader.getResource("coffee.js")

        )
    )

    override def projectSettings = Seq(
        bare := false,
        sourceMap := true

    ) ++ inTask(coffeeScript)(
        SbtJsTask.jsTaskSpecificUnscopedProjectSettings ++
          inConfig(Assets)(coffeeScriptUnscopedSettings) ++
          inConfig(TestAssets)(coffeeScriptUnscopedSettings) ++
          Seq(
              taskMessage in Assets := "CoffeeScript compiling",
              taskMessage in TestAssets := "CoffeeScript test compiling"
          )
    ) ++ SbtJsTask.addJsSourceFileTasks(coffeeScript) ++ Seq(
        coffeeScript in Assets := (coffeeScript in Assets).dependsOn(webModules in Assets).value,
        coffeeScript in TestAssets := (coffeeScript in TestAssets).dependsOn(webModules in TestAssets).value
    )

    def genIndexFile(writeIncludeModules: Boolean, sourseDir: File, distinationDir: File)(implicit logger: Logger): Seq[File] = {
        val index = scala.collection.mutable.ListBuffer.empty[String]

        import Import._
        if (writeIncludeModules) {
            if (sourseDir.exists()) {
                index ++= IO.readLines(sourseDir, StandardCharsets.UTF_8).withOutComment.map(x => x.replace(".coffee", ".js"))
            } else
                logger.error(s"transpile plugin: IncludeModules is not exists at ${sourseDir.getAbsolutePath}")

            IO.writeLines(distinationDir, index, StandardCharsets.UTF_8, false)
            logger debug "Index File for coffeeScript meked."
        }

        Seq()
    }
}
