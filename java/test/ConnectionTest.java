import junit.framework.*;
import com.bloombergapi.wrapper.*;

public class ConnectionTest extends TestCase {
  public void testConnection() throws Exception {
    Connection connection = new Connection();
    connection.connect();

    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME"};
    connection.sendRefDataRequest(securities, fields);
  }
}

