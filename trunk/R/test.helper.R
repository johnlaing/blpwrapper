allBloombergTests <- defineTestSuite("All Tests", dirs=system.file("runit-tests", package="RBloomberg"), testFileRegexp="Test.R$")

# To run all unit tests:
# 
# testResults <- runTestSuite(allBloombergTests)
# printTextProtocol(testResults)
