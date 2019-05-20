clear all

foreach package in outreg2 listtex listtab parmest _gwtmean geodist opencagegeo libjson insheetjson {
	capture which `package'
	if _rc==111 ssc install `package'
}

shell echo 'done' > stata_packages.txt
