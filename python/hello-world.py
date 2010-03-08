import sys

sys.path.append('C:\\blp\API\APIv3\JavaAPI\lib\\blpapi3.jar')
sys.path.append("..\java\\blpwrapper.jar")

from org.findata.blpwrapper import Connection

conn = Connection()
result = conn.blp(["RYA ID Equity"], ["NAME"])

print(result.getData()[0][0])

