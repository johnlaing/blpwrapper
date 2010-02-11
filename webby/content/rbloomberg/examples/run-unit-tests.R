library(RBloomberg)
### @export "run"
testResults <- runTestSuite(allBloombergTests())
printTextProtocol(testResults)
### @end
printTextProtocol(testResults, fileName="unit-test-results.txt")
