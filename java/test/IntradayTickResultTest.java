import junit.framework.*;
import org.findata.blpwrapper.*;

public class IntradayTickResultTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testTickData() throws Exception {
    String security = "C US Equity";
    String[] fields = {"TRADE", "BID_BEST"};

    IntradayTickDataResult result = (IntradayTickDataResult)conn.tick(security, fields, "2010-09-21 15:00:00.000", "2010-09-21 15:00:01.000");
    System.out.println(result.getData()[0][0]);
  }

  public void testTickDataWithEid() throws Exception {
    String security = "C US Equity";
    String[] fields = {"TRADE", "BID_BEST"};

    String[] option_fields = {"returnEids"};
    String[] option_values = {"true"};

    IntradayTickDataResult result = (IntradayTickDataResult)conn.tick(security, fields, "2010-09-21 15:00:00.000", "2010-09-21 15:00:01.000", option_fields, option_values);
    System.out.println(result.getData()[0][0]);
  }
}

