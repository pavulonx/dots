val updateAllClassifiersCommand: String =
  """; updateClassifiers
    |; updateSbtClassifiers
    |; reload plugins
    |; updateClassifiers
    |; updateSbtClassifiers
    |; reload return""".stripMargin

addCommandAlias("updateAllClassifiers", updateAllClassifiersCommand)
addCommandAlias("dlSrc", updateAllClassifiersCommand)


val dependencyUpdatesAllCommand: String =
  """; reload
    |; dependencyUpdates
    |; reload plugins
    |; dependencyUpdates
    |; reload return""".stripMargin

addCommandAlias("dependencyUpdatesAll", dependencyUpdatesAllCommand)
addCommandAlias("lsUpdates", dependencyUpdatesAllCommand)


lazy val sh = inputKey[Unit]("Run shell command")

import sys.process._
import complete.DefaultParsers._
sh := {
  val args: Seq[String] = spaceDelimited("<arg>").parsed
  val cmd = args.mkString(" ")
  cmd.!
}
