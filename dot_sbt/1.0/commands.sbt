val updateAllClassifiersCommand: String =
  """; updateClassifiers
    |; updateSbtClassifiers
    |; reload plugins
    |; updateClassifiers
    |; updateSbtClassifiers
    |; reload return""".stripMargin

addCommandAlias("updateAllClassifiers", updateAllClassifiersCommand)
addCommandAlias("dlSrc", updateAllClassifiersCommand)
