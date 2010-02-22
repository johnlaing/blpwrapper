import junit.framework.*;
import com.bloombergapi.wrapper.*;

public class ConnectionTest extends TestCase {
  public void testConnection() throws Exception {
    Connection connection = new Connection();
    connection.connect();

    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "BID"};
    
    connection.blp(securities, fields);

    String[] fields2 =  {"NAME", "COUNTRY_ISO", "PX_LAST"};
    ReferenceDataResult result = (ReferenceDataResult)connection.blp(securities, fields2);
    
    System.out.println(result.tsv());
  }
}

