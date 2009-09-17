# This script is called by build_rbloomberg_pkg.bat
library(tools)
write_PACKAGES("R/bin/windows/contrib/2.8/", type="win.binary")
write_PACKAGES("R/bin/windows/contrib/2.9/", type="win.binary")
