package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;
import java.util.HashMap;

public class ReferenceDataResult{
  private String[] submitted_fields;
  private String[] returned_fields;
  private String[] submitted_securities;
  private String[] data_types;
  private String[][] result_data;

  public ReferenceDataResult(String[] securities, String[] fields) {
    submitted_fields = fields;
    submitted_securities = securities;

    returned_fields = new String[fields.length];

    data_types = new String[fields.length];
    result_data = new String[securities.length][fields.length];
  }

  public String tsv() {
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

  public String[] fields() {
    return(returned_fields);
  }

  public String[] securities() {
    return(submitted_securities);
  }

  public String[][] getData() {
    return(result_data);
  }

  public String[] getDataTypes() {
    return(data_types);
  }

  public void processResponse(Element response) throws Exception {
    Element securityDataArray = response.getElement("securityData");
    int numItems = securityDataArray.numValues();

    // Iterate over securities.
    for (int i = 0; i < numItems; i++) {
      Element securityData = securityDataArray.getValueAsElement(i);
      Element fieldData = securityData.getElement("fieldData");
      int seq = securityData.getElementAsInt32("sequenceNumber");

      // Iterate over fields for each security
      for (int j = 0; j < fieldData.numElements(); j++) { 
        Element field = fieldData.getElement(j);
        
        if (seq==0) {
          // This is the first security to be processed.
          // Store field name and type.
          data_types[j] = field.datatype().toString();
          returned_fields[j] = field.name().toString();
        }

        result_data[seq][j] = field.getValueAsString();
      } 
    }
  }
}
