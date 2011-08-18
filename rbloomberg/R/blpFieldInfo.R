blpFieldInfo <- function(conn, fields) {
  fields <- .jarray(fields)
  result <- conn$fieldInfo(fields)

  l <- .jevalArray(result$getData(), simplify = TRUE)
  colnames(l) <- result$getColumnNames()
  rownames(l) <- .jevalArray(result$getData(), simplify = TRUE)[,2]
  df.data <- as.data.frame(l)
  
  return(df.data)
}

field.description <- function(conn, mnemonic) {
  as.vector(blpFieldInfo(conn, fields)["description"])
}

