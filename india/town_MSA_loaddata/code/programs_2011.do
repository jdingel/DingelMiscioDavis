cap program drop edu_labels_7_2011
program define edu_labels_7_2011
syntax, lblname(string)
label define `lblname' 1 "Illiterate", add
label define `lblname' 2 "Literate without education", add
label define `lblname' 3 "Literate but below matric/secondary", add
label define `lblname' 4 "Matric/secondary but below graduate" , add
label define `lblname' 5 "Diploma not equal to degree", add
label define `lblname' 6 "Graduate and above other than technical degree", add
label define `lblname' 7 "Technical degree or diploma equal to degree or post-graduate degree", add
end


cap program drop edu_town_count7_2011
program define edu_town_count7_2011

syntax using/, saveas_B9(string) saveas_sample(string)

//Load raw data
import excel "`using'", cellrange(A8) clear

rename (B C D E F G H I S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM) (state_code town_code area_name urban edu main_workers worker_male worker_female A25to29 A25to29_M A25to29_F A30to34 A30to34_M A30to34_F A35to39 A35to39_M A35to39_F A40to49 A40to49_M A40to49_F A50to59 A50to59_M A50to59_F A60to69 A60to69_M A60to69_F A70Plus A70Plus_M A70Plus_F)

keep (state_code town_code area_name urban edu main_workers worker_male worker_female A25to29 A25to29_M A25to29_F A30to34 A30to34_M A30to34_F A35to39 A35to39_M A35to39_F A40to49 A40to49_M A40to49_F A50to59 A50to59_M A50to59_F A60to69 A60to69_M A60to69_F A70Plus A70Plus_M A70Plus_F)

drop if missing(state_code) & missing(town_code) & missing(edu) //Drop footer

label data "Number of workers in each of 7 education categories, by town (2011)"

label var	state_code "State code"
label var	town_code "Town code"
label var	area_name "Area name"
label var	urban "Discrete variable classifying observation as part of total, rural, or urban"
label var 	edu "Education level"
label var	main_workers	"Main workers"
label var	worker_male	"Main workers male"
label var	worker_female	"Main workers female"
label var	A25to29	"Workers 25 to 29"
label var	A25to29_M	"Workers 25 to 29 male"
label var	A25to29_F	"Workers 25 to 29 female"
label var	A30to34	"Workers 30 to 34"
label var	A30to34_M	"Workers 30 to 34 male"
label var	A30to34_F	"Workers 30 to 34 female"
label var	A35to39	"Workers 35 to 39"
label var	A35to39_M	"Workers 35 to 39 male"
label var	A35to39_F	"Workers 35 to 39 female"
label var	A40to49	"Workers 40 to 49"
label var	A40to49_M	"Workers 40 to 49 male"
label var	A40to49_F	"Workers 40 to 49 female"
label var	A50to59	"Workers 50 to 59"
label var	A50to59_M	"Workers 50 to 59 male"
label var	A50to59_F	"Workers 50 to 59 female"
label var	A60to69	"Workers 60 to 69"
label var	A60to69_M	"Workers 60 to 69 male"
label var	A60to69_F	"Workers 60 to 69 female"
label var	A70Plus	"Workers 70+"
label var	A70Plus_M	"Workers 70+ male"
label var	A70Plus_F	"Workers 70+ female"

