require 'java'

$CLASSPATH << 'C:\\blp\\API\\APIv3\\JavaAPI\\v3.3.1.0\\lib\\blpapi3.jar'
$CLASSPATH << "blpwrapper.jar"

include_class "org.findata.blpwrapper.Connection"

conn = Connection.new

securities = ["GOOG US Equity", "OCN US Equity"].to_java(:string)
fields = ["NAME", "PX_LAST", "TIME"].to_java(:string)

result = conn.blp(securities, fields)
puts result.getData.to_a.inspect

