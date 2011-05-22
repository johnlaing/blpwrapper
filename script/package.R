# This script is called by build_rbloomberg_pkg.bat
library(tools)
write_PACKAGES("R/bin/windows64/contrib/2.13/", type="win.binary")
write_PACKAGES("R/bin/windows64/contrib/2.12/", type="win.binary")
write_PACKAGES("R/bin/windows/contrib/2.13/", type="win.binary")
write_PACKAGES("R/bin/windows/contrib/2.12/", type="win.binary")

