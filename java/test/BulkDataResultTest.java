import junit.framework.*;
import org.findata.blpwrapper.*;

public class BulkDataResultTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
    conn.connect();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testFutDeliverableBonds() throws Exception {
    String security = "TYA Comdty";
    String field = "FUT_DELIVERABLE_BONDS";

    conn.bls(security, field);
  }

  public void testEmptyResult() throws Exception {
    String security = "UKX Index";
    String field = "INDX_MEMBERS";

    conn.bls(security, field);

    field = "INDX_MEMBERS2";
    DataResult result = conn.bls(security, field);
  }

  public void testValidBulkDataRequest() throws Exception {
    String security = "BKIR ID Equity";
    String field = "DVD_HIST";

    DataResult result = conn.bls(security, field);
    System.out.println(result.getData()[0][0]);
  }

  public void testRaisesErrorOnInvalidSecurity() throws Exception {
    String security = "XXJIOJFDIOSJ US Equity";
    String field = "DVD_HIST";

    try {
      conn.bls(security, field);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("invalid security XXJIOJFDIOSJ US Equity", e.getMessage());
    }
  }

  public void testRaisesErrorOnInvalidField() throws Exception {
    String security = "BKIR ID Equity";
    String field = "JIODJOIADFSJFOI";

    try {
      conn.bls(security, field);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("invalid field JIODJOIADFSJFOI", e.getMessage());
    }
  }
}

