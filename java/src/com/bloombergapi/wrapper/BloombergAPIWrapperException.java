package com.bloombergapi.wrapper;
import com.bloomberglp.blpapi.*;

public class BloombergAPIWrapperException extends Exception {
  private String message;

  public BloombergAPIWrapperException(String custom_message) {
    message = custom_message;
  }

  public BloombergAPIWrapperException(Event.EventType event_type) {
    message = "Don't know how to handle event type " + event_type.toString();
  }

  public String getMessage() {
    return(message);
  }
}
