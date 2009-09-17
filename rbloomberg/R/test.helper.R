allBloombergTests <- defineTestSuite("All Tests", 
   dirs=system.file("runit-tests", package="RBloomberg"), 
   testFileRegexp="^test_")

runAllBloombergTests <- function() {
   testResults <- runTestSuite(allBloombergTests)
   printTextProtocol(testResults)
}
