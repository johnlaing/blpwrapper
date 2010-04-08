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

    result_data = new String[tickDataArray.numValues()][returned_fields.length];

    for (int i = 0; i < tickDataArray.numValues(); i++) {
      Element tickData = tickDataArray.getValueAsElement(i);
      
      for (int j = 0; j < returned_fields.length; j++) {
        result_data[i][j] = tickData.getElementAsString(returned_fields[j]);
      }
    }
  }
}
