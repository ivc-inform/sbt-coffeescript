organization := "com.typesafe.sbt"
name := "sbt-coffeescript"

libraryDependencies ++= Seq(
  "org.webjars.npm" % "coffee-script" % "1.12.7",
  "org.webjars" % "mkdirp" % "0.5.0"
)

publishMavenStyle := true

addSbtPlugin("com.typesafe.sbt" % "sbt-js-engine" % "1.3.2-SNAPSHOT")
