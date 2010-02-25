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

  public void processResponse(Element response, boolean verbose) throws WrapperException {
    Element securityData = response.getElement("securityData");
    Element fieldData = securityData.getElement("fieldData");
    int seq = securityData.getElementAsInt32("sequenceNumber");
    if (seq > 0) {
      throw new WrapperException("do not expect seq " + seq + " to be greater than 0.");
    }

    if (securityData.hasElement("securityError")) {
      if (verbose) {
        System.err.println(securityData.getElement("security"));
        System.err.println(securityData.getElement("securityError"));
      }
      throw new WrapperException("invalid security " + submitted_securities[seq]);
    }

    Element field_exceptions = securityData.getElement("fieldExceptions");
    if (field_exceptions.numValues() > 0) {
      for (int k = 0; k < field_exceptions.numValues(); k++) {
        Element exception = field_exceptions.getValueAsElement(k);
        if (verbose) {
          System.err.println("********** fieldError info **********");
          System.err.println(securityData.getElement("security"));
          System.err.println(exception.getElement("fieldId"));
        }

        Element errorInfo = exception.getElement("errorInfo");
        if (verbose) {
          System.err.println(errorInfo);
        }
        String errorType = errorInfo.getElementAsString("subcategory");
        if (errorType.equals("INVALID_FIELD")) {
          throw new WrapperException("invalid field " + exception.getElementAsString("fieldId"));
        } else if (errorType.equals("NOT_APPLICABLE_TO_HIST_DATA")) {
          // Not a fatal error. Just return null value.
        } else {
          throw new WrapperException("unknown field error type " + errorType);
        } 
      }
    }

    // Iterate over historical data points
    for (int j = 0; j < fieldData.numValues(); j++) { 
      Element field = fieldData.getValueAsElement(j);

      if (j==0) {
        result_data = new String[fieldData.numValues()][submitted_fields.length+1];
      }
      
      // TODO iterate over submitted fields instead as in ReferenceDataResult
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
