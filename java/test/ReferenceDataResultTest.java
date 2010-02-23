import junit.framework.*;
import com.bloombergapi.wrapper.*;

public class ReferenceDataResultTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
    conn.connect();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testThrowsErrorForBulkDataRequest() throws Exception {
    String[] securities = {"BKIR ID Equity"};
    String[] fields = {"DVD_HIST"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (BloombergAPIWrapperException e) {
      assertEquals("reference data request cannot handle SEQUENCE data in field DVD_HIST", e.getMessage());
    }
  }

  public void testRaisesErrorOnInvalidSecurity() throws Exception {
    String[] securities = {"XXJIOJFDIOSJ US Equity"};
    String[] fields = {"NAME"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (BloombergAPIWrapperException e) {
      assertEquals("invalid security XXJIOJFDIOSJ US Equity", e.getMessage());
    }
  }

  public void testRaisesErrorOnInvalidField() throws Exception {
    String[] securities = {"BKIR ID Equity"};
    String[] fields = {"JIODJOIADFSJFOI"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (BloombergAPIWrapperException e) {
      assertEquals("invalid field JIODJOIADFSJFOI", e.getMessage());
    }
  }

  public void testRaisesErrorOnMultipleInvalidFields() throws Exception {
    String[] securities = {"BKIR ID Equity"};
    String[] fields = {"XXX1", "XXX2"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (BloombergAPIWrapperException e) {
      assertEquals("invalid fields XXX1, XXX2", e.getMessage());
    }
  }

  public void testValidRequest() throws Exception {
    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "BID", "LOW_DT_52WEEK"};

    ReferenceDataResult result = (ReferenceDataResult)conn.blp(securities, fields);
  }

  public void testValidRequestWithOverrides() throws Exception {
    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"CRNCY_ADJ_MKT_CAP", "CUR_MKT_CAP"};
    String[] override_fields = {"EQY_FUND_CRNCY"};
    String[] overrides = {"JPY"};

    ReferenceDataResult result = (ReferenceDataResult)conn.blp(securities, fields, override_fields, overrides);
    String[][] data = result.getData();
    
    System.out.println(data[0][0]);
    System.out.println(data[0][1]);
    System.out.println(data[1][0]);
    System.out.println(data[1][1]);
  }

  public void testValidRequestWithInvalidOverrides() throws Exception {
    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "BID", "LOW_DT_52WEEK"};
    String[] override_fields = {"PRICING SOURCE"};
    String[] overrides = {"CG"};

    try {
      conn.blp(securities, fields, override_fields, overrides);
      fail("Should have raised an error");
    } catch (BloombergAPIWrapperException e) {
      assertEquals("response error: Invalid override field: PRICING SOURCE [nid:200] ", e.getMessage());
    }
  }
}

