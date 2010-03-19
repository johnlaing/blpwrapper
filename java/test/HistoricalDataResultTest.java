import junit.framework.*;
import java.util.regex.*;
import org.findata.blpwrapper.*;

public class HistoricalDataResultTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testValidRequest() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"PX_LAST", "PX_BID"};
    String start_date = "20100101";
    String end_date = "20100201";

    HistoricalDataResult result = (HistoricalDataResult)conn.blh(security, fields, start_date, end_date);
    String[][] data = result.getData();
  }

  public void testValidRequestWithoutEndDate() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"PX_LAST", "PX_BID"};
    String start_date = "20100315";

    HistoricalDataResult result = (HistoricalDataResult)conn.blh(security, fields, start_date);
    String[][] data = result.getData();
  }

  public void testValidRequestWithOverrides() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"PX_LAST", "PX_BID"};
    String[] override_fields = {"EQY_FUND_CRNCY"};
    String[] override_values = {"JPY"};

    String[] option_names = {"startDate", "endDate"};
    String[] option_values = {"20100101", "20100201"};

    HistoricalDataResult result = (HistoricalDataResult)conn.blh(security, fields, override_fields, override_values, option_names, option_values);
    String[][] data = result.getData();
    System.out.println(data[0][0]);
  }

  public void testValidRequestWithOptions() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"PX_LAST", "PX_BID"};
  
    String[] override_fields = new String[0];
    String[] override_values = new String[0];

    String[] option_names = {"startDate", "endDate", "currency"};
    String[] option_values = {"20100101", "20100201", "JPY"};

    HistoricalDataResult result = (HistoricalDataResult)conn.blh(security, fields, override_fields, override_values, option_names, option_values);
    String[][] data = result.getData();
    System.out.println(data[0][0]);
  }

  public void testValidRequestWithOverridesWithoutEndDate() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"PX_LAST", "PX_BID"};
    String[] override_fields = {"EQY_FUND_CRNCY"};
    String[] override_values = {"JPY"};

    String[] option_names = {"startDate"};
    String[] option_values = {"20100315"};

    HistoricalDataResult result = (HistoricalDataResult)conn.blh(security, fields, override_fields, override_values, option_names, option_values);
    String[][] data = result.getData();
  }

  public void testRaisesErrorOnInvalidSecurity() throws Exception {
    String security = "XXJIOJFDIOSJ US Equity";
    String[] fields = {"PX_LAST"};
    String start_date = "20100101";
    String end_date = "20100201";

    try {
      conn.blh(security, fields, start_date, end_date);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("invalid security XXJIOJFDIOSJ US Equity", e.getMessage());
    }
  }

  public void testRaisesErrorOnInvalidField() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"JIODJOIADFSJFOI"};
    String start_date = "20100101";
    String end_date = "20100201";

    try {
      conn.blh(security, fields, start_date, end_date);
//      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("invalid field JIODJOIADFSJFOI", e.getMessage());
    }
  }

  public void testInvalidDates() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"NAME", "BID", "LOW_DT_52WEEK"};
    String start_date = "2010-01-01";
    String end_date = "2010-02-01";

    try {
      conn.blh(security, fields, start_date, end_date);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      boolean b = Pattern.matches("^response error: Invalid start date.*$", e.getMessage());
      assertTrue("unexpected message", b);
    }
  }

  public void testValidRequestWithInvalidOverrides() throws Exception {
    String security = "OCN US Equity";
    String[] fields = {"NAME", "BID", "LOW_DT_52WEEK"};
    String[] override_fields = {"PRICING SOURCE"};
    String[] override_values = {"CG"};
    String[] option_names = {"startDate", "endDate"};
    String[] option_values = {"20100101", "20100201"};

    try {
      HistoricalDataResult result = (HistoricalDataResult)conn.blh(security, fields, override_fields, override_values, option_names, option_values);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      boolean b = Pattern.matches("^response error: Invalid override field id specified.*$", e.getMessage());
      assertTrue("unexpected message", b);
    }
  }
}

