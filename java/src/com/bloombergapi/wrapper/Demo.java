package com.bloombergapi.wrapper;

import com.bloombergapi.wrapper.*;


public class Demo {
  public static void main(String[] args) throws Exception {
    Connection connection = new Connection();
    connection.connect();

    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "BID"};
    
    connection.blp(securities, fields);

    String[] fields2 =  {"PX_LAST"};
    ReferenceDataResult result = (ReferenceDataResult)connection.blp(securities, fields2);

    System.out.println("hello, world! wrapper demo.");
  }
}

