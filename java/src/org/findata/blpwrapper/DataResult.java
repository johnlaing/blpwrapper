package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

import java.util.logging.Logger;

public abstract class DataResult {
  public abstract void processResponse(Element response, Logger logger) throws WrapperException;
  public abstract String[][] getData() throws WrapperException;
  public abstract String[] getColumnNames() throws WrapperException;
  public abstract String[] getDataTypes() throws WrapperException;

  public void processSecurityError(Element securityData, Logger logger) throws WrapperException {
    if (securityData.hasElement("securityError")) {
      logger.info("securityError info\n" + securityData.getElement("security") + "\n" + securityData.getElement("securityError"));

      // Note this will only show the first invalid security.
      throw new WrapperException("invalid security " + securityData.getElementAsString("security"));
    }
  }

  public void processFieldExceptions(Element securityData, Logger logger) throws WrapperException {
    Element field_exceptions = securityData.getElement("fieldExceptions");
    if (field_exceptions.numValues() > 0) {
      for (int k = 0; k < field_exceptions.numValues(); k++) {
        Element exception = field_exceptions.getValueAsElement(k);
        logger.info("fieldError info\n" + securityData.getElement("security") + "\n" + exception.getElement("fieldId"));

        Element errorInfo = exception.getElement("errorInfo");
        logger.info("" + errorInfo);
        String errorType = errorInfo.getElementAsString("subcategory");
        if (errorType.equals("INVALID_FIELD")) {
          throw new WrapperException("invalid field " + exception.getElementAsString("fieldId"));
        } else if (errorType.equals("NOT_APPLICABLE_TO_REF_DATA")) {
          // Not a fatal error. Just return null value.
        } else if (errorType.equals("NOT_APPLICABLE_TO_HIST_DATA")) {
          // Not a fatal error. Just return null value.
        } else {
          throw new WrapperException("unknown field error type " + errorType);
        }
      }
    }
  }
}
