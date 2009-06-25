library(RBloomberg)
allBloombergTests <- defineTestSuite("All Tests", dirs=system.file("runit-tests", package="RBloomberg"), testFileRegexp="Test.R$")
testResults <- runTestSuite(allBloombergTests)
printTextProtocol(testResults)
