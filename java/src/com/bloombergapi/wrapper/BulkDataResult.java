package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;

public class BulkDataResult implements DataResult {
  private String[] submitted_fields;
  private String[] returned_fields;
  private String[] submitted_securities;
  private String[] data_types;
  private String[][] result_data;

  public BulkDataResult(String[] securities, String[] fields) {
    submitted_fields = fields;
    submitted_securities = securities;
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

  public void processResponse(Element response) throws BloombergAPIWrapperException {
    if (response.hasElement("responseError")) {
      Element response_error = response.getElement("responseError");
      System.err.println(response_error);
      throw new BloombergAPIWrapperException("response error: " + response_error.getElementAsString("message"));
    }
    Element securityDataArray = response.getElement("securityData");
    int numItems = securityDataArray.numValues();

    for (int i = 0; i < numItems; i++) {
      if (i > 0) {
        throw new BloombergAPIWrapperException("wasn't expecting i > 0");
      }
      Element securityData = securityDataArray.getValueAsElement(i);
      Element fieldData = securityData.getElement("fieldData");
      int seq = securityData.getElementAsInt32("sequenceNumber");

      // Check for errors.
      if (securityData.hasElement("securityError")) {
        System.err.println(securityData.getElement("security"));
        System.err.println(securityData.getElement("securityError"));
        // Note this will only show the first invalid security.
        throw new BloombergAPIWrapperException("invalid security " + submitted_securities[seq]);
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
          throw new BloombergAPIWrapperException("invalid fields " + fields_with_errors);
        } else {
          throw new BloombergAPIWrapperException("invalid field " + fields_with_errors);
        }
      }

      // Iterate over fields for each security
      for (int j = 0; j < fieldData.numElements(); j++) { 
        if (j > 0) {
          throw new BloombergAPIWrapperException("wasn't expecting j > 0");
        }
        Element field = fieldData.getElement(j);

        if (field.datatype().intValue() != Schema.Datatype.Constants.SEQUENCE) {
          throw new BloombergAPIWrapperException("bulk data request can only handle SEQUENCE data in field " + field.name().toString());
        }
        
        // Look at first element to get field names and types
        Element x = field.getValueAsElement(0);

        returned_fields = new String[x.numElements()];
        data_types = new String[x.numElements()];
        result_data = new String[field.numValues()][x.numElements()];

        for (int k = 0; k < x.numElements(); k++) {
          Element y = x.getElement(k);
          returned_fields[k] = y.name().toString();
          data_types[k] = y.datatype().toString();
        }

        for (int l = 0; l < field.numValues(); l++) {
          Element z = field.getValueAsElement(l);

          for (int k = 0; k < x.numElements(); k++) {
            Element y = z.getElement(k);
            result_data[l][k] = y.getValueAsString();
          }
        }
      } 
    }
  }
}
