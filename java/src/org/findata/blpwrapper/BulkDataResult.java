package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

public class BulkDataResult implements DataResult {
  private String[] requested_fields;
  private String[] returned_fields;
  private String[] securities;
  private String[] data_types;
  private String[][] result_data;

  public BulkDataResult(String[] argSecurities, String[] argFields) {
    securities = argSecurities;
    requested_fields = argFields;
  }

  public String[][] getData() {
    return(result_data);
  }

  public String[] getDataTypes() {
    return(data_types);
  }

  public String[] getColumnNames() {
    return(returned_fields);
  }

  public void processResponse(Element response, boolean verbose) throws WrapperException {
    Element securityDataArray = response.getElement("securityData");
    Element securityData = securityDataArray.getValueAsElement(0);
    Element fieldData = securityData.getElement("fieldData");

    int seq = securityData.getElementAsInt32("sequenceNumber");
    if (seq > 0) {
      throw new WrapperException("do not expect seq " + seq + " to be greater than 0.");
    }

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

    if (fieldData.numElements() > 1) {
      throw new WrapperException("not expecting more than 1 element in fieldData, got " + fieldData.numElements());
    }

    Element x = fieldData.getElement(0);

    if (x.datatype().intValue() != Schema.Datatype.Constants.SEQUENCE) {
      throw new WrapperException("bulk data request can only handle SEQUENCE data in field " + x.name().toString());
    }

    for (int i = 0; i < x.numValues(); i++) {
      Element field = x.getValueAsElement(i);
      
      if (i == 0) {
        returned_fields = new String[field.numElements()];
        data_types = new String[field.numElements()];
        result_data = new String[x.numValues()][field.numElements()];
      }

      for (int j = 0; j < field.numElements(); j++) {
        Element y = field.getElement(j);

        if (i == 0) {
          returned_fields[j] = y.name().toString();
          data_types[j] = y.datatype().toString();
        }

        result_data[i][j] = y.getValueAsString();
      }
    }
  }
}
