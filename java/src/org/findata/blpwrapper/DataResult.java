package org.findata.blpwrapper;

import com.bloomberglp.blpapi.*;

public abstract interface DataResult {
  void processResponse(Element response, boolean verbose) throws WrapperException;
  String[][] getData() throws WrapperException;
  String[] getColumnNames() throws WrapperException;
  String[] getDataTypes() throws WrapperException;
}
