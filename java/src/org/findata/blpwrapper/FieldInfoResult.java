package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

public class FieldInfoResult implements DataResult {
  public static final String[] returned_fields = {"id", "mnemonic", "description", "datatype"};
  private String[][] result_data;

  public FieldInfoResult(String[] fields) {
    result_data = new String[fields.length][returned_fields.length];
  }

  public String[][] getData() {
    return(result_data);
  }

  public String[] getDataTypes() {
    String[] data_types = {"STRING", "STRING", "STRING", "STRING"};
    return(data_types);
  }

  public String[] getColumnNames() {
    return(returned_fields);
  }

  public void processResponse(Element response, boolean verbose) throws WrapperException {
    Element field_data = response.getElement("fieldData");
    for (int i = 0; i < field_data.numValues(); i++) {
      Element field = field_data.getValueAsElement(i);
      
      try {
        Element field_info = field.getElement("fieldInfo");
        result_data[i][0] = field.getElementAsString("id");
        for (int j = 1; j < returned_fields.length; j++) {
          result_data[i][j] = field_info.getElementAsString(returned_fields[j]);
        }
      } catch (com.bloomberglp.blpapi.NotFoundException e) {
        throw new WrapperException("field " + field.getElementAsString("id") + " not found");
      }
    }
  }
}
