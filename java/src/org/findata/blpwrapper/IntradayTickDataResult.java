package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

import java.util.logging.Logger;

public class IntradayTickDataResult extends DataResult {
  private String[] requested_fields;
  private static final String[] returned_fields = {"time", "type", "value", "size"};
  private String[] securities;
  private static final String[] data_types = {"DATETIME", "STRING", "FLOAT64", "INT32"};
  private String[][] result_data;

  public IntradayTickDataResult(String[] argSecurities, String[] argFields) {
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
    Element tickDataArray = response.getElement("tickData").getElement("tickData");

    int initial_offset;

    if (result_data == null) {
      logger.fine("Initializing result_data for IntradayTickDataResult");

      initial_offset = 0;
      result_data = new String[tickDataArray.numValues()][returned_fields.length];
    } else {
      logger.fine("Extending existing result_data for IntradayTickDataResult");
      
      initial_offset = result_data.length;
      int combined_length = tickDataArray.numValues() + initial_offset;
      String[][] combined_result_data = new String[combined_length][returned_fields.length];
      System.arraycopy(result_data, 0, combined_result_data, 0, initial_offset);
      result_data = combined_result_data;
    }


    for (int i = 0; i < tickDataArray.numValues(); i++) {
      Element tickData = tickDataArray.getValueAsElement(i);
      
      for (int j = 0; j < returned_fields.length; j++) {
        result_data[initial_offset+i][j] = tickData.getElementAsString(returned_fields[j]);
      }
    }
  }
}
