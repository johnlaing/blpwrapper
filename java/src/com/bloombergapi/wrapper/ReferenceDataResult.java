package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;
import java.util.HashMap;

public class ReferenceDataResult{
  private String[][] result_data;
  private String[] submitted_fields;
  private String[] submitted_securities;

  public ReferenceDataResult(String[] securities, String[] fields) {
    submitted_fields = fields;
    submitted_securities = securities;
    result_data = new String[fields.length][securities.length];
  }

  public String csv() {
    String x = "";
    for (int i = 0; i < result_data.length; i++) {
      for (int j = 0; j < result_data[0].length; j++) {
        x += result_data[i][j];
        x += "\t";
      }
      x += "\n";
    }
    return(x);
  }

  public void processResponse(Element response) {
    Element securityDataArray = response.getElement("securityData");

    int numItems = securityDataArray.numValues();
    for (int j = 0; j < numItems; ++j) {
      Element securityData = securityDataArray.getValueAsElement(j);
      Element fieldData = securityData.getElement("fieldData");
      int seq = securityData.getElementAsInt32("sequenceNumber");

      for (int i = 0; i < fieldData.numElements(); i++) {
        Element field = fieldData.getElement(i);
        
        System.out.println("field name" + field.name());
        System.out.println("field value" + field.getValueAsString());

        result_data[i][j] = field.getValueAsString();
      }
    } 
  }
}
