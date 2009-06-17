# To run all unit tests:
# runTestSuite(allBloombergTests)
allBloombergTests <- defineTestSuite("All Tests", dirs=system.file("runit-tests", package="RBloomberg"), testFileRegexp="Test.R$")
