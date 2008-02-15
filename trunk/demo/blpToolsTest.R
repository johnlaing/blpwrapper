setUp <- function() {
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
    c("double", "double", "double" "character", "chron")
  )
}
# cnames <- c("category","category.name","subcategory","subcategory.name",
#         "field.id","field.name","field.mnemonic","mkt.bitmask",
#         "data.bitmask","data.type")
test.category <- function() {
  checkEquals(
    category(multiple.fields),
    c(10,10,10,185,195)
  )
}
test.category.name <- function() {
  checkEquals(
    category.name(multiple.fields),
    c("Real Time Quotes", "Real Time Quotes", "Real Time Quotes", "Descriptive Info", "Pricing")
  )
}

test.commodity <- function() {
  checkTrue(market.commodity("ED1 Comdty"))
  checkTrue(!market.commodity("BSC US Equity"))
}

test.static <- function() {
  checkTrue(data.static("PX_LAST"))
}

test.historical <- function() {
  checkTrue(data.historical("PX_LAST"))
}