# We have to bundle more tests together than I would like because we don't want
# to call blpConnect too often. There's a setup and teardown but they are run
# in between each test and there's no global option.

test.basic <- function() {
  conn <- blpConnect()
  
  # Fetch static data for multiple securities and multiple fields.
  checkEquals(
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity"), c("NAME", "COUNTRY")),
    data.frame(
      NAME=c("RYANAIR HOLDINGS PLC", "BEAR STEARNS COMPANIES INC"), 
      COUNTRY=c("IR", "US"),
      row.names = c("RYA ID EQUITY", "BSC US EQUITY")
    )
  )
  
  checkEquals(
    # We are cheating here and returning a "matrix" since that is easier for
    # us to construct than the default zoo return type.
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "CUR_MKT_CAP", 
    start=as.chron(as.POSIXct("2008-02-01", tz="GMT")), 
    end=as.chron(as.POSIXct("2008-02-04", tz="GMT")), retval="matrix"),
    
    data.matrix(data.frame(
      "[DATETIME]" = c(39479, 39482),
      "RYA ID EQUITY" = c(5366.891, 5277.443),
      "BSC US EQUITY" = c(12647.49, 12390.16),
      "YHOO US EQUITY" = c(37928.28, 39197.90),
      check.names = FALSE
    )),
    tolerance = 0.000005
  )
  
  blpDisconnect(conn)
}

