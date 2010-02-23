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
    Element securityDataArray = response.getElement("securityData");
    int numItems = securityDataArray.numValues();

    for (int i = 0; i < numItems; i++) {
      System.out.println("i :" + i);
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
        Element field = fieldData.getElement(j);

        if (seq==0) {

          if (field.datatype().intValue() != Schema.Datatype.Constants.SEQUENCE) {
            throw new BloombergAPIWrapperException("bulk data request can only handle SEQUENCE data in field " + field.name().toString());
          }

          Element x = field.getValueAsElement(0);
          int num_data_fields = x.numElements();

          returned_fields = new String[num_data_fields];
          data_types = new String[num_data_fields];
          result_data = new String[field.numElements()][num_data_fields];

          for(int k = 0; k < num_data_fields; k++) {
            Element y = x.getElement(k);
            returned_fields[k] = y.name().toString();
            data_types[k] = y.datatype().toString();
          }

        }

        for (int l = 0; l < field.numElements(); l++) {
          Element x = field.getValueAsElement(l);

          for (int k = 0; k < x.numElements(); k++) {
            System.out.println("l: " + l + "; k: " + k);
            Element y = x.getElement(k);
            result_data[l][k] = y.getValueAsString();
          }
        }
      } 
    }
  }
}
