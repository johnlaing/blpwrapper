echo "Deleting old files in contrib directories..."
@echo off
del /Q R\src\contrib\*
del /Q R\bin\windows\contrib\2.8\*
del /Q R\bin\windows\contrib\2.9\*

tar -czvf R\src\contrib\RBloomberg.tar.gz --exclude=._* -C rbloomberg .

"C:\Program Files\R\R-2.8.1\bin\R.exe" CMD BUILD --binary rbloomberg
move RBloomberg_0.2-2.zip R\bin\windows\contrib\2.8\

"C:\Program Files\R\R-2.9.2\bin\R.exe" CMD BUILD --binary rbloomberg
move RBloomberg_0.2-2.zip R\bin\windows\contrib\2.9\

R CMD BATCH script\package.R

type script\package.Rout
del script\package.Rout
@echo on