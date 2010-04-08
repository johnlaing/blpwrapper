package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

import java.util.logging.Logger;

public class HistoricalDataResult extends DataResult {
  private String[] submitted_fields;
  private String[] returned_fields;
  private String[] submitted_securities;
  private String[] data_types;
  private String[] returned_dates;
  private String[][] result_data;

  public HistoricalDataResult(String[] securities, String[] fields) {
    submitted_fields = fields;
    submitted_securities = securities;

    returned_fields = new String[fields.length + 1];
    returned_fields[0] = "date";
    for (int i = 0; i < fields.length; i++) {
      returned_fields[i+1] = fields[i];
    }

    data_types = new String[returned_fields.length];
    for (int i = 0; i < data_types.length; i++) {
      data_types[i] = "NOT_APPLICABLE";
    }
  }

  public String[][] getData() {
    return(result_data);
  }

  public String[] getColumnNames() {
    return(returned_fields);
  }

  public String[] getRowNames() {
    return(returned_dates);
  }

  public String[] getDataTypes() {
    return(data_types);
  }

  public void processResponse(Element response, Logger logger, boolean throwInvalidTickerError) throws WrapperException {
    Element securityData = response.getElement("securityData");
    Element fieldData = securityData.getElement("fieldData");
    int seq = securityData.getElementAsInt32("sequenceNumber");
    if (seq > 0) {
      throw new WrapperException("do not expect seq " + seq + " to be greater than 0.");
    }
    
    processSecurityError(securityData, logger, throwInvalidTickerError);
    processFieldExceptions(securityData, logger);

    // Iterate over historical data points
    for (int j = 0; j < fieldData.numValues(); j++) { 
      Element x = fieldData.getValueAsElement(j);

      if (j==0) {
        result_data = new String[fieldData.numValues()][returned_fields.length];
        returned_dates = new String[fieldData.numValues()];
      }

      int field_data_counter = 0;
      for (int k = 0; k < returned_fields.length; k++) {
        String field_name = returned_fields[k];
        String field_value = null;

        if (field_data_counter < x.numElements()) {
          Element field = x.getElement(field_data_counter);

          if (field.name().toString().equals(field_name)) {
            // Store data type for later.
            if (data_types[k].equals("NOT_APPLICABLE")) {
              String data_type = field.datatype().toString();
              if (!data_type.equals("NA")) {
                data_types[k] = data_type;
              }
            }

            field_value = field.getValueAsString();
            field_data_counter++;
          }
        }

        result_data[j][k] = field_value;
      } 
      returned_dates[j] = result_data[j][0];
    }
  }
}

