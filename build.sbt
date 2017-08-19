organization := "com.typesafe.sbt"
name := "sbt-coffeescript"

libraryDependencies ++= Seq(
  //"org.webjars" % "coffee-script-node" % "1.11.0",
  "org.webjars.npm" % "coffee-script" % "1.12.7",
  "org.webjars" % "mkdirp" % "0.5.0"
)
addSbtJsEngine("1.2.1")