//Confirm that file is balanced
tempvar state_town_concat
egen `state_town_concat' = group(state_code town_code)
qui fillin `state_town_concat' edu
qui count if _fillin==1
if (`r(N)'!=0) error 416
else drop _fillin `state_town_concat'

//Save normalized file before imposing sample restrictions
compress
desc
saveold "`saveas_B9'", replace $saveoldversion

//Restrict sample to urban population and keep labor-force participants over age 25
keep if urban=="Urban"
gen A25to59 = A25to29 + A30to34 + A35to39 + A40to49 + A50to59
keep state_code town_code area_name edu A25to59

//"Literate without education" is a residual category that we create
drop if edu=="Total"
bys state_code town_code: egen literate_total = max(A25to59*(edu=="Literate"))
by  state_code town_code: egen educated_total = total(A25to59*(edu!="Literate" & edu!="Total" & edu!="Illiterate"))
replace edu = "Literate without education" if edu=="Literate"
replace A25to59 = literate_total - educated_total if edu== "Literate without education"
drop literate_total educated_total

//Create numeric ordered schooling variable and label it //Shouldn't an "encode" command do this?
rename edu edu_string
gen     edu = 1 if edu_string=="Illiterate"
replace edu = 2 if edu_string=="Literate without education"
replace edu = 3 if edu_string=="Literate but below matric/secondary"
replace edu = 4 if edu_string=="Matric/secondary but below graduate"
replace edu = 5 if edu_string=="Technical diploma or certificate not equal to degree"
replace edu = 6 if edu_string=="Graduate and above other than technical degree"
replace edu = 7 if edu_string=="Technical degree or diploma equal to degree or post-graduate degree"
edu_labels_7_2011, lblname(edu_labels)
label values edu edu_labels
drop edu_string

//Generate TownCode, label variables, save
gen TownCode = state_code + town_code
order TownCode area_name edu A25to59

label data "Number of workers in each of 7 education categories for age 25-59, by town (2011)"
label var TownCode  "Unique town identifier (digits 1-2 state code and digits 3-8 town code)"
label var area_name "Area name"
label var edu       "Education level"
label var A25to59   "Workers age 25 to 59"
compress
desc
saveold "`saveas_sample'", replace $saveoldversion

end



//EDUCATION WORKERS- 4 GROUPS
cap program drop edu_town_count4_2011
program define edu_town_count4_2011

syntax using/, saveas(string)

use "`using'", clear
gen edu2 = edu
recode edu2 1=1 2=1 3=2 4=3 5=3 6=4 7=4
label define edu2_aggregated_categories 1 "No education" 2 "Primary" 3 "Secondary" 4 "College graduate"
label values edu2 edu2_aggregated_categories

collapse (sum) A25to59, by(TownCode area_name edu2)

label data "Number of workers in each of 4 education categories for age 25-59, by town (2011)"

label var	TownCode "Unique town identification- first 2 numbers are the state code and next 8 numbers are the town code "
label var	area_name "Area name"
label var 	edu "Education level (collapsed 4 scheme)"
label var	A25to59	"Workers age 25 to 59"

rename edu2 edu
compress
desc
saveold "`saveas'", replace $saveoldversion
end


//EDUCATION TOTAL POPULATION- 9 GROUPS
cap program drop edu_labels_9_2011
program define edu_labels_9_2011

syntax, lblname(string)
label define `lblname'	1	"Iliterate " 	,add
label define `lblname'	2	"Literate without education level  " 	,add
label define `lblname'	3	"Below primary  " 	,add
label define `lblname'	4	"Primary  " 	,add
label define `lblname'	5	"Middle  " 	,add
label define `lblname'	6	"Secondary  " 	,add
label define `lblname'	7	"Higher secondary  " 	,add
label define `lblname'	8	"Diploma not equal to degree" 	,add
label define `lblname'	10	"Graduate and above " 	,add  //JD: Kevin, why is this ten?

end


cap program drop edu_totalPop_9_2011
program define edu_totalPop_9_2011
syntax using/, saveas(string)

//Load raw data
import excel "`using'", cellrange(A8) clear

rename (B C D E F G H I J M P S V Y AB AE AH AK AN) (state_code town_code area_name urban age total total_male total_female illiterate literate literate_no_edu below_primary primary middle secondary higher_secondary non_technical_dipl technical_dipl graduate_above)

keep state_code town_code urban area_name age total total_male total_female illiterate literate literate_no_edu below_primary primary middle secondary higher_secondary non_technical_dipl technical_dipl graduate_above

label data "Number of individuals (entire population) in each of 10 education categories, by town (2011)"

label var	state_code "State code"
label var	town_code "Town code"
label var	area_name "Area name"
label var	urban "Discrete variable classifying observation as part of total, rural, or urban"
label var 	age "Age"
label var	total	"Total population"
label var	total_male	"Total male population"
label var	total_female	"Total female population"
label var	illiterate	"Illiterate"
label var	literate	"Literate"
label var	literate_no_edu	"Literate without education level"
label var	below_primary	"Below primary"
label var	primary	"Primary"
label var	middle	"Middle"
label var	secondary	"Matric/Secondary"
label var	higher_secondary	"Higher secondary/Intermediate/Pre-University/Senior secondary"
label var	non_technical_dipl	"Non-technical diploma or certificate not equal to degree"
label var	technical_dipl	"Technical diploma or certificate not equal to degree "
label var	graduate_above	"Graduate & above"

compress
desc
saveold "../output/all_India_series_C8City_2011.dta", replace $saveoldversion

use "../output/all_India_series_C8City_2011.dta", clear

//restrict sample to urban population and keep Labor-force participants over age 25
keep if urban=="Urban"
drop urban

drop if age=="All ages"|age=="Age not stated"
drop if age=="0-6"|age=="7"|age=="8"|age=="9"|age=="10"|age=="11"|age=="12"|age=="13"|age=="14"|age=="15"|age=="16"|age=="17"|age=="18"|age=="19"|age=="20-24"
drop if age=="70-74"|age=="75-79"|age=="80+"

keep state_code town_code area_name  illiterate- graduate_above

foreach var of varlist illiterate- graduate_above {
	bysort state_code  town_code:  egen `var'_C = sum(`var')
}

keep state_code town_code illiterate_C - graduate_above_C

quietly bysort state_code town_code:  gen dup = cond(_N==1,0,_n)

keep if dup==1 | dup==0

foreach var of varlist illiterate_C - graduate_above_C {
	local newname = substr("`var'",1,strpos("`var'","_C")-1)
	rename `var' `newname'
}

drop literate //literate is the sum of the rest of the edu lab

rename 	illiterate	edu1
rename 	literate_no_edu	edu2
rename 	below_primary	edu3
rename 	primary	edu4
rename 	middle	edu5
rename 	secondary	edu6
rename 	higher_secondary	edu7
rename 	non_technical_dipl	edu8
rename 	technical_dipl	edu9
rename 	graduate_above	edu10

reshape long edu, i(state_code town_code) j(edu_level)

edu_labels_9_2011, lblname(name)
label values edu_level name

drop dup
rename edu A25to59
rename edu_level edu

//already in string format so no need to convert
gen TownCode = state_code + town_code

gen no_diploma = A25to59 if edu==8 | edu==9
bysort TownCode: egen no_diploma_n = total(no_diploma)
replace A25to59 = no_diploma_n if edu==8

recode edu 9=8
collapse (sum) A25to59, by(TownCode edu)
edu_labels_9_2011, lblname(name2)
label values edu name2

order TownCode edu A25to59

keep TownCode edu A25to59

label data "Number of workers in each of 9 education categories for age 25-59, by town (2011)"

label var	TownCode "Unique town identification- first 2 numbers are the state code and next 6 numbers are the town code "
label var 	edu "Education level"
label var	A25to59	"Total population age 25 to 59"

compress
desc
saveold "`saveas'", replace $saveoldversion

end

//EDUCATION TOTAL POPULATION- 4 GROUPS
cap program drop edu_totalPop_4_2011
program define edu_totalPop_4_2011
syntax using/, saveas(string)

use "`using'", clear

gen edu2 = edu
recode edu2 1=1 2=2 3=2 4=2 5=3 6=3 7=3 8=4 9=4 10=4
label define edu2_aggregated_categories 1 "Iliterate" 2 "Primary" 3 "Middle and secondary" 4 "Certificate and college diploma"
label values edu2 edu2_aggregated_categories

collapse (sum) A25to59, by(TownCode edu2)

label data "Number of people in each of 4 education categories for age 25-59, by town (2011)"

label var	TownCode "Unique town identification- first 2 numbers are the state code and next 6 numbers are the town code "
label var 	edu "Education level (collapsed 4 scheme)"
label var	A25to59	"Total population age 25 to 59"

rename edu2 edu
compress
desc
saveold "`saveas'", replace $saveoldversion

end
