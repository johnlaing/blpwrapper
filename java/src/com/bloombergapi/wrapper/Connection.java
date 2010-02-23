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

  public static final int REFERENCE_DATA_RESULT = 1;
  public static final int BULK_DATA_RESULT = 2;

  public Connection() {
    response_cache = new ArrayList();
  }

  public void connect() throws java.io.IOException, java.lang.InterruptedException, BloombergAPIWrapperException {
    setupSessionOptions();
    setupSession();
    processEventLoop();
  }

  public void close() throws java.io.IOException, java.lang.InterruptedException {
    session.stop();
  }

  private void setupSessionOptions() {
    session_options = new SessionOptions();
    session_options.setServerHost(server_host);
    session_options.setServerPort(server_port);
  }

  private void setupSession() throws java.io.IOException, java.lang.InterruptedException {
    session = new Session(session_options);
    session.start();
  }

  public CorrelationID nextCorrelationID(int result_type, String[] securities, String[] fields) throws Exception {
    DataResult result;
    switch(result_type) {
        case REFERENCE_DATA_RESULT:   result = new ReferenceDataResult(securities, fields); break;
        case BULK_DATA_RESULT:        result = new BulkDataResult(securities, fields); break;
        default: throw new BloombergAPIWrapperException("unknown result_type " + result_type);
      }
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

  private CorrelationID sendRefDataRequest(int result_type, String[] securities, String[] fields) throws Exception {
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

    CorrelationID correlation_id = nextCorrelationID(result_type, securities, fields);
    session.sendRequest(request, correlation_id);
    return(correlation_id);
  }
  
  private void processEventLoop() throws java.lang.InterruptedException, BloombergAPIWrapperException {
    processEventLoop(0);
  }

  private void processEventLoop(int result_type) throws java.lang.InterruptedException, BloombergAPIWrapperException {
    boolean await_response = (result_type > 0);
    boolean cont = true;
    while (cont) {
      Event event = session.nextEvent();

      switch (event.eventType().intValue()) {
        case Event.EventType.Constants.SESSION_STATUS:       processStatusEvent(event); cont=await_response; break;
        case Event.EventType.Constants.SERVICE_STATUS:       processStatusEvent(event); cont=await_response; break;
        case Event.EventType.Constants.RESPONSE:             processResponseEvent(result_type, event); cont=false; break;
        case Event.EventType.Constants.PARTIAL_RESPONSE:     processResponseEvent(result_type, event); break;
        default: throw new BloombergAPIWrapperException(event.eventType());
      }
    }
  }

  private void processStatusEvent(Event event) {
  }

  private void processResponseEvent(int result_type, Event event) throws BloombergAPIWrapperException {
    MessageIterator msgIter = event.messageIterator();

    while (msgIter.hasNext()) {
      Message message = msgIter.next();
      int response_id = (int)message.correlationID().value();
      DataResult result;

      switch(result_type) {
        case REFERENCE_DATA_RESULT:   result = (ReferenceDataResult)response_cache.get(response_id); break;
        case BULK_DATA_RESULT:        result = (BulkDataResult)response_cache.get(response_id); break;
        default: throw new BloombergAPIWrapperException("unknown result_type " + result_type);
      }

      result.processResponse(message.asElement());
    }
  }

  public DataResult blp(String[] securities, String[] fields) throws Exception {
    int response_id = (int)sendRefDataRequest(REFERENCE_DATA_RESULT, securities, fields).value();
    processEventLoop(REFERENCE_DATA_RESULT);
    return((DataResult)response_cache.get(response_id));
  }

  public DataResult bls(String security, String field) throws Exception {
    String[] securities = new String[1];
    securities[0] = security;

    String[] fields = new String[1];
    fields[0] = field;

    int response_id = (int)sendRefDataRequest(BULK_DATA_RESULT, securities, fields).value();
    processEventLoop(BULK_DATA_RESULT);
    return((DataResult)response_cache.get(response_id));
  }
}

