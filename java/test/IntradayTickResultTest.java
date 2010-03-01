import junit.framework.*;
import org.findata.blpwrapper.*;

public class IntradayTickResultTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
    conn.connect();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testTickData() throws Exception {
    String security = "C US Equity";
    String[] fields = {"TRADE", "BID_BEST"};

    DataResult result = conn.tick(security, fields, "2010-03-01 15:00:00.000", "2010-03-01 15:00:01.000");
    System.out.println(result.getData()[0][0]);
  }

  public void testTickDataWithEid() throws Exception {
    String security = "C US Equity";
    String[] fields = {"TRADE", "BID_BEST"};

    String[] override_fields = new String[0];
    String[] override_values = new String[0];

    String[] option_fields = {"returnEids"};
    String[] option_values = {"true"};

    DataResult result = conn.tick(security, fields, "2010-03-01 15:00:00.000", "2010-03-01 15:00:01.000", override_fields, override_values, option_fields, option_values);
    System.out.println(result.getData()[0][0]);
  }
}

