
//This program calculates occupational employment by municipio from 2000 to 2014.
cap program drop occpop_Census
program define occpop_Census
syntax, saveas(string) minage(integer) maxage(integer) formal(integer) raisformal(integer)

capture erase "`saveas'.dta" //Deleting the output file if it already exists.
use "../input/CENSO10_pes.dta",clear
rename (v6400 v6461 v6930 v6036 v0010 v6910) (edu occupation emp_status age sampling_weight occupied)
keep if occupied == 1
rename (munic) (municipio6)
keep if (inrange(age,`minage',`maxage') & !missing(occupation))
if (`formal' == 1) 		drop if emp_status == 3 //Dropping workers in informal sector.
if (`raisformal' == 1) 	drop if emp_status >= 3
gen sch = edu
recode sch 1=6 2=10 3=14 4=18
gen tot_sch = sch*sampling_weight //Scaling schooling variable by person weights before summation, below.
collapse (first) edu emp_status (sum) occpop = sampling_weight sch = tot_sch, by(municipio6 occupation)
gen state_code  = floor(municipio6/10000) 				if inrange(municipio6,110001,530010) //Digits 1-2
gen municipio_code = floor((municipio6-state_code*10000))	if inrange(municipio6,110001,530010) //Digits 3-6
//Generating more aggregate occupational categories
gen greatocc = floor(occupation/1000)
label define lblname_greatocc 0 "Military and police force" 1 "Managers and directors" ///
	2 "Scientists and intelectuals" 3 "Intermediary-level technicians" 4 "Administrative services" ///
	5 "Service & Commerce" 6 "Agriculture" 7 "Construction/Mechanical Services" ///
	8 "Machine operators" 9 "Maintenance and repair", replace
label values greatocc lblname_greatocc

decode greatocc, gen(greatocc_temp)
drop greatocc
rename greatocc_temp greatocc

//Ordering, sorting and labelling variables for cleanliness of output.
order state_code municipio_code municipio6 greatocc occupation occpop
sort  state_code municipio_code municipio6 greatocc occupation
label var state_code  "State"
label var municipio_code "Municipio"
label var greatocc    "Great occupational category"
label var occupation  "Occupational category"
label var occpop      "Occupational employment category population"
label var sch         "Total years of schooling at municipio-greatocc level"
label var edu 		  "Educational attainment level"
label var emp_status  "Position held in the occupation of the main job"

compress
desc
label data "Occupational employment in Brazil by municipio. Source: 2010 Census."
saveold "`saveas'.dta", replace

end

//This program calculates educational group counts by municipio from 2000 to 2014.
cap program drop edupop_Census
program define edupop_Census
syntax, saveas(string) minage(integer) maxage(integer)

capture erase "`saveas'.dta" //Deleting the output file if it already exists.
use "../input/CENSO10_pes.dta",clear
ren (v0010 v6036 v6400) (sampling_weight age educ)
keep if inrange(age,`minage',`maxage')
collapse (sum) sampling_weight, by(munic educ)
tostring munic, replace
gen state_code = substr(munic, 1, 2)
gen municipio_code = substr(munic, 3, 4)
destring municipio_code state_code, replace
rename sampling_weight edupop
recode educ (1 = 1 "No schooling") (2 = 2 "Elementary Graduate") (3 = 3 "High School Graduate") (4 = 4 "College Graduate") (5 = 5 "Undetermined"), gen(edu)
drop educ
rename (munic) (municipio6)
destring municipio6, replace

//Ordering, sorting and labelling variables for cleanliness of output.
order state_code municipio_code edu
sort state_code municipio_code
label var state_code "State code"
label var municipio_code "municipio code"
label var edu "Educational attainment level"
compress
desc
label data "Educational group populations in Brazil by municipio. Source: 2010 Census."
saveold "`saveas'.dta", replace

end


//This program calculates industrial group counts by municipio from 2000 to 2014.
cap program drop indpop_Census
program define indpop_Census
syntax, saveas(string) minage(integer) maxage(integer) formal(integer) raisformal(integer)

capture erase "`saveas'.dta" //Deleting the output file if it already exists.
use "../input/CENSO10_pes.dta",clear

ren (v0010 v6910 v6036 v6471 v6930 v6400) (sampling_weight occupied age industry emp_status edu)
keep if occupied == 1 // occupied
keep if inrange(age,`minage',`maxage')
drop if missing(industry) //People without an associated occupation.
if (`formal' == 1) drop if emp_status == 3 //Dropping workers in informal sector.
if (`raisformal' == 1) drop if emp_status >= 3
gen sch = edu
recode sch 1=6 2=10 3=14 4=18
gen tot_sch = sch*sampling_weight
collapse (first) emp_status edu (sum) tot_sch sampling_weight, by(munic industry)
tostring munic, replace
gen state_code = substr(munic, 1, 2)
gen municipio_code = substr(munic, 3, 4)
destring municipio_code state_code, replace
rename (tot_sch sampling_weight) (sch indpop)

//Creating great industrial groups as per CNAE definitions.
gen greatind = "Ill-defined Activities"
replace greatind = "Agriculture" if industry > 0
replace greatind = "Extractive Industries" if industry >= 5000
replace greatind = "Transformation Industries" if industry >= 10000
replace greatind = "Electricity and gas" if industry >= 35000
replace greatind = "Sanitation" if industry >= 36000
replace greatind = "Construction" if industry >= 41000
replace greatind = "Commerce" if industry >= 45000
replace greatind = "Transportation" if industry >= 49000
replace greatind = "Hospitality and Food Services" if industry >= 55000
replace greatind = "Information & Communication" if industry >= 58000
replace greatind = "Finance" if industry >= 64000
replace greatind = "Real Estate" if industry >= 68000
replace greatind = "Science & Technical Professions" if industry >= 69000
replace greatind = "Administrative Services" if industry >= 77000
replace greatind = "Public Administration" if industry >= 84000
replace greatind = "Education" if industry >= 85000
replace greatind = "Health & Social Services" if industry >= 86000
replace greatind = "Arts, Culture & Sports" if industry >= 90000
replace greatind = "Other services activities" if industry >= 94000
replace greatind = "Domestic services" if industry >= 97000
replace greatind = "International institutions" if industry >= 99000

//drop munic
rename (munic) (municipio6)
destring municipio6, replace

//Ordering, sorting and labelling variables for cleanliness of output.
order state municipio_code industry indpop
sort state municipio_code industry
label var state_code 	"State"
label var municipio_code 	"Municipio"
label var industry 		"Industrial category"
label var indpop 		"Industrial category population"
label var greatind 		"Great industrial category"
label var sch         	"Total years of schooling at municipio-greatind level"
label var edu 		  	"Educational attainment level"
label var emp_status  	"Position held in the occupation of the main job"
compress
desc
label data "Industrial group populations in Brazil by municipio. Source: 2010 Census."
saveold "`saveas'.dta", replace

end

cap program drop empskill_census
program define empskill_census
syntax, emp(string) using(string) saveas(string)
tempfile tf1
use "`using'", clear
collapse (sum) `emp'pop sch, by(great`emp') //This computes the total employment population and total years of schooling for each employment category.
gen skillintensity = sch/`emp'pop
egen rankskill = rank(skillintensity)
sort rankskill
drop if missing(great`emp')
keep great`emp' skillintensity rankskill
//rename great`emp' `emp'
gen `emp' =  great`emp'
compress
saveold "`saveas'", replace
end

//This program calculates education-cohort group counts by municipio from 2000 to 2014.
cap program drop agepop_Census
program define agepop_Census
syntax, saveas(string) minage(integer) maxage(integer)

capture erase "`saveas'.dta" //Deleting the output file if it already exists.
use "../input/CENSO10_pes.dta",clear

ren (v0010 v6036 v6400) (sampling_weight age educ)
keep if inrange(age,`minage',`maxage')
gen agebin=.
local step=9
local start=`minage'
forval c=1/3 { // 3 cohorts: 25-34; 35-44; 45-54
	replace agebin=`c' if inrange(age,`start'+(`step'+1)*(`c'-1),`start'+(`step'+1)*(`c'-1)+`step')
}
assert agebin==. if !inrange(age,25,54)
assert agebin!=. if inrange(age,25,54)
drop if agebin==.
collapse (sum) sampling_weight, by(munic educ agebin)
tostring munic, replace
gen state_code = substr(munic, 1, 2)
gen municipio_code = substr(munic, 3, 4)
destring municipio_code state_code, replace
rename sampling_weight edupop
recode educ (1 = 1 "No schooling") (2 = 2 "Elementary Graduate") (3 = 3 "High School Graduate") (4 = 4 "College Graduate") (5 = 5 "Undetermined"), gen(edu)
drop educ
recode agebin (1 = 1 "25-34") (2 = 2 "35-44") (3 = 3 "45-54"), gen(cohort)
drop agebin
rename (munic) (municipio6)
destring municipio6, replace

//Ordering, sorting and labelling variables for cleanliness of output.
order state_code municipio_code edu
sort state_code municipio_code
label var state_code "State code"
label var municipio_code "municipio code"
label var edu "Educational attainment level"
label var cohort "Age cohort bin recoded"
compress
desc
label data "Age-Education cell populations in Brazil by municipio. Source: 2010 Census."
saveold "`saveas'.dta", replace

end
