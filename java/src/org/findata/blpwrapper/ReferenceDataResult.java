package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

public class ReferenceDataResult implements DataResult {
  private String[] fields;
  private String[] securities;
  private String[] data_types;
  private String[][] result_data;

  public ReferenceDataResult(String[] argSecurities, String[] argFields) {
    securities = argSecurities;
    fields = argFields;

    data_types = new String[fields.length];
    // Because we may get data type info out of order, need to
    // initialize array at start with a default value.
    for (int i = 0; i < fields.length; i++) {
      // Call this "NOT_APPLICABLE" since "NA" causes problems in R.
      data_types[i] = "NOT_APPLICABLE";
    }
    result_data = new String[securities.length][fields.length];
  }

  public String[][] getData() {
    return(result_data);
  }

  public String[] getColumnNames() {
    return(fields);
  }

  public String[] getRowNames() {
    return(securities);
  }

  public String[] getDataTypes() {
    return(data_types);
  }

  public void processResponse(Element response, boolean verbose) throws WrapperException {
    Element securityDataArray = response.getElement("securityData");
    int numItems = securityDataArray.numValues();

    for (int i = 0; i < numItems; i++) {
      Element securityData = securityDataArray.getValueAsElement(i);
      Element fieldData = securityData.getElement("fieldData");
      int seq = securityData.getElementAsInt32("sequenceNumber");

      if (securityData.hasElement("securityError")) {
        if (verbose) {
          System.err.println("********** securityError info **********");
          System.err.println(securityData.getElement("security"));
          System.err.println(securityData.getElement("securityError"));
        }
        // Note this will only show the first invalid security.
        throw new WrapperException("invalid security " + securities[seq]);
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
          } else if (errorType.equals("NOT_APPLICABLE_TO_REF_DATA")) {
            // Not a fatal error. Just return null value.
          } else {
            throw new WrapperException("unknown field error type " + errorType);
          }
        }
      }
      
      int field_data_counter = 0;
      for (int j = 0; j < fields.length; j++) { 
        String field_name = fields[j];
        String field_value = null;

        if (field_data_counter < fieldData.numElements()) {
          Element field = fieldData.getElement(field_data_counter);
          if (field.name().toString().equals(field_name)) {
            // Raise an error if we're trying to read SEQUENCE data.
            // Store the data type for later (if it hasn't already been stored).
            if (data_types[j].equals("NOT_APPLICABLE")) {
              if (field.datatype().intValue() == Schema.Datatype.Constants.SEQUENCE) {
                throw new WrapperException("reference data request cannot handle SEQUENCE data in field " + field.name().toString());
              }
              String data_type = field.datatype().toString();
              if (!data_type.equals("NA")) {
                data_types[j] = data_type;
              }
            }

            field_value = field.getValueAsString();
            field_data_counter++;
          }
        }

        result_data[seq][j] = field_value;
      } 
    }
  }
}
