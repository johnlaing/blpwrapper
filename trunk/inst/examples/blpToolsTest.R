.setUp <- function() {
  multiple.fields <<- c("px_last", "bid", "ask", "NAME", "TRADING_DT_REALTIME")
}

test.is.power.of.two <- function() {
  checkTrue(isPowerOfTwo(2))
  checkTrue(!isPowerOfTwo(3))
  checkTrue(isPowerOfTwo(4))
  checkTrue(!isPowerOfTwo(6))
}

test.field.name.for.single.field <- function() {
  checkEquals(field.name("PX_LAST"), "Last Price")
}
test.field.name.for.list.of.fields <- function() {
  checkEquals(
    field.name(multiple.fields), 
    c("Last Price", "Bid Price", "Ask Price", "Name", "Trading Date")
  )
}
test.data.type.for.single.field <- function() {
  checkEquals(dataType("PX_LAST"), "double")
}
test.data.type.for.list.of.fields <- function() {
  checkEquals(
    dataType(multiple.fields),
    c("double", "double", "double", "character", "chron")
  )
}
# cnames <- c("category","category.name","subcategory","subcategory.name",
#         "field.id","field.name","field.mnemonic","mkt.bitmask",
#         "data.bitmask","data.type")
test.category <- function() {
  checkEquals(
    category(multiple.fields),
    c(195,10,10,185,10)
  )
}
test.category.name <- function() {
  checkEquals(
    category.name(multiple.fields),
    c("Pricing", "Real Time Quotes", "Real Time Quotes", "Descriptive Info", "Real Time Quotes")
  )
}

test.static <- function() {
  checkTrue(data.static("PX_LAST"))
}

test.historical <- function() {
  checkTrue(data.historical("PX_LAST"))
}

test.what.i.override <- function() {
  checkEquals(
    what.i.override("EQY_BETA_OVERRIDE_END_DT"),
    c(
    "EQY_BETA_ADJ_OVERRIDABLE"        , "EQY_BETA_RAW_OVERRIDABLE"      , 
    "EQY_ALPHA_OVERRIDABLE"           , "EQY_CORR_COEF"                 , 
    "EQY_COEF_DETER_R_SQUARED"        , "EQY_STD_DEV_ERR_OVERRIDABLE"   , 
    "EQY_BETA_STD_DEV_ERR_OVERRIDABLE", "EQY_BETA_POINTS"               , 
    "EQY_BETA_T_TEST")
  )
  
  checkException(
    what.i.override(multiple.fields)
  )
}

test.what.overides.me <- function() {
  checkEquals(
    what.overrides.me("EQY_CORR_COEF"),
    c("EQY_BETA_OVERRIDE_START_DT",  "EQY_BETA_OVERRIDE_END_DT",
      "EQY_BETA_OVERRIDE_REL_INDEX", "EQY_BETA_OVERRIDE_PERIOD")
    )
}