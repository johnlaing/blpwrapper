"C:\Program Files\R\R-2.8.1\bin\R.exe" CMD BUILD --binary rbloomberg
move RBloomberg_0.2-2.zip webby\content\R\bin\windows\contrib\2.8\

"C:\Program Files\R\R-2.9.1\bin\R.exe" CMD BUILD --binary rbloomberg
move RBloomberg_0.2-2.zip webby\content\R\bin\windows\contrib\2.9\

R CMD BATCH script\package.R
type script\package.Rout
del script\package.Rout
