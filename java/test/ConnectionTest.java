import junit.framework.*;
import com.bloombergapi.wrapper.*;

public class ConnectionTest extends TestCase {
  public void testConnection() throws Exception {
    Connection connection = new Connection();
    connection.connect();

    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "BID"};
    
    connection.blp(securities, fields);

    String[] fields2 =  {"PX_LAST"};
    ReferenceDataResult result = (ReferenceDataResult)connection.blp(securities, fields2);
    System.out.println("*************************");
    System.out.println(result.csv());

//    System.out.println(connection.response_cache);

//    System.out.println(connection.response_cache.get(0).csv());
  }
}

