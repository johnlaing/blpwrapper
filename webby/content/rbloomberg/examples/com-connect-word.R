library(RDCOMClient)
word = COMCreate("Word.Application")
word[["Visible"]] <- TRUE
word$quit()
