organization := "com.typesafe.sbt"
name := "sbt-coffeescript"

libraryDependencies ++= Seq(
  //"org.webjars" % "coffee-script-node" % "1.11.0",
  "org.webjars.npm" % "coffee-script" % "1.12.7",
  "org.webjars" % "mkdirp" % "0.5.0"
)

//addSbtJsEngine("1.3.2-SNAPSHOT")

publishMavenStyle := true

addSbtPlugin("com.typesafe.sbt" % "sbt-js-engine" % "1.3.2-SNAPSHOT")
