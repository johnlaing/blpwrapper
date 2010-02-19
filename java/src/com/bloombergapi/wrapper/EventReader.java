package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;
import java.util.ArrayList;

public class EventReader implements EventHandler {
  private ArrayList response_cache;

  public EventReader() {
    response_cache = new ArrayList();
  }

  public CorrelationID nextCorrelationID() {
    return(new CorrelationID(response_cache.size()));
  }

  public void processEvent(Event event, Session session) {
    System.out.println("i am in ur loop, processing ur event");
    System.out.println(event.eventType().toString());
    MessageIterator msgIter = event.messageIterator();

    while (msgIter.hasNext()) {
      Message msg = msgIter.next();
      System.out.println(msg.asElement());
    }

    System.out.println("Array list has " + response_cache.size() + "elements");
  }
}
