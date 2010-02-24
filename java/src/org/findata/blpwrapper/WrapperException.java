package org.findata.blpwrapper;
import com.bloomberglp.blpapi.*;

public class WrapperException extends Exception {
  private String message;

  public WrapperException(String custom_message) {
    message = custom_message;
  }

  public WrapperException(Event.EventType event_type) {
    message = "Don't know how to handle event type " + event_type.toString();
  }

  public String getMessage() {
    return(message);
  }
}
