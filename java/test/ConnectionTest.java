import junit.framework.*;
import com.bloombergapi.wrapper.*;

public class ConnectionTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
    conn.connect();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testValidBulkDataRequest() throws Exception {
    String security = "BKIR ID Equity";
    String field = "DVD_HIST";

    conn.bls(security, field);
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
}

