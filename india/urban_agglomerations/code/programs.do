//LOAD URBAN AGGLOMERATION SOURCE FILES
cap program drop urbanagglomerations_2011
program define urbanagglomerations_2011

//Identify the list of files that are "Primary Census Abstract - Urban Aglomeration Table"
global folder "../input/"
local myfilelist : dir "$folder" files "Primary*.xlsx", respectcase
display `myfilelist'
//Load them all
tempfile tf_UA_populations
foreach file of local myfilelist {
	qui import excel STCode DTCode SubDTCode TownCode UACode UAName No_HH TOT_P TOT_WORK_P using "$folder/`file'", clear
	//Append
	qui capture confirm file "`tf_UA_populations'"
	qui if (_rc==0) append using "`tf_UA_populations'"
	qui save "`tf_UA_populations'", replace
}
drop if STCode=="ST Code"
destring  UA* No_HH TOT_P TOT_WORK_P, replace
drop if missing(UACode)==1 & missing(STCode)==1 & missing(TOT_P)==1
rename (STCode) (StateCode)
save "`tf_UA_populations'", replace

//Produce file containing only UAs and their populations
use "`tf_UA_populations'", clear

keep if substr(UAName,-2,2)=="UA" & missing(TownCode)==1
replace UACode = UACode/100000
order UACode UAName No_HH TOT_P TOT_WORK_P StateCode DTCode SubDTCode
compress

label var	UACode "Urban Agglomeration code"
label var	UAName "Urban Agglomeration name"
label var	No_HH  "Number of Households"
label var 	TOT_P  "Total Population"
label var   TOT_WORK_P "Total Workers (Main+Marginal) Persons"
label var	StateCode "State code"
label var 	DTCode "District code"
label var   SubDTCode "Tahsil Code"

label data "Population information for Urban Agglomerations (2011)"

gen TownCode_v2 = StateCode + TownCode
drop TownCode
rename TownCode_v2 TownCode
duplicates drop
saveold "../output/UAs.dta", replace version(12)

//Produce file assigning cities (TownCode) to UAs
use "`tf_UA_populations'", clear

drop if substr(UAName,-2,2)=="UA" & missing(TownCode)==1
drop if missing(TownCode)==1
drop if UACode==900000000
rename (UAName) (TownName)
replace TownName = trim(TownName)
tempvar tv0 tv1
gsort StateCode TownCode -TOT_P
by StateCode TownCode: egen `tv0' = total(1)
by StateCode TownCode: gen `tv1' = _n if `tv0'!=1
drop if inrange(`tv0',2,.) & inrange(`tv1',2,`tv0')
drop `tv0' `tv1'
replace UACode = floor(UACode/100000)
compress

label var	TownCode "Town/Village code"
label var	TownName "Urban Agglomeration name"
label var	No_HH  "Number of Households"
label var 	TOT_P  "Total Population"
label var   TOT_WORK_P "Total Workers (Main+Marginal) Persons"
label var	StateCode "State code"
label var 	DTCode "District code"
label var   SubDTCode "Tahsil Code"
label var	UACode "Urban Agglomeration code"


gen TownCode_v2 = StateCode + TownCode
drop TownCode
rename TownCode_v2 TownCode

order TownCode TownName No_HH TOT_P TOT_WORK_P UACode StateCode DTCode SubDTCode

label data "Population information for towns belonging to Urban Agglomerations (2011)"

saveold "../output/Towns_thatbelongtoUAs.dta", replace version(12)

//Produce file containing cities (TownCode) not belonging to UAs that are sufficiently large that they have 50,000+ residents
use "`tf_UA_populations'", clear
drop if substr(UAName,-2,2)=="UA" & missing(TownCode)==1
drop if missing(TownCode)==1
keep if UACode==900000000 & inrange(TOT_P,50000,.)
replace UACode = floor(UACode/100000)
rename (UAName) (TownName)
replace TownName = trim(TownName)
compress

label var	TownCode "Town/Village code"
label var	TownName "Urban Agglomeration name"
label var	No_HH  "Number of Households"
label var 	TOT_P  "Total Population"
label var   TOT_WORK_P "Total Workers (Main+Marginal) Persons"
label var	StateCode "State code"
label var 	DTCode "District code"
label var   SubDTCode "Tahsil Code"
label var	UACode "Urban Agglomeration code"

gen TownCode_v2 = StateCode + TownCode
drop TownCode
rename TownCode_v2 TownCode

order TownCode TownName No_HH TOT_P TOT_WORK_P UACode StateCode DTCode SubDTCode

label data "Population information for towns not belonging to Urban Agglomerations (2011)"

saveold "../output/Towns_notbelongtoUAs.dta", replace version(12)

end
