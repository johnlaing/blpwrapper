package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;
import java.util.HashMap;

public class ReferenceDataResult{
  private String[] submitted_fields;
  private String[] returned_fields;
  private String[] submitted_securities;
  private String[] data_types;
  private Object[] result_data;

  public ReferenceDataResult(String[] securities, String[] fields) {
    submitted_fields = fields;
    submitted_securities = securities;

    returned_fields = new String[fields.length];

    data_types = new String[fields.length];
    result_data = new Object[fields.length];
  }

  public String csv() {
    String x = "";
    for (int i = 0; i < result_data.length; i++) {
      for (int j = 0; j < ((Object[])result_data[0]).length; j++) {
        x += ((Object[])result_data[i])[j];
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

  public Object[] getData() {
    return(result_data);
  }

  public void processResponse(Element response) throws Exception {
    Element securityDataArray = response.getElement("securityData");

    int numItems = securityDataArray.numValues();
    for (int j = 0; j < numItems; ++j) {
      Element securityData = securityDataArray.getValueAsElement(j);
      Element fieldData = securityData.getElement("fieldData");
      int seq = securityData.getElementAsInt32("sequenceNumber");

      for (int i = 0; i < fieldData.numElements(); i++) {
        Element field = fieldData.getElement(i);

        if (seq==0) {
          data_types[i] = field.datatype().toString();

          switch(field.datatype().intValue()) {
            case Schema.Datatype.Constants.FLOAT64: result_data[i] = new Double[submitted_securities.length]; break;
            case Schema.Datatype.Constants.STRING:  result_data[i] = new String[submitted_securities.length]; break;                                                    
            default: throw new Exception("don't recognize data type " + field.datatype().toString());
          }

          returned_fields[i] = field.name().toString();
        }


        switch(field.datatype().intValue()) {
          case Schema.Datatype.Constants.FLOAT64: ((Object[])result_data[i])[j] = field.getValueAsFloat64(); break;
          case Schema.Datatype.Constants.STRING: ((Object[])result_data[i])[j] = field.getValueAsString(); break;
          default: throw new Exception("don't recognize data type " + field.datatype().toString());
        }
      } 
    }
  }
}
