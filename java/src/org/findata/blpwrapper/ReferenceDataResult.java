package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

import java.util.logging.Logger;

public class ReferenceDataResult extends DataResult {
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

  public void processResponse(Element response, Logger logger) throws WrapperException {
    Element securityDataArray = response.getElement("securityData");
    int numItems = securityDataArray.numValues();

    for (int i = 0; i < numItems; i++) {
      Element securityData = securityDataArray.getValueAsElement(i);
      Element fieldData = securityData.getElement("fieldData");
      int seq = securityData.getElementAsInt32("sequenceNumber");

      processSecurityError(securityData, logger);
      processFieldExceptions(securityData, logger);

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
