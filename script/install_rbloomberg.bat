"C:\Program Files\R\R-2.9.1\bin\R.exe" CMD INSTALL "rbloomberg"
"C:\Program Files\R\R-2.9.1\bin\R.exe" CMD BATCH "rbloomberg\inst\runit-tests\run.tests.R"
echo "test results are in tests.html"
