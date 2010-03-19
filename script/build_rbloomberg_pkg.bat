echo "Deleting old files in contrib directories..."
@echo off
@echo on
del /Q R\src\contrib\*
del /Q R\bin\windows\contrib\2.8\*
del /Q R\bin\windows\contrib\2.9\*
del /Q R\bin\windows\contrib\2.10\*

cp java\blpwrapper.jar rbloomberg\java

ruby script\check_rbloomberg_version.rb
ruby script\substitute_examples.rb

tar -czvf R\src\contrib\RBloomberg.tar.gz --exclude=._* -C rbloomberg .

"C:\Program Files\R\R-2.8.1\bin\R.exe" CMD BUILD --binary rbloomberg
move RBloomberg_*.zip R\bin\windows\contrib\2.8\

"C:\Program Files\R\R-2.9.2\bin\R.exe" CMD BUILD --binary rbloomberg
move RBloomberg_*.zip R\bin\windows\contrib\2.9\

"C:\Program Files\R\R-2.10.1\bin\R.exe" CMD BUILD --binary rbloomberg
move RBloomberg_*.zip R\bin\windows\contrib\2.10\

R CMD BATCH script\package.R

type script\package.Rout
del script\package.Rout

bzr revert --no-backup rbloomberg\man

