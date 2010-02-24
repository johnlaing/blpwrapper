package com.bloombergapi.wrapper;

import com.bloomberglp.blpapi.*;

public abstract interface DataResult {
  void processResponse(Element response) throws BloombergAPIWrapperException;
  String[][] getData() throws BloombergAPIWrapperException;
}
