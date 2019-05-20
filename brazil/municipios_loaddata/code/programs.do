
cap program drop municipio_pop
program municipio_pop
syntax, saveas(string)

tempfile tf1
//We import the .xls file and not the .dta file because municipio names in the .dta files are incorrect (special characters are missing).
import excel using "../input/census_popmun_1872-2010.xls", clear firstrow
save `tf1'.dta, replace

//** LOADING AND CLEANING municipio POPULATION FROM 1940 TO 2010 **//
foreach y in 1940 1950 1960 1970 1980 1991 2000 2010{
	tempfile tf`y'
	use `tf1'.dta, clear

	keep cod`y' Município`y' poptot`y' popurb`y' poprur`y' //Only keeping variables for the year in question.
	drop if missing(cod`y') //Only keeping municipios that were defined for the given year.
	gen year = `y' //Year identifier

	//Renaming variables.
	ren cod`y' municipio_code_full
	ren Município`y' municipio_name
	ren poptot`y' totalpop
	ren popurb`y' urbanpop
	ren poprur`y' ruralpop

	replace municipio_name = trim(municipio_name) //Removing leading and/or trailing blanks from municipio_name

	//Converting variables to strings so we can use some string functions (see below).
	foreach v in totalpop urbanpop ruralpop municipio_code_full{
		tostring `v', force replace
	}

	//The first two digits of municipio_code_full refer to the state in which the municipio is in.
	//The last 5 digits of municipio_code_full refer to the actual municipio code. Importantly, a municipio's full geographic identifier must be 7 digits long.
	//For instance, if a state's state code is 43 and its municipio code is 34, the geographic identifier would be 4300034.
	//Thus if you search for 4334 in the IBGE database, it will say it found no municipio with that code.
	gen state_code = substr(municipio_code_full, 1, 2)
	gen municipio_code = substr(municipio_code_full, 3, 4)

	//Replacing "." and "," in population strings with blanks. This avoids language issues in terms of what "," and "." delimit in Portuguese vs. English.
	foreach v in totalpop urbanpop ruralpop{
		replace `v' = subinstr(`v',".","",.)
		replace `v' = subinstr(`v',",","",.)
	}

	//De-stringing variables
	foreach v in state_code municipio_code municipio_code_full totalpop urbanpop ruralpop{
		destring `v', force replace
	}

	save `tf`y''.dta, replace
}

//Appending municipio populations for each year into a single .dta file.
clear
foreach y in 1940 1950 1960 1970 1980 1991 2000 2010{
	append using `tf`y''.dta
}

//Ordering, sorting and labelling variables.
sort year state_code municipio_code
order year municipio_code_full state_code municipio_code municipio_name totalpop urbanpop ruralpop

label var year "Year"
label var municipio_code_full "Full 7-digit municipio code"
label var state_code "2-digit state code"
label var municipio_code "municipio code"
label var municipio_name "municipio name"
label var totalpop "Total municipio population"
label var urbanpop "Urban municipio population"
label var ruralpop "Rural municipio population"

//Final arrangements and saving.
compress
desc
label data "Brazilian municipio population (1940 - 2010)"
saveold "`saveas'.dta", replace
end

cap program drop municipio_geoid
program municipio_geoid
syntax, saveas(string)

tempfile tf1 tf1940 tf1950 tf1960 tf1970 tf1991 tf2000 tf2010

//We import the .xls file and not the .dta file because municipio names in the .dta files are incorrect (special characters are missing).
import excel using "../input/census_popmun_1872-2010.xls", clear firstrow
save `tf1'.dta, replace

//** LOADING AND CLEANING municipio POPULATION FROM 1940 TO 2010 **//
foreach y in 1940 1950 1960 1970 1980 1991 2000 2010{
	use `tf1'.dta, clear

	keep cod`y' Município`y' //Only keeping variables for the year in question.
	drop if missing(cod`y') //Only keeping municipios that were defined for the given year.
	gen year = `y' //Year identifier

	//Renaming variables.
	ren cod`y' municipio_code_full
	ren Município`y' municipio_name
	replace municipio_name = trim(municipio_name) //Removing leading and/or trailing blanks from municipio_name
	tostring municipio_code_full, force replace

	//The first two digits of municipio_code_full refer to the state in which the municipio is in.
	//The next 4 digits of municipio_code_full refer to the actual municipio code.
	//The last digit of municipio_code_full is an "identifier digit".
	//For instance, if a state's state code is 43 and its municipio code is 34, the full geographic identifier would be 4300034.
	gen state_code = substr(municipio_code_full, 1, 2)
	gen municipio_code = substr(municipio_code_full, 3, 4)
	gen identifier_digit = substr(municipio_code_full, 7, 1)

	//De-stringing variables
	foreach var in state_code municipio_code municipio_code_full identifier_digit {
		destring `var', replace force
	}

	save `tf`y''.dta, replace
}

//Appending municipio populations for each year into a single .dta file.
clear
foreach y in 1940 1950 1960 1970 1980 1991 2000 2010{
	append using `tf`y''.dta
}

//Ordering, sorting and labelling variables.
sort year state_code municipio_code
order year municipio_code_full state_code municipio_code identifier_digit municipio_name

label var year "Year"
label var municipio_code_full "7-digit municipio code"
label var state_code "2-digit state code"
label var municipio_code "municipio code"
label var municipio_name "municipio name"
label var identifier_digit "municipio identifier digit (last digit of full municipio code)"

//Final arrangements and saving.
compress
desc
label data "Brazilian municipios 7-digit geographic identifiers (1940-2010)"
saveold "`saveas'.dta", replace
end
