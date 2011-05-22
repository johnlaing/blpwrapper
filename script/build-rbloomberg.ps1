echo "Deleting old files in contrib directories..."
rm R/src/contrib/*
rm R/bin/windows/contrib/2.12/*
rm R/bin/windows/contrib/2.13/*
rm R/bin/windows64/contrib/2.12/*
rm R/bin/windows64/contrib/2.13/*

cp java/blpwrapper.jar rbloomberg/inst/java

# Build 64-bit versions
$env:JAVA_HOME="C:\Program Files\Java\jdk1.6.0_25"
echo $env:JAVA_HOME

& 'C:\Program Files\R\R-2.13.0\bin\x64\R.exe' CMD build --binary rbloomberg
mv RBloomberg_*.zip R/bin/windows64/contrib/2.13/

& 'C:\Program Files\R\R-2.12.2\bin\x64\R.exe' CMD build --binary rbloomberg
mv RBloomberg_*.zip R/bin/windows64/contrib/2.12/


# Now build 32-bit versions
$env:JAVA_HOME="C:\Program Files (x86)\Java\jdk1.6.0_25"
echo $env:JAVA_HOME

& "C:\Program Files\R\R-2.13.0\bin\i386\R.exe" CMD build --binary rbloomberg
mv RBloomberg_*.zip R/bin/windows/contrib/2.13/

& "C:\Program Files\R\R-2.12.2\bin\i386\R.exe" CMD build --binary rbloomberg
mv RBloomberg_*.zip R/bin/windows/contrib/2.12/


# Now add package info...
& 'C:\Program Files\R\R-2.13.0\bin\x64\R.exe' CMD BATCH script\package.R

type script\package.Rout
del script\package.Rout

# Restore 64 bit Java to default...
$env:JAVA_HOME="C:\Program Files\Java\jdk1.6.0_25"
