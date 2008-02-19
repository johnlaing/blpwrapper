# To run all unit tests:
# runTestSuite(allBloombergTests)
allBloombergTests <- defineTestSuite("All Tests", system.file("runit-tests", package="RBloomberg"), testFileRegexp="Test.R$")