require 'java'

$CLASSPATH << 'C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar'
$CLASSPATH << "blpwrapper.jar"

include_class "org.findata.blpwrapper.Connection"

conn = Connection.new
securities = ["RYA ID Equity"].to_java(:string)
fields = ["NAME"].to_java(:string)
result = conn.blp(securities, fields)

puts result.getData[0][0]

