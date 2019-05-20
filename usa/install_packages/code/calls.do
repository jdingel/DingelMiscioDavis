clear all

foreach package in outreg2 listtex parmest _gwtmean geodist winsor2 {
	capture which `package'
	if _rc==111 ssc install `package'
}
capture which grc1leg
if _rc==111 net install grc1leg, from(http://www.stata.com/users/vwiggins)
capture which grc1leg2
if _rc==111 net install grc1leg2, from(http://digital.cgdev.org/doc/stata/MO/Misc/)
capture which mylabels
if _rc==111 net install mylabels, from(http://fmwww.bc.edu/RePEc/bocode/m)

file open outfile using "stata_packages.txt", write replace text
file write outfile "Package installation commands ran." _n
file close outfile
