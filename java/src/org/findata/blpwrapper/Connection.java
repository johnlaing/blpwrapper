package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.regex.Pattern;

import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.FileHandler;
import java.util.logging.SimpleFormatter;

public class Connection {
  private SessionOptions session_options;
  private Session session;

  private Logger logger;

  public ArrayList response_cache;

  // Session options defaults.
  private String server_host = "localhost";
  private int server_port = 8194;

  private String refdata_service_name = "//blp/refdata";
  private boolean refdata_service_open = false;
  private String refdata_request_name = "ReferenceDataRequest";
  private String histdata_request_name = "HistoricalDataRequest";
  private String intraday_tick_request_name = "IntradayTickRequest";
  private String intraday_bar_request_name = "IntradayBarRequest";

  private String apifields_service_name = "//blp/apiflds";
  private boolean apifields_service_open = false;

  private boolean throw_invalid_ticker_error = true;

  public static final int REFERENCE_DATA_RESULT = 1;
  public static final int BULK_DATA_RESULT = 2;
  public static final int HISTORICAL_DATA_RESULT = 3;
  public static final int FIELD_INFO_RESULT = 4;
  public static final int INTRADAY_TICK_RESULT = 5;
  public static final int INTRADAY_BAR_RESULT = 6;

  public static final int MB = 1048576;

  public static final String DATETIME_OPTION_NAMES[] = {
    "startDateTime", 
    "endDateTime"
  };

  public static final String BOOLEAN_OPTION_NAMES[] = {
    "useUTCTime", 
    "returnRelativeDate", 
    "adjustmentNormal",
    "adjustmentAbnormal",
    "adjustmentSplit",
    "adjustmentFollowDPDF",
    "returnEids",
    "includeConditionCodes",
    "includeNonPlottableEvents",
    "includeExchangeCodes"
  };

  public Connection() throws java.io.IOException, java.lang.InterruptedException, WrapperException {
    this(Level.FINEST);
  }

  public Connection(Level logLevel) throws java.io.IOException, java.lang.InterruptedException, WrapperException {
    response_cache = new ArrayList();
    setupLogger(logLevel);
    connect();
  }

  public Connection(Level logLevel, String serverHost, int serverPort) throws java.io.IOException, java.lang.InterruptedException, WrapperException {
    server_host = serverHost;
    server_port = serverPort;
    response_cache = new ArrayList();
    setupLogger(logLevel);
    connect();
  }

  private void setupLogger(Level log_level) throws java.io.IOException {
    logger = Logger.getLogger("org.findata.blpwrapper");
    logger.setUseParentHandlers(false);
    logger.setLevel(log_level);

    if (logger.getHandlers().length == 0) {
      FileHandler handler = new FileHandler("%h/org.findata.blpwrapper.%g.log", 100*MB, 100, true);
      handler.setFormatter(new SimpleFormatter());
      logger.addHandler(handler);
    }
  }

