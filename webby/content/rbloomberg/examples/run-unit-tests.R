library(RBloomberg)
### @export "run"
testResults <- runTestSuite(allBloombergTests())
printTextProtocol(testResults)
### @end
printTextProtocol(testResults, fileName="C:\\work\\rbloomberg-examples\\unit-test-results.txt")