test.overrides <- function() {
  conn <- blpConnect()
  
  # CUST_TRR_RETURN_HOLDING_PER gives you total return for a custom period
  # of time.
  checkEquals(
    blpGetData(
         conn, 
         c("RYA ID Equity", "BSC US Equity"), 
         c("CUST_TRR_RETURN_HOLDING_PER"), 
         override_fields = c("CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY"), 
         overrides = c("20080103", "20080110", "PRC")
    ),
    data.frame(
      CUST_TRR_RETURN_HOLDING_PER=c(-9.8266, -7.2528), 
      row.names = c("RYA ID EQUITY", "BSC US EQUITY")
    )
  )
  
  
  # EQY_FUND_DT, on its own, gives you the value at the end of the fiscal year
  # which the date, in this case 20051231, falls into. So, if you call this
  # for companies with different fiscal year ends, you will get results
  # relating to different dates.
  checkEquals(
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "LT_DEBT_TO_COM_EQY",
    override_fields = c("EQY_FUND_DT"),
    overrides = c("20051231")),
    data.frame(
      LT_DEBT_TO_COM_EQY=c(76.53, 408.54, 8.76), 
      row.names = c("RYA ID EQUITY", "BSC US EQUITY", "YHOO US EQUITY")
    )
  )
  
  # Ryanair year end is at the end of March.
  # Hence EQY_FUND_DT of 20051231 returns the value reported by Ryanair
  # at the end of March 2006, since 2005-12-31 falls into this fiscal year.
  checkEquals(
    max(blpGetData(conn, c("RYA ID Equity"), "LT_DEBT_TO_COM_EQY",
    start=as.chron(as.POSIXct("2006-03-30", tz="GMT")), 
    end=as.chron(as.POSIXct("2006-04-02", tz="GMT"))), na.rm=TRUE),
    76.5275
  )
    
  # Bear Stearns year end is at the end of November. WTF November!?!?
  # Hence EQY_FUND_DT of 20051231 returns the value reported by Ryanair
  # at the end of November 2006, since 2005-12-31 falls into this fiscal year.
  
  checkEquals(
    max(blpGetData(conn, c("BSC US Equity"), "LT_DEBT_TO_COM_EQY",
    start=as.chron(as.POSIXct("2006-11-29", tz="GMT")), 
    end=as.chron(as.POSIXct("2006-12-01", tz="GMT"))), na.rm=TRUE),
    408.5385
  )
  
  # Yahoo! year end is at the end of December. Like a sensible company.
  # Hence EQY_FUND_DT of 20051231 returns the value reported by Yahoo!
  # at the end of December 2005, since 2005-12-31 falls into this fiscal year.
  checkEquals(
    max(blpGetData(conn, c("YHOO US Equity"), "LT_DEBT_TO_COM_EQY",
    start=as.chron(as.POSIXct("2005-12-29", tz="GMT")), 
    end=as.chron(as.POSIXct("2006-01-01", tz="GMT"))), na.rm=TRUE),
    8.7551
  )
  
  
  # EQY_FUND_DT combined with EQY_FUND_RELATIVE_PERIOD can give data relating
  # to more useful time periods. EQY_FUND_RELATIVE_PERIOD should be a
  # combiation of a negative number and a periodicity. Some examples of
  # valid inputs are -3FQ, -1CQ, -4FY. 0 is the most recent period available,
  # -1 is the one before that, etc. Valid periodicity codes are:
  # AQ: Actual Quarterly
  # AS: Actual Semi-Annual
  # AY: Actual Yearly
  # CQ: Calendar Quarterly
  # CS: Calendar Semi-Annual
  # CY: Calendar Yearly
  # FQ: Fiscal Quarterly
  # FS: Fiscal Semi-Annual
  # FY: Fiscal Yearly

  # Omitting EQY_FUND_RELATIVE_PERIOD is equivalent to a code of "-0AY"
  checkEquals(
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "LT_DEBT_TO_COM_EQY",
    override_fields = c("EQY_FUND_DT", "EQY_FUND_RELATIVE_PERIOD"),
    overrides = c("20051231", "-0AY")),
    data.frame(
      LT_DEBT_TO_COM_EQY=c(76.53, 408.54, 8.76), 
      row.names = c("RYA ID EQUITY", "BSC US EQUITY", "YHOO US EQUITY")
    )
  )
  
  # Passing "-0FY" returns data for the most recent fiscal year ending prior
  # to the passed date. This would be 2005-12-31 for Yahoo!, 2005-11-30 for
  # Bear Stearns and 2005-03-31 for Ryanair.
  checkEquals(
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "LT_DEBT_TO_COM_EQY",
    override_fields = c("EQY_FUND_DT", "EQY_FUND_RELATIVE_PERIOD"),
    overrides = c("20051231", "-0FY")),
    data.frame(
      LT_DEBT_TO_COM_EQY=c(74.6, 417.4, 8.76),
      row.names = c("RYA ID EQUITY", "BSC US EQUITY", "YHOO US EQUITY")
    )
  )
  
  # Passing "-0CQ" returns data for the current calendar quarter.
  checkEquals(
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "LT_DEBT_TO_COM_EQY",
    override_fields = c("EQY_FUND_DT", "EQY_FUND_RELATIVE_PERIOD"),
    overrides = c("20051231", "-0CQ")),
    data.frame(
      LT_DEBT_TO_COM_EQY=c(71.52, 417.4, 8.76),
      row.names = c("RYA ID EQUITY", "BSC US EQUITY", "YHOO US EQUITY")
    )
  )
  
  # And we can verify that these 3 data points were all reported in this
  # calendar quarter.
  checkEquals(
    as.vector(sapply(blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "LT_DEBT_TO_COM_EQY",
    start=as.chron(as.POSIXct("2005-10-15", tz="GMT")), 
    end=as.chron(as.POSIXct("2005-12-31", tz="GMT"))), max, na.rm=TRUE)),
    c(71.5221, 417.4026, 8.7551)
  )
  
  # EQY_FUND_YEAR and EQY_FUND_PER are relative to each company's
  # fiscal year. This query returns the Q4 results for what each company
  # defines to be fiscal year 2005. This is equivalent to 20051231 and "-0FY"
  checkEquals(
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "LT_DEBT_TO_COM_EQY",
    override_fields = c("EQY_FUND_YEAR", "EQY_FUND_PER"),
    overrides = c("2005", "Q4")),
    data.frame(
      LT_DEBT_TO_COM_EQY=c(74.6, 417.4, 8.76),
      row.names = c("RYA ID EQUITY", "BSC US EQUITY", "YHOO US EQUITY")
    )
  )
  
  
  # More examples - not run - with override fields for volatility surface
  # calculations.
  #
  # blpGetData(conn, c("EURUSD Curncy"), 
  #   c("SP_VOL_SURF_BID", "VOL_SURF_DELTA_OVR", "VOL_SURF_EXPIRY_OVR", "VOL_SURF_CALLPUT_OVR"),
  #   retval="raw"
  #   )
  # 
  # blpGetData(conn, c("EURUSD Curncy"), 
  #   c("SP_VOL_SURF_BID", "VOL_SURF_DELTA_OVR", "VOL_SURF_EXPIRY_OVR", "VOL_SURF_CALLPUT_OVR"),
  #   override_fields=c("VOL_SURF_DELTA_OVR", "VOL_SURF_EXPIRY_OVR", "VOL_SURF_CALLPUT_OVR"),
  #   overrides=c("30", "20081231", "P"),
  #   retval="raw"
  # )
  
  blpDisconnect(conn)
}