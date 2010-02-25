import junit.framework.*;
import org.findata.blpwrapper.*;

public class FieldInfoResultTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
    conn.connect();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testValidBulkDataRequest() throws Exception {
    String[] fields = {"NAME", "DVD_HIST", "PX_LAST", "TIME"};
    conn.fieldInfo(fields);
  }
}

