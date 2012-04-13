## Constants
$R = "C:\R"
$JDK = "jdk.1.7.0_03"

## Delete old, prepare for new
rm R/bin -Recurse
cp java/blpwrapper.jar rbloomberg/inst/java
$versions = ls -name $R\R-*

## Build 64-bit versions
$env:JAVA_HOME="C:\Program Files\Java\$JDK"
foreach ($version in $versions) {
    $short_version = echo $version | sed 's/\.[0-9]$//'
    mkdir R/bin/windows64/contrib/$short_version/

    & "$R\$version\bin\x64\R.exe" CMD build rbloomberg
    if ($LastExitCode -ne 0) {exit}
    mv RBloomberg_*.zip R/bin/windows/contrib/$short_version/

    Rscript -e "require(tools); write_PACKAGES('R/bin/windows64/contrib/$short_version/', type='win.binary')"
    if ($LastExitCode -ne 0) {exit}
}

## Now build 32-bit versions
$env:JAVA_HOME="C:\Program Files (x86)\Java\$JDK"
foreach ($version in $versions) {
    $short_version = echo $version | sed 's/\.[0-9]$//'
    mkdir R/bin/windows/contrib/$short_version/

    & "$R\$version\bin\x64\R.exe" CMD build rbloomberg
    if ($LastExitCode -ne 0) {exit}
    mv RBloomberg_*.zip R/bin/windows64/contrib/$short_version/

    Rscript -e "require(tools); write_PACKAGES('R/bin/windows/contrib/$short_version/', type='win.binary')"
    if ($LastExitCode -ne 0) {exit}
}

## Restore 64 bit Java to default...
$env:JAVA_HOME="C:\Program Files\Java\$JDK"
