allBloombergTests <- defineTestSuite("All Tests", dirs=system.file("runit-tests", package="RBloomberg"), testFileRegexp="Test.R$")

# To run all unit tests:

# library(RBloomberg)
# testResults <- runTestSuite(allBloombergTests)
# printTextProtocol(testResults)
