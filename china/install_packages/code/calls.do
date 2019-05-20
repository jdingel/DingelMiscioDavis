clear all

foreach package in outreg2 listtex parmest _gwtmean geodist distinct carryforward reghdfe ftools{
	capture which `package'
	if _rc==111 ssc install `package'
}
capture which grc1leg
if _rc==111 net install grc1leg, from(http://www.stata.com/users/vwiggins)
capture which grc1leg2
if _rc==111 net install grc1leg2, from(http://digital.cgdev.org/doc/stata/MO/Misc/)

shell echo 'done' > stata_packages.txt
