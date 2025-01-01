addDependencyTreePlugin
addSbtPlugin("com.timushev.sbt" % "sbt-rewarn" % "0.1.3")
//addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.6.3")
//addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.6.5-16-0310b0c-dirty-SNAPSHOT")
addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.6.5-25-7eb013d-SNAPSHOT")
ThisBuild / libraryDependencySchemes ++= Seq(
  "org.scala-lang.modules" %% "scala-xml" % VersionScheme.Always
)
