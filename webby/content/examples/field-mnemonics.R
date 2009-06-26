source("init.R")

sink("search-mnemonics.txt")
### @export "search-mnemonics"
search.mnemonics("PX_LAST")
### @end
sink()

sink("field-info.txt")
### @export "field-info"
field.info("PX_LAST")
### @end
sink()