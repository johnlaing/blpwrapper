package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

public class HistoricalDataResult implements DataResult {
  private String[] submitted_fields;
  private String[] returned_fields;
  private String[] submitted_securities;
  private String[] data_types;
  private String[][] result_data;

  public HistoricalDataResult(String[] securities, String[] fields) {
    submitted_fields = fields;
    submitted_securities = securities;

    returned_fields = new String[fields.length + 1];
    data_types = new String[fields.length + 1];
  }

  public String[] getFields() {
    return(returned_fields);
  }

  public String[] getSecurities() {
    return(submitted_securities);
  }

  public String[][] getData() {
    return(result_data);
  }

  public String[] getDataTypes() {
    return(data_types);
  }

  public void processResponse(Element response) throws WrapperException {
    if (response.hasElement("responseError")) {
      Element response_error = response.getElement("responseError");
      System.err.println(response_error);
      throw new WrapperException("response error: " + response_error.getElementAsString("message"));
    }

    Element securityData = response.getElement("securityData");
    Element fieldData = securityData.getElement("fieldData");
    int seq = securityData.getElementAsInt32("sequenceNumber");
    if (seq > 0) {
      throw new WrapperException("do not expect seq " + seq + " to be greater than 0.");
    }

    if (securityData.hasElement("securityError")) {
      System.err.println(securityData.getElement("security"));
      System.err.println(securityData.getElement("securityError"));
      throw new WrapperException("invalid security " + submitted_securities[seq]);
    }

    Element field_exceptions = securityData.getElement("fieldExceptions");
    if (field_exceptions.numValues() > 0) {
      String fields_with_errors = "";

      for (int k = 0; k < field_exceptions.numValues(); k++) {
        Element exception = field_exceptions.getValueAsElement(k);
        System.err.println(exception.getElement("fieldId"));
        System.err.println(exception.getElement("errorInfo"));
        if (k > 0) {
          fields_with_errors += ", ";
        }
        fields_with_errors += exception.getElementAsString("fieldId");
      }

      // Throws all invalid fields, but only for the first security which has invalid fields.
      if (field_exceptions.numValues() > 1) {
        throw new WrapperException("invalid fields " + fields_with_errors);
      } else {
        throw new WrapperException("invalid field " + fields_with_errors);
      }
    }

    // Iterate over historical data points
    for (int j = 0; j < fieldData.numValues(); j++) { 
      Element field = fieldData.getValueAsElement(j);

      if (j==0) {
        result_data = new String[fieldData.numValues()][submitted_fields.length+1];
      }

      // Iterate over returned fields
      for (int k = 0; k < field.numElements(); k++) {
        Element x = field.getElement(k);
        if (j==0) {
          data_types[k] = x.datatype().toString();
          returned_fields[k] = x.name().toString();
        }
        result_data[j][k] = x.getValueAsString();
      }
    } 
  }
}
