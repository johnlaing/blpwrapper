library(RBloomberg)

testResults <- runTestSuite(allBloombergTests())
sink("tests.html")
printHTMLProtocol(testResults)
sink()