  private void connect() throws java.io.IOException, java.lang.InterruptedException, WrapperException {
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

  public void setThrowInvalidTickerError(boolean arg) {
    throw_invalid_ticker_error = arg;
  }

  public CorrelationID nextCorrelationID(int result_type, String[] securities, String[] fields) throws Exception {
    DataResult result;
    switch(result_type) {
      case REFERENCE_DATA_RESULT:           result = new ReferenceDataResult(securities, fields); break;
      case BULK_DATA_RESULT:                result = new BulkDataResult(securities, fields); break;
      case HISTORICAL_DATA_RESULT:          result = new HistoricalDataResult(securities, fields); break;
      case FIELD_INFO_RESULT:               result = new FieldInfoResult(securities); break;
      case INTRADAY_TICK_RESULT:    result = new IntradayTickDataResult(securities, fields); break;
      case INTRADAY_BAR_RESULT:    result = new IntradayBarDataResult(securities, fields); break;
      default: throw new WrapperException("unknown result_type " + result_type);
    }
    if (response_cache.add(result)) {
      return(new CorrelationID(response_cache.size()-1));
    } else {
      throw new Exception("unable to add to response_cache");
    }
  }

  private Service getRefDataService() throws java.io.IOException, java.lang.InterruptedException {
    if (!refdata_service_open) {
      refdata_service_open = session.openService(refdata_service_name);
    }
    return(session.getService(refdata_service_name));
  }

  private Service getApiDataService() throws java.io.IOException, java.lang.InterruptedException {
    if (!apifields_service_open) {
      apifields_service_open = session.openService(apifields_service_name);
    }
    return(session.getService(apifields_service_name));
  }

  private CorrelationID sendApiDataRequest(int result_type, String[] field_identifiers) throws Exception {
    Service service = getApiDataService();
    Request request = service.createRequest("FieldInfoRequest");

    for (int i = 0; i < field_identifiers.length; i++) {
      request.append("id", field_identifiers[i]);
    }

    String[] mock_fields = {""};
    CorrelationID correlation_id = nextCorrelationID(result_type, field_identifiers, mock_fields);
    session.sendRequest(request, correlation_id);
    return(correlation_id);
  }

  private CorrelationID sendRefDataRequest(int result_type, String request_name, String[] securities, String[] fields, String[] override_fields, String[] override_values, String[] option_names, String[] option_values) throws Exception {
    String[] event_types = new String[0];
    return(sendRefDataRequest(result_type, request_name, securities, fields, override_fields, override_values, option_names, option_values, event_types));
  }

  private CorrelationID sendRefDataRequest(int result_type, String request_name, String[] securities, String[] fields, String[] override_fields, String[] override_values, String[] option_names, String[] option_values, String[] event_types) throws Exception {
    Service service = getRefDataService();
    Request request = service.createRequest(request_name);
    
    if (request.hasElement("securities")) {
      Element securities_element = request.getElement("securities");
      for (int i = 0; i < securities.length; i++) {
        securities_element.appendValue(securities[i]);
      }
    }
    
    if (request.hasElement("fields")) {
      Element fields_element = request.getElement("fields");
      for (int i = 0; i < fields.length; i++) {
        fields_element.appendValue(fields[i]);
      }
    }

    if (override_fields.length > 0) {
      Element override_values_element = request.getElement("overrides");
      for (int i = 0; i < override_fields.length; i++) {
        if (!override_fields[i].equals("IGNORE")) {
          Element override = override_values_element.appendElement();
          override.setElement("fieldId", override_fields[i]);
          override.setElement("value", override_values[i]);
          logger.fine("override " + override_fields[i] + " set to " + override_values[i]);
        }
      }
    }

    if (event_types.length > 0) {
      for (int i = 0; i < event_types.length; i++) {
        request.append("eventTypes", event_types[i]);
      }
    }

    for (int i = 0; i < option_names.length; i++) {
      String n = option_names[i];

      HashSet datetime_option_names = new HashSet(Arrays.asList(DATETIME_OPTION_NAMES));
      HashSet boolean_option_names = new HashSet(Arrays.asList(BOOLEAN_OPTION_NAMES));
      
      if (datetime_option_names.contains(n)) {
        Pattern p = Pattern.compile(":|-|\\.|\\s"); // Expecting e.g. 2010-01-01 09:00:00.000
        String[] time_parts = p.split(option_values[i]);

        int year = new Integer(time_parts[0]).intValue();
        int month = new Integer(time_parts[1]).intValue();
        int day_of_month = new Integer(time_parts[2]).intValue();
        int hour = new Integer(time_parts[3]).intValue();
        int minute = new Integer(time_parts[4]).intValue();
        int second = new Integer(time_parts[5]).intValue();
        int millisecond = new Integer(time_parts[6]).intValue();

        Datetime d = new Datetime(year, month, day_of_month, hour, minute, second, millisecond);
        logger.fine("option " + n + " set to Datetime value " + d + ".");
        request.set(n, d); 
      } else if (boolean_option_names.contains(n)) {
        boolean option_value;

        String true_value_elements[] = {"true", "TRUE", "True", "t", "T"};
        HashSet true_values = new HashSet(Arrays.asList(true_value_elements));

        String false_value_elements[] = {"false", "FALSE", "False", "f", "F"};
        HashSet false_values = new HashSet(Arrays.asList(false_value_elements));
        
        if (true_values.contains(option_values[i])) {
          option_value = true;
        } else if (false_values.contains(option_values[i])) {
          option_value = false;
        } else {
          throw new WrapperException("Unable to convert this string '" + option_values[i] + "' to a boolean.");
        }

        logger.fine("option " + n + " set to boolean value " + option_value + " original string '" + option_values[i] + "'.");
        request.set(n, option_value);
      } else {
        logger.fine("option " + n + " set to string value '" + option_values[i] + "'.");
        request.set(n, option_values[i]);
      }
    }

    CorrelationID correlation_id = nextCorrelationID(result_type, securities, fields);
    session.sendRequest(request, correlation_id);
    return(correlation_id);
  }

  private void processEventLoop() throws java.lang.InterruptedException, WrapperException {
    processEventLoop(0);
  }

  private void processEventLoop(int result_type) throws java.lang.InterruptedException, WrapperException {
    boolean await_response = (result_type > 0);
    boolean cont = true;
    while (cont) {
      Event event = session.nextEvent();

      String event_type_string = event.eventType().toString();

      if (event_type_string == "SESSION_STATUS") {
        processSessionStatusEvent(event);
        cont = await_response;
      } else if (event_type_string == "SERVICE_STATUS") {
        processServiceStatusEvent(event); 
        cont = await_response;
      } else if (event_type_string == "RESPONSE") {
        processResponseEvent(result_type, event);
        cont = false;
      } else if (event_type_string == "PARTIAL_RESPONSE") {
        processResponseEvent(result_type, event);
      } else {
        throw new WrapperException(event.eventType());
      }
    }
  }

  private void processSessionStatusEvent(Event event) throws WrapperException {
    MessageIterator msgIter = event.messageIterator();

    while(msgIter.hasNext()) {
      Message message = msgIter.next();
      Element response = message.asElement();

      if (response.name().equals("SessionStarted")) {
        logger.info("Session Started");
      } else if (response.name().equals("SessionStartupFailure")) {
        logger.warning("" + response);
        Element reason = response.getElement(0);
        throw new WrapperException("Session not started because: " + reason.getElementAsString("description"));
      } else {
        logger.warning("" + response);
        throw new WrapperException("Session not started. See logs. Please report this to blpwrapper maintainer.");
      }
    }
  }

  private void processServiceStatusEvent(Event event) throws WrapperException {
    MessageIterator msgIter = event.messageIterator();

    while(msgIter.hasNext()) {
      Message message = msgIter.next();
      Element response = message.asElement();

      if (response.name().equals("ServiceOpened")) {
        logger.info("Service Started");
      } else {
        logger.warning("" + response);
        throw new WrapperException("Service not started. See logs. Please report this to blpwrapper maintainer.");
      }
    }
  }

  private void processResponseEvent(int result_type, Event event) throws WrapperException {
    MessageIterator msgIter = event.messageIterator();

    while (msgIter.hasNext()) {
      Message message = msgIter.next();
      int response_id = (int)message.correlationID().value();
      logger.fine("Response id " + response_id);
      DataResult result;

      switch(result_type) {
        case REFERENCE_DATA_RESULT:     result = (ReferenceDataResult)response_cache.get(response_id); break;
        case BULK_DATA_RESULT:          result = (BulkDataResult)response_cache.get(response_id); break;
        case HISTORICAL_DATA_RESULT:    result = (HistoricalDataResult)response_cache.get(response_id); break;
        case FIELD_INFO_RESULT:         result = (FieldInfoResult)response_cache.get(response_id); break;
        case INTRADAY_TICK_RESULT:      result = (IntradayTickDataResult)response_cache.get(response_id); break;
        case INTRADAY_BAR_RESULT:       result = (IntradayBarDataResult)response_cache.get(response_id); break;
        default: throw new WrapperException("unknown result_type " + result_type);
      }

      Element response = message.asElement();

      if (response.hasElement("responseError")) {
        Element response_error = response.getElement("responseError");
        logger.warning(response_error.toString());
        throw new WrapperException("response error: " + response_error.getElementAsString("message"));
      }
      logger.fine("Processing response:\n" + response);
      result.processResponse(response, logger, throw_invalid_ticker_error);
    }
  }

  public DataResult fieldInfo(String[] fields) throws Exception {
    int response_id = (int)sendApiDataRequest(FIELD_INFO_RESULT, fields).value();
    processEventLoop(FIELD_INFO_RESULT);
    return((DataResult)response_cache.get(response_id));
  }

  public DataResult blp(String[] securities, String[] fields) throws Exception {
    String[] override_fields = new String[0];
    String[] override_values = new String[0];
    String[] option_names = new String[0];
    String[] option_values = new String[0];
    return(blp(securities, fields, override_fields, override_values, option_names, option_values));
  }

  public DataResult blp(String[] securities, String[] fields, String[] override_fields, String[] override_values) throws Exception {
    String[] option_names = new String[0];
    String[] option_values = new String[0];
    return(blp(securities, fields, override_fields, override_values, option_names, option_values));
  }

  public DataResult blp(String[] securities, String[] fields, String[] override_fields, String[] override_values, String[] option_names, String[] option_values) throws Exception {
    int response_id = (int)sendRefDataRequest(REFERENCE_DATA_RESULT, refdata_request_name, securities, fields, override_fields, override_values, option_names, option_values).value();
    processEventLoop(REFERENCE_DATA_RESULT);
    return((DataResult)response_cache.get(response_id));
  }

  public DataResult blh(String security, String[] fields, String start_date, String end_date) throws Exception {
    String[] override_fields = new String[0];
    String[] override_values = new String[0];

    String[] option_names = {"startDate", "endDate"};
    String[] option_values = new String[2];
    option_values[0] = start_date;
    option_values[1] = end_date;

    return(blh(security, fields, override_fields, override_values, option_names, option_values));
  }

  public DataResult blh(String security, String[] fields, String start_date) throws Exception {
    String[] override_fields = new String[0];
    String[] override_values = new String[0];

    String[] option_names = {"startDate"};
    String[] option_values = new String[1];
    option_values[0] = start_date;

    return(blh(security, fields, override_fields, override_values, option_names, option_values));
  }

  public DataResult blh(String security, String[] fields, String start_date, String end_date, String[] override_fields, String[] override_values) throws Exception {
    String[] option_names = {"startDate", "endDate"};
    String[] option_values = new String[2];
    option_values[0] = start_date;
    option_values[1] = end_date;

    return(blh(security, fields, override_fields, override_values, option_names, option_values));
  }

  public DataResult blh(String security, String[] fields, String start_date, String[] override_fields, String[] override_values) throws Exception {
    String[] option_names = {"startDate"};
    String[] option_values = new String[1];
    option_values[0] = start_date;

    return(blh(security, fields, override_fields, override_values, option_names, option_values));
  }

  public DataResult blh(String security, String[] fields, String start_date, String[] override_fields, String[] override_values, String[] option_names, String[] option_values) throws Exception {

    int len = option_names.length;
    String[] option_names_with_start = new String[len + 1];
    String[] option_values_with_start = new String[len + 1];

    for (int i = 0; i < len; i++) {
      option_names_with_start[i] = option_names[i];
      option_values_with_start[i] = option_values[i];
    }

    option_names_with_start[len] = "startDate";
    option_values_with_start[len] = start_date;

    return(blh(security, fields, override_fields, override_values, option_names_with_start, option_values_with_start));
  }

  public DataResult blh(String security, String[] fields, String start_date, String end_date, String[] override_fields, String[] override_values, String[] option_names, String[] option_values) throws Exception {

    int len = option_names.length;
    String[] option_names_with_start = new String[len + 2];
    String[] option_values_with_start = new String[len + 2];

    for (int i = 0; i < len; i++) {
      option_names_with_start[i] = option_names[i];
      option_values_with_start[i] = option_values[i];
    }

    option_names_with_start[len] = "startDate";
    option_values_with_start[len] = start_date;

    option_names_with_start[len+1] = "endDate";
    option_values_with_start[len+1] = end_date;
    
    return(blh(security, fields, override_fields, override_values, option_names_with_start, option_values_with_start));
  }

  public DataResult blh(String security, String[] fields, String[] override_fields, String[] override_values, String[] option_names, String[] option_values) throws Exception {
    String[] securities = new String[1];
    securities[0] = security;

    int response_id = (int)sendRefDataRequest(HISTORICAL_DATA_RESULT, histdata_request_name, securities, fields, override_fields, override_values, option_names, option_values).value();
    processEventLoop(HISTORICAL_DATA_RESULT);
    return((DataResult)response_cache.get(response_id));
  }
  
  /**
   * Request bulk data from Bloomberg. Shortcut method which allows you to call bls simply by passing a security and field.
   * @param security A string containing security ticker.
   * @param field A string containing field mnemonic.
   */
  public DataResult bls(String security, String field) throws Exception {
    String[] override_fields = new String[0];
    String[] override_values = new String[0];
    String[] option_names = new String[0];
    String[] option_values = new String[0];
    return(bls(security, field, override_fields, override_values, option_names, option_values));
  }

  /**
   * Request bulk data from Bloomberg. Bulk data may return several different fields for a single requested field.
   * @param security A string containing security ticker.
   * @param field A string containing field mnemonic.
   * @param override_fields Array of strings with field mnemonics for override fields.
   * @param override_values Array of strings with override values, must be in same order as override_fields.
   */
  public DataResult bls(String security, String field, String[] override_fields, String[] override_values) throws Exception {
    String[] option_names = new String[0];
    String[] option_values = new String[0];
    return(bls(security, field, override_fields, override_values, option_names, option_values));
  }

  /**
   * Request bulk data from Bloomberg. Bulk data may return several different fields for a single requested field.
   * @param security A string containing security ticker.
   * @param field A string containing field mnemonic.
   * @param override_fields Array of strings with field mnemonics for override fields.
   * @param override_values Array of strings with override values, must be in same order as override_fields.
   * @param option_names Array of strings with option names.
   * @param option_values Array of strings with option values, must be in same order as option_names.
   */
  public DataResult bls(String security, String field, String[] override_fields, String[] override_values, String[] option_names, String[] option_values) throws Exception {
    String[] securities = new String[1];
    securities[0] = security;

    String[] fields = new String[1];
    fields[0] = field;

    int response_id = (int)sendRefDataRequest(BULK_DATA_RESULT, refdata_request_name, securities, fields, override_fields, override_values, option_names, option_values).value();
    processEventLoop(BULK_DATA_RESULT);
    return((DataResult)response_cache.get(response_id));
  }

  public DataResult tick(String security, String[] event_types, String start_date_time, String end_date_time) throws Exception {
    String[] option_names = new String[0];
    String[] option_values = new String[0];

    return(tick(security, event_types, start_date_time, end_date_time, option_names, option_values));
  }

  public DataResult tick(String security, String[] event_types, String start_date_time, String end_date_time, String[] option_names, String[] option_values) throws Exception {
    String[] securities = new String[0];
    String[] fields = new String[0];
  
    int len = option_names.length;
    String[] option_names_with_start = new String[len + 3];
    String[] option_values_with_start = new String[len + 3];
    
    for (int i = 0; i < option_names.length; i++) {
      option_names_with_start[i] = option_names[i];
      option_values_with_start[i] = option_values[i];
    }

    option_names_with_start[len] = "security";
    option_values_with_start[len] = security;
    option_names_with_start[len+1] = "startDateTime";
    option_values_with_start[len+1] = start_date_time;
    option_names_with_start[len+2] = "endDateTime";
    option_values_with_start[len+2] = end_date_time;

    String[] override_fields = new String[0];
    String[] override_values = new String[0];

    int response_id = (int)sendRefDataRequest(INTRADAY_TICK_RESULT, intraday_tick_request_name, securities, fields, override_fields, override_values, option_names_with_start, option_values_with_start, event_types).value();
    processEventLoop(INTRADAY_TICK_RESULT);
    return((DataResult)response_cache.get(response_id));
  }

  public DataResult bar(String security, String event_type, String start_date_time, String end_date_time, String interval) throws Exception {
    String[] securities = new String[0];
    String[] fields = new String[0];

    String[] option_names = new String[0];
    String[] option_values = new String[0];
    String[] override_fields = new String[0];
    String[] override_values = new String[0];
  
    int len = option_names.length;
    String[] option_names_with_start = new String[len + 5];
    String[] option_values_with_start = new String[len + 5];
    
    for (int i = 0; i < option_names.length; i++) {
      option_names_with_start[i] = option_names[i];
      option_values_with_start[i] = option_values[i];
    }

    option_names_with_start[len] = "security";
    option_values_with_start[len] = security;
    option_names_with_start[len+1] = "startDateTime";
    option_values_with_start[len+1] = start_date_time;
    option_names_with_start[len+2] = "endDateTime";
    option_values_with_start[len+2] = end_date_time;
    option_names_with_start[len+3] = "eventType";
    option_values_with_start[len+3] = event_type;
    option_names_with_start[len+4] = "interval";
    option_values_with_start[len+4] = interval;

    int response_id = (int)sendRefDataRequest(INTRADAY_BAR_RESULT, intraday_bar_request_name, securities, fields, override_fields, override_values, option_names_with_start, option_values_with_start).value();
    processEventLoop(INTRADAY_BAR_RESULT);
    return((DataResult)response_cache.get(response_id));
  }
}

