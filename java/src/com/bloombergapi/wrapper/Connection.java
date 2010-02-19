package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;

public class Connection {
  private SessionOptions session_options;
  private Session session;
  private EventReader handler;

  // Session options defaults.
  private String server_host = "localhost";
  private int server_port = 8194;

  private String refdata_service_name = "//blp/refdata";
  private String refdata_request_name = "ReferenceDataRequest";
  private boolean refdata_service_open = false;

  public Connection() {
    handler = new EventReader();
  }

  public void connect() throws Exception {
    setupSessionOptions();
    setupSession();
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
    session = new Session(session_options, handler);
    session.start();
  }
  
  private Service getRefDataService() throws Exception {
    if (!refdata_service_open) {
      refdata_service_open = session.openService(refdata_service_name);
    }
    return(session.getService(refdata_service_name));
  }
  
  //TODO mark private, use blp() as public interface
  public CorrelationID sendRefDataRequest(String[] securities, String[] fields) throws Exception {
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
    
    CorrelationID correlation_id = handler.nextCorrelationID();
    session.sendRequest(request, correlation_id);
    return(correlation_id);
  }

  public Object blp(String[] equities, String[] fields) throws Exception {
    return(5);
  }
}

