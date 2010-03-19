import junit.framework.*;
import java.util.regex.*;
import org.findata.blpwrapper.*;

import java.util.logging.Level;

public class ConnectionTest extends TestCase {
  private Connection conn;

  public void testConnectionWithoutParams() throws Exception {
    conn = new Connection();
    conn.close();
  }

  public void testCustomLogLevel() throws Exception {
    conn = new Connection(Level.WARNING);
    conn.close();
  }

  public void testCustomServerSettings() throws Exception {
    try {
      conn = new Connection(Level.WARNING, "localhost", 8195);
    } catch (WrapperException e) {
      assertEquals("Session not started because: Failed to connect server: localhost/127.0.0.1:8195", e.getMessage());
    }
  }
}

