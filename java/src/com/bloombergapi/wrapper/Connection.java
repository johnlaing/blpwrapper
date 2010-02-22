package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;

import java.util.ArrayList;

public class Connection {
  private SessionOptions session_options;
  private Session session;

  public ArrayList response_cache;

  // Session options defaults.
  private String server_host = "localhost";
  private int server_port = 8194;

  private String refdata_service_name = "//blp/refdata";
  private String refdata_request_name = "ReferenceDataRequest";
  private boolean refdata_service_open = false;

  public Connection() {
    response_cache = new ArrayList();
  }

  public void connect() throws Exception {
    setupSessionOptions();
    setupSession();
    processEventLoop();
  }

  public void close() throws Exception {
    session.stop();
  }

  private void setupSessionOptions() {
    session_options = new SessionOptions();
    session_options.setServerHost(server_host);
    session_options.setServerPort(server_port);
  }

  private void setupSession() throws Exception {
    session = new Session(session_options);
    session.start();
  }

  public CorrelationID nextCorrelationID(String[] securities, String[] fields) throws Exception {
    ReferenceDataResult result = new ReferenceDataResult(securities, fields);
    if (response_cache.add(result)) {
      return(new CorrelationID(response_cache.size()-1));
    } else {
      throw new Exception("unable to add to response_cache");
    }
  }

  private Service getRefDataService() throws Exception {
    if (!refdata_service_open) {
      refdata_service_open = session.openService(refdata_service_name);
    }
    return(session.getService(refdata_service_name));
  }

  private CorrelationID sendRefDataRequest(String[] securities, String[] fields) throws Exception {
    Service service = getRefDataService();
    Request request = service.createRequest(refdata_request_name);

    Element securities_element = request.getElement("securities");
    for (int i = 0; i < securities.length; i++) {
      securities_element.appendValue(securities[i]);
    }

    Element fields_element = request.getElement("fields");
    for (int i = 0; i < fields.length; i++) {
      fields_element.appendValue(fields[i]);
    }

    CorrelationID correlation_id = nextCorrelationID(securities, fields);
    session.sendRequest(request, correlation_id);
    return(correlation_id);
  }
  
  private void processEventLoop() throws Exception {
    processEventLoop(false);
  }

  private void processEventLoop(boolean await_response) throws Exception {
    boolean cont = true;
    while (cont) {
      Event event = session.nextEvent();

      switch (event.eventType().intValue()) {
        case Event.EventType.Constants.SESSION_STATUS:       processStatusEvent(event); cont=await_response; break;
        case Event.EventType.Constants.SERVICE_STATUS:       processStatusEvent(event); cont=await_response; break;
        case Event.EventType.Constants.RESPONSE:             processResponseEvent(event); cont=false; break;
        case Event.EventType.Constants.PARTIAL_RESPONSE:     processResponseEvent(event); break;
        default: throw new Exception("don't recognize event type" + event.eventType().toString());
      }
    }
  }

  private void processStatusEvent(Event event) {
  }

  private void processResponseEvent(Event event) {
    MessageIterator msgIter = event.messageIterator();

    while (msgIter.hasNext()) {
      Message message = msgIter.next();
      int response_id = (int)message.correlationID().value();

      ReferenceDataResult result = (ReferenceDataResult)response_cache.get(response_id);
      result.processResponse(message.asElement());
    }
  }

  public Object blp(String[] securities, String[] fields) throws Exception {
    int response_id = (int)sendRefDataRequest(securities, fields).value();
    processEventLoop(true); // await_response = true to ensure we wait for full response.
    return(response_cache.get(response_id));
  }
}

