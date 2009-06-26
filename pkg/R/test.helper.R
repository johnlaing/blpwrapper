allBloombergTests <- defineTestSuite("All Tests", dirs=system.file("runit-tests", package="RBloomberg"), testFileRegexp="Test.R$")

runAllBloombergTests <- function() {
   testResults <- runTestSuite(allBloombergTests)
   printTextProtocol(testResults)
}
