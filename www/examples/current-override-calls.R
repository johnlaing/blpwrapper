source("init.R")

sink("override-currency.out")
### @export "currency"
blp(conn, "RYA ID Equity", "PX_LAST")
blp(conn, "RYA ID Equity", "CRNCY_ADJ_PX_LAST")

blp(conn, "RYA ID Equity", "CRNCY_ADJ_PX_LAST", 
   override_fields = "EQY_FUND_CRNCY", overrides = "HKD")

blp(conn, "RYA ID Equity", "CRNCY_ADJ_PX_LAST", 
   override_fields = "EQY_FUND_CRNCY", overrides = "GBP")
### @end
sink()


sink("search-mnemonics.out")
### @export "search-mnemonics"
cat("search all mnemonics to find all with CUST_TRR\n")
search.mnemonics("CUST_TRR")

cat("find out which fields override CUST_TRR_RETURN\n")
what.overrides.me("CUST_TRR_RETURN")

cat("find our which fields are overridden by CUST_TRR_CRNCY\n")
what.i.override("CUST_TRR_CRNCY")
### @end
sink()

sink("override-total-return.out")
### @export "total-return"
blp(conn, "MSFT US Equity", c("CUST_TRR_RETURN"),
   override_fields = c("CUST_TRR_START_DT", "CUST_TRR_END_DT"), 
   overrides = c("20080215", "20080602")
)

blp(conn, "MSFT US Equity", 
   c("CUST_TRR_RETURN"), 
   override_fields = c("CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY"), 
   overrides = c("20080215", "20080602", "GBP")
)
### @end
sink()
