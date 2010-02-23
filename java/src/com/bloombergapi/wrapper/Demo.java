package com.bloombergapi.wrapper;

import com.bloombergapi.wrapper.*;


public class Demo {
  public static void main(String[] args) throws Exception {
    Connection connection = new Connection();
    connection.connect();

    String[] securities = {"BKIR ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "PX_LAST", "BID", "LOW_DT_52WEEK", "CHG_PCT_YTD", "LAST_UPDATE"};
    
    ReferenceDataResult result = (ReferenceDataResult)connection.blp(securities, fields);
    
    System.out.println(result.getData());
  }
}

