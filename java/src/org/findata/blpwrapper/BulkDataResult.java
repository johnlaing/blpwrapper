package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

import java.util.logging.Logger;

public class BulkDataResult extends DataResult {
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

  public void processResponse(Element response, Logger logger, boolean throwInvalidTickerError) throws WrapperException {
    Element securityDataArray = response.getElement("securityData");
    Element securityData = securityDataArray.getValueAsElement(0);
    Element fieldData = securityData.getElement("fieldData");

    int seq = securityData.getElementAsInt32("sequenceNumber");
    if (seq > 0) {
      throw new WrapperException("do not expect seq " + seq + " to be greater than 0.");
    }
    
    processSecurityError(securityData, logger, throwInvalidTickerError);
    processFieldExceptions(securityData, logger);

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

        String value = y.getValueAsString();

        if (value.equals("-2.4245362661989844E-14")) {
          logger.info("Numeric of -2.4245362661989844E-14 encountered. Not a real value. Will be left NULL.");
        } else {
          result_data[i][j] = value;
        }
      }
    }
  }
}
