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

  public void testValidBulkDataRequest() throws Exception {
    String security = "BKIR ID Equity";
    String field = "DVD_HIST";

    conn.bls(security, field);
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

