package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

import java.util.logging.Logger;

public class IntradayBarDataResult extends DataResult {
  private String[] requested_fields;
  private static final String[] returned_fields = {"time", "open", "high", "low", "close", "numEvents", "volume"};
  private String[] securities;
  private static final String[] data_types = {"DATETIME", "FLOAT64", "FLOAT64", "FLOAT64", "FLOAT64", "INT32", "INT64"};
  private String[][] result_data;

  public IntradayBarDataResult(String[] argSecurities, String[] argFields) {
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

  public void processResponse(Element response, Logger logger, boolean throwInvalidTickerError) throws WrapperException {
    Element barDataArray = response.getElement("barData").getElement("barTickData");
    
    int initial_offset;

    if (result_data == null) {
      logger.fine("Initializing result_data for IntradayBarDataResult");

      initial_offset = 0;
      result_data = new String[barDataArray.numValues()][returned_fields.length];
    } else {
      logger.fine("Extending existing result_data for IntradayBarDataResult");
      
      initial_offset = result_data.length;
      int combined_length = barDataArray.numValues() + initial_offset;
      String[][] combined_result_data = new String[combined_length][returned_fields.length];
      System.arraycopy(result_data, 0, combined_result_data, 0, initial_offset);
      result_data = combined_result_data;
    }

    for (int i = 0; i < barDataArray.numValues(); i++) {
      Element barData = barDataArray.getValueAsElement(i);
      
      for (int j = 0; j < returned_fields.length; j++) {
        result_data[initial_offset+i][j] = barData.getElementAsString(returned_fields[j]);
      }
    }
  }
}
