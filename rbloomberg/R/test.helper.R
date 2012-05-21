allBloombergTests <- function() {
	defineTestSuite("All Tests",
			dirs=system.file("runit-tests", package="Rbbg"),
			testFileRegexp="^test")
}

runAllBloombergTests <- function() {
	testResults <- runTestSuite(allBloombergTests())
		printTextProtocol(testResults)
}
