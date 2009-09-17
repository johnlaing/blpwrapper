# The table of JNI types is as follows:
# I   integer  D  double (numeric)  J  long (*)    F  float (*)
# V   void  Z  boolean  C  char (integer)    B  byte (raw)
# L<class>; Java object of the class <class> (e.g. Ljava/lang/Object;)
# [<type> Array of objects of type <type> (e.g. [D for an array of doubles)
# Not all types or combinations are supported, but most are. Note that the Java type short was sacrificed for greater good (and pushed to T), namely S return type specification in .jcall is a shortcut for Ljava/lang/String;.

append_value_to_element <- function(value, element) {
   .jcall(element, returnSig = "V", "appendValue", value)
}

set_request_parameter <- function(request, parameter, value) {
   .jcall(request, returnSig = "V", "set", parameter, value)
}

grepMethod <- function(java_object, search_string) {
   grep(search_string, .jmethods(java_object), ignore.case = TRUE, value=TRUE)
}

int <- function(value) {
   .jcall(.jnew("java/lang/Integer", format(value)), "I", "intValue")
}

toString <- function(java_object) {
   .jcall(java_object, "Ljava/lang/String;", "toString")
}

hasNext <- function(java_object) {
   .jcall(java_object, returnSig="Z", method="hasNext")
}

getElement <- function(element_name, java_object) {
   .jcall(java_object, returnSig="Lcom/bloomberglp/blpapi/Element;", method="getElement", element_name)
}

getElements <- function(java_object) {
   from <- 0
   to <- numElements(java_object) - 1
   lapply(seq(from, to), getElement, java_object)
}

getValueAsElement <- function(i, java_object) {
   .jcall(java_object, returnSig="Lcom/bloomberglp/blpapi/Element;", method="getValueAsElement", int(i))
}

getValuesAsElements <- function(java_object) {
   from <- 0
   to <- numValues(java_object) - 1
   lapply(seq(from, to), getValueAsElement, java_object)
}

# Returns an ordered list of field contents.
getFieldData <- function(field) {
   field_data <- getElement("fieldData", field)
   fields <- getElements(field_data)
   lapply(fields, getFieldValue)
}

getValuesForFieldData <- function(field_data) {
   fields <- getElements(field_data)
   unlist(lapply(fields, getFieldValue))
}

getFieldAs <- function(field, fn_stub, return_sig) {
   fn_name <- paste("getValueAs", fn_stub, sep="")
   .jcall(field, returnSig = return_sig, fn_name)
}

getFieldValue <- function(field) {
   field_datatype <- getFieldType(field)
   switch(
     field_datatype,
      FLOAT64 = getFieldAs(field, "Float64", "D"),
      STRING = getFieldAs(field, "String", "S"),
      DATE = toString(getFieldAs(field, "Date", "Lcom/bloomberglp/blpapi/Datetime;")),
      show_available_methods(field)
   )
}

show_available_methods <- function(field) {
   cat("datatype of this field is ", getFieldType(field))
   grepMethod(field, "getValueAs")
   stop()
}

getFieldType <- function(field) {
   raw.result <- tryCatch(.jcall(field, "Lcom/bloomberglp/blpapi/Schema$Datatype;", "datatype"), finally=cat(class(field)))
   toString(raw.result)
}

numValues <- function(java_object) {
   .jcall(java_object, returnSig="I", method = "numValues")
}

numElements <- function(java_object) {
   .jcall(java_object, returnSig="I", method = "numElements")
}

