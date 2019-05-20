////////////////////////////////////////////////////////////////////////////////////////////////////
// Program to create a normalized file at the Town level
////////////////////////////////////////////////////////////////////////////////////////////////////

cap program drop normalized_towns
program define normalized_towns

syntax, saveas(string)

// Stack all files from the Town directory and save in tempfile
tempfile temp_town_directory
global folder "../input"
local list_files: dir "$folder" files "Town*.xls", respectcase
foreach file of local list_files {
	display "`file'"
	qui import excel "${folder}/`file'", sheet("Sheet1") firstrow allstring clear
	keep *CODE TOWN_NAME CLASS C_STATUS POP_2001
	destring *CODE POP_2001, replace ignore(NA-.$)
	drop if TOWN_CODE==.
	replace TOWN_NAME = trim(TOWN_NAME)
	replace CLASS = trim(CLASS)
	replace C_STATUS = trim(C_STATUS)
	compress

	qui capture confirm file "`temp_town_directory'"
	qui if (_rc==0) append using "`temp_town_directory'"
	qui saveold "`temp_town_directory'", replace $saveoldversion
	drop if TOWN_NAME=="Vijayawada (Part) **"	// This row in Andra Pradesh should not be there. It only says that this entry is included in Vijayawada and doesn't contain any other data.
}
gen TownCode = string(ST_CODE,"%02.0f") + string(TOWN_CODE,"%8.0f")
replace TOWN_NAME = trim(TOWN_NAME)
replace TOWN_NAME = proper(TOWN_NAME)
rename (POP_2001 TOWN_NAME ST_CODE DIST_CODE THSIL_CODE BLOCK_CODE) (population TownName StateCode DistrictCode TehsilCode BlockCode)
drop TOWN_CODE
duplicates drop
save `temp_town_directory', replace

// Stack all files from the "Primary Census Abstract - Urban Agglomerations" and save in tempfile
/* These files contain the mapping between Towns and Urban Agglomerations, for UA that consist of
	more than one Town (or one Town plus some Out Growths). This lists contains all sizes of UA.
	To obtain the list of all MSAs above a given population threshold we must
	add the Towns that are not part of an UA but alone have a population above the desired threshold.
	By construction, these UA cannot cross state boundaries. If in reality they do, then they have
	a different code. */

global myfolder "../input"
tempfile pca_urbanagg
local list_files: dir "$myfolder" files "PCA*.csv", respectcase
foreach file of local list_files {
	display "`file'"

	insheet using "$myfolder/`file'", clear
	keep state district subdistt uacode towncode level name city_file tot_p mainwork_p
	tostring *, replace

	gen line = _n	// line no. within state file

	qui capture confirm file "`pca_urbanagg'"
	qui if (_rc==0) append using "`pca_urbanagg'"
	qui save "`pca_urbanagg'", replace
}
foreach x of varlist * {
	capture replace `x' = trim(`x')
}
rename (state tot_p mainwork_p city_file) (StateCode population workforce temp_city_file)
destring *, replace
gen byte city_file = (temp_city_file=="y")
drop temp_city_file

/* Rules to assign code to urban agglomerations (deduced by observing code pattern in Primary Census Abstract, Urban Agglomeration files)
- 8 digit, of which the first digit is 5
- next 3 digits = sequential number assigned to UA within a State (often but not always sorted from large to small)
- next 2 digits = sequential number assigned to a 1st level of UA constituents
- next 2 digits = sequential number assigned to a 2nd level of UA constituents (i.e. those that form a partition of a 1st level constituent)

==> an Urban agglomeration can cross District boundaries but not State boundaries
==> the UA-level code has zeros in the last 4 digits (i.e. it's the sum of all its 1st level constituents, we make use of this to create a new code for urban agglomerations that is unique in the country, as opposed to unique in the state: UrbAggCode)
==> a 1st level constituent has zeros in the last 2 digits
*/

tostring uacode, gen(temp_uacode)
gen UrbAggCode = string(StateCode,"%02.0f") + substr(temp_uacode,1,4)
gen TownCode = string(StateCode,"%02.0f") + string(towncode,"%08.0f") if towncode!=.

// Special handling of Delhi: for some reason its urban agglomeration components don't have a code in the PCA files, but they do in the town directory and city files.
replace TownCode="074" + string(district,"%02.0f") + "01000" if regex(name,"N.D.M.C.")==1 & TownCode=="" & district!=0
replace TownCode="0740802000" if regex(name,"Delhi Cant")==1 & TownCode==""
replace TownCode="074" + string(district,"%02.0f") + "03000" if regex(name,"DMC")==1 & TownCode=="" &  district!=0
// Special handling of Siliguri: the town directory lists 2 components but for one of them it says population = 0 because it's been added to the other component; the city files have 2 separate entries for the components of Siliguri + another entry for its total; the urban agglomeration mapping doesn't list Siliguri (consistent with population in one constituent being zero).
// Here, we keep the town directory as the reference, hence we treat Siliguri as having 2 entries. Since the urban agglomeration mapping doesn't feature Siliguri, I added the entry to the xls and csv urban agglomeration file of West Bengal.

// Cosmetics
label variable city_file "y = this spatial unit is available in the tables by city"
label variable uacode "8 digit Urban Aggregation code from Census, unique within a State"
label variable population "resident population as of Census 2001 (including Out Growths)"
label variable workforce "main workforce (i.e. not marginal workers)"

compress
save `pca_urbanagg', replace

////////////////////////////////////////////////////////////////////////////////////////////////////
// Save a clean mapping from Towns to Urban Agglomerations
////////////////////////////////////////////////////////////////////////////////////////////////////

use `pca_urbanagg', replace
drop if (level=="U.A." | level=="OG" | substr(name,-3,2)=="OG")
drop if TownCode==""	// this is to drop obs corresponding to town headers such as "City A (M + OG)" (i.e. municipal corporation plus outgrowths) and towns that require special handling.
keep UrbAggCode TownCode population

// Cosmetics
compress
rename population population_town_no_OG	// we save this because this is the actual population in the section of the town observed in city files, the town directory instead reports a population that includes the outgrowths, but the outgrowths are not observed in the "city" files so we would be overstating the observed city population if we were to use the town directory.
label variable TownCode "state code (2-digits) + town code (8-digits), Census 2001 classification"
label variable UrbAggCode "state code + 1st 4 digits of Urban Agglom. code found in Primary Census Abstract"
label variable population_town_no_OG "population in Town (excluding Out Growths, unlike in Town Directory)"
label data "Mapping Towns to Urban Agglomerations. UA can't cross state boundaries."
order TownCode UrbAggCode population_town_no_OG
duplicates drop
saveold "../output/mapping_towns_urban_agglomerations_2001_within.dta", replace $saveoldversion

// Save names and combined population of Urban Agglomerations for later use
use `pca_urbanagg', replace
keep if level=="U.A."
keep UrbAggCode population name
rename (population name) (population_UA UrbAggName)
compress
label variable population_UA "total population of urban agglomeration (Census 01)"
duplicates drop
saveold "../output/urban_agglomerations_2001_within.dta", replace $saveoldversion


////////////////////////////////////////////////////////////////////////////////////////////////////
// For selected Towns, save a mapping from Towns to Urban Agglomerations that cross state boundaries.
////////////////////////////////////////////////////////////////////////////////////////////////////
use `temp_town_directory', clear
merge 1:1 TownCode using "../output/mapping_towns_urban_agglomerations_2001_within.dta", nogen keepusing(UrbAggCode)
gen GEOKEY = string(StateCode,"%02.0f") + string(DistrictCode,"%02.0f") + string(TehsilCode,"%04.0f")
merge m:1 GEOKEY using "../input/India_subdistricts_2001.dta", keep(master match) keepusing(msa20 msa30 msa40) nogen

drop if TehsilCode==0 & msa20!=""  //We are only merging observations on the basis of subdistrict overlap with nightlight polygons

//Both Chandigarh Tricity & Delhi span multiple states
tempvar tv1 tv2
egen `tv1' = tag(msa20 StateCode)
bys msa20: egen `tv2' = total(`tv1')
gen multistate20 = inrange(`tv2',2,.)


bys UrbAggCode: egen UAelement_multistate = max(multistate20) if missing(UrbAggCode)==0
keep if multistate20 == 1 | UAelement_multistate == 1 //Retain elements that are (1) identified by a subdistrict that has been assigned to a tri-state MSA or (2) identified by an Urban Agglomeration that has had a component asssigned to a tri-state MSA

//Chandigarh Tricity: A single MSA spans three states
bys msa20: egen UrbAggCode_unassigned20 = min(missing(UrbAggCode)==1) if inrange(population,100000,.)
tab msa20 if multistate20==1 & UrbAggCode_unassigned20==1
gen str UrbAggCode_cross = msa20 if multistate20==1 & UrbAggCode_unassigned20==1

//Delhi: A collection of UAs and Towns that spans three states [but we don't have Delhi subdistricts! so not assigned to polygons]
bys UrbAggCode: egen msa20mode = mode(msa20) if UAelement_multistate==1
replace UrbAggCode_cross = msa20 if multistate20==1 & missing(UrbAggCode_cross)==1
replace UrbAggCode_cross = msa20mode if UAelement_multistate==1 & missing(UrbAggCode_cross)==1

tempvar tv3 tv4
egen `tv3' = tag(UrbAggCode_cross StateCode)
bys UrbAggCode_cross: egen `tv4' = total(`tv3')
gen multistate_UA_20 = inrange(`tv4',2,.)

keep if multistate_UA_20==1

keep TownCode UrbAggCode_cross population
replace UrbAggCode_cross = substr(UrbAggCode_cross,2,length(UrbAggCode_cross)-1) if substr(UrbAggCode_cross,1,1)=="9" & length(UrbAggCode_cross)==9
gen UrbAggName_cross = ""
replace UrbAggName_cross = "Greater Delhi" if UrbAggCode_cross=="07010002"
replace UrbAggName_cross = "Chandigarh Tricity" if UrbAggCode_cross=="04010001"

label variable TownCode "state code (2-digits) + town code (8-digits), Census 2001 classification"
label variable UrbAggCode_cross "a unique code for Urban Agglomerations that cross state boundaries"
tempfile tf0
save `tf0', replace

use `tf0', clear
drop population
label data "Mapping selected Towns to Urban Agglomerations that cross state boundaries."
saveold "../output/mapping_towns_urban_agglomerations_2001_cross.dta", replace

use `tf0', clear
collapse (sum) population_UA_cross = population (firstnm) UrbAggName_cross, by(UrbAggCode_cross)
label variable population_UA_cross "total population of urban agglomeration (Census 2001)"
saveold "../output/urban_agglomerations_2001_cross.dta", replace


////////////////////////////////////////////////////////////////////////////////////////////////////
// Prepare tempfile with list of towns (or town components) for which we have town-level data (i.e. the folders with "city" in the foldername)
////////////////////////////////////////////////////////////////////////////////////////////////////

/* Warnings:
For the following towns we have both the town total and town components in the city files: treat carefully to avoid double counting.
- Delhi Municipal Corporation (DMC) 9 parts + 1 total
- Greater Mumbai Municipal Corporation 2 parts + 1 total
- Hyderabad Municipal Corporation 2 parts + 1 total
- Imphal 2 parts + 1 total
- New Delhi Municipal Council (N.D.M.C.) 4 parts + 1 total
- Siliguri Municipal Corporation 2 parts + 1 total

We use table "B9 City - India" as the reference because it's clean and comprehensive.
Instead, tables "B4 City" and "B24 City" have only files by State. In addition B24 has a missing town (Gondiya, Maharashtra), and duplicate entries for Jaipur (Rajasthan), Kochi (Kerala), Delhi Cantt (Delhi), Korba (Chhattisgarh), Bilaspur (Chhattisgarh). For these towns we have duplicates under the same town name, and additional duplicates under with the "Part" suffix in the town name.

After cleaning, B9 city and B4 city have 443 towns. B24 city has 442 towns.
*/

tempfile temp_city_files
import excel StateCode = B DistrictCode = C temp_TownCode = D TownName = F using "../input/B_9_City_india.xls", sheet("Sheet2") cellrange(B8:F3551) clear
duplicates drop
gen TownCode = StateCode + temp_TownCode
gen byte city_file = 1
keep TownName TownCode city_file
replace TownName= trim(TownName)
compress
save `temp_city_files', replace


// Merge town directory with mapping towns-to-urban-agglomerations + list of towns with town-level data
use `temp_town_directory', replace
merge 1:1 TownCode using "../output/mapping_towns_urban_agglomerations_2001_within.dta", gen(merge_ua_within)
tab merge_ua_within	// merge 1 = 3993 towns not part of an urban agglomeration (for UA that don't cross state boundaries), merge 2 = one partition of Greater Mumbai with its own code (we keep it because the town directory only lists one of the two parts, but the city data provides the two components separately, we need both), merge 3 = 1185 towns that are part of a larger urban agglomeration.
replace TownName = "Greater Mumbai (Part)" if TownCode=="2742201000" | TownCode=="2742301000"

merge 1:1 TownCode using "../output/mapping_towns_urban_agglomerations_2001_cross.dta", gen(merge_ua_cross) keepusing(UrbAggCode_cross)

merge 1:1 TownCode using `temp_city_files', gen(merge_city) keepusing(city_file)
tab merge_city	// merge 1 = 4742 towns that are not available in the "city" files because they have a population of less than 100k; merge 2 = six entries for which we have a town total as well as town components in the city data; merge 3 = 437 matched towns. To recap, of the 443 towns in the "city" data, 437 are matched and 6 are dropped to avoid double counting.
drop if merge_city==2	// drop to avoid double counting in the following towns: New Delhi Municipal Corporation, Delhi Municipal Corporation, Imphal, Siliguri, Greater Mumbai, Hyderabad.

replace population = 0 if population==.	// this should only affect 2 observations (one portion of Greater Mumbai - more info in comments to "tab merge_city"; one portion of Siliguri for which we have a separate entry in the town directory, but whose population is included in the other portion).
replace population_town_no_OG = population if population_town_no_OG==.

// Generate a single variable to facilitate aggregation from towns to MSAs
gen MSACode_within = UrbAggCode if UrbAggCode!=""
replace MSACode_within = TownCode if UrbAggCode==""

// Special handling of MSAs that cross state boundaries
clonevar MSACode = MSACode_within
replace MSACode = UrbAggCode_cross if UrbAggCode_cross!=""

// Cosmetics and save
label variable population "resident population as of Census 2001 (including Out Growths)"
label variable TownCode "state code (2-digits) + town code (8-digits), Census 2001 classification"
label variable CLASS "I: pop > 100k, II: 50k-100k, III: 20k-50k, etc."
label variable city_file "y = this spatial unit is available in the tables by city"
label variable MSACode_within "For towns inside an Urban Agglomeration it's UrbAggCode, otherwise it's TownCode"
label variable MSACode "same as MSACode_within, but MSAs are allowed to cross state boundaries"

capture label drop StateCode
label define StateCode 1 "Jammu & Kashmir"
label define StateCode 2 "Himachal Pradesh", add
label define StateCode 3 "Punjab", add
label define StateCode 4 "Chandigarh", add
label define StateCode 5 "Uttaranchal", add
label define StateCode 6 "Haryana", add
label define StateCode 7 "Delhi", add
label define StateCode 8 "Rajasthan", add
label define StateCode 9 "Uttar Pradesh", add
label define StateCode 10 "Bihar", add
label define StateCode 11 "Sikkim", add
label define StateCode 12 "Arunachal Pradesh", add
label define StateCode 13 "Nagaland", add
label define StateCode 14 "Manipur", add
label define StateCode 15 "Mizoram", add
label define StateCode 16 "Tripura", add
label define StateCode 17 "Meghalaya", add
label define StateCode 18 "Assam", add
label define StateCode 19 "West Bengal", add
label define StateCode 20 "Jharkhand", add
label define StateCode 21 "Orissa", add
label define StateCode 22 "Chhatisgarh", add
label define StateCode 23 "Madhya Pradesh", add
label define StateCode 24 "Gujarat", add
label define StateCode 25 "Daman & Diu", add
label define StateCode 26 "Dadra & Nagar Haveli", add
label define StateCode 27 "Maharashtra", add
label define StateCode 28 "Andhra Pradesh", add
label define StateCode 29 "Karnataka", add
label define StateCode 30 "Goa", add
label define StateCode 31 "Lakshadweep", add
label define StateCode 32 "Kerala", add
label define StateCode 33 "Tamil Nadu", add
label define StateCode 34 "Pondicherry", add
label define StateCode 35 "Andaman & Nicobar Island", add
label value StateCode StateCode

order TownCode TownName StateCode DistrictCode TehsilCode BlockCode population*, first

// add a district identifier to match the district_pop.dta msavarnormfile
gen str2 district_string = string(DistrictCode,"%02.0f")
gen str2 state_string = string(StateCode,"%02.0f")
gen district_code = state_string + district_string

label var district_code "First two numbers are state code second two numbers are district code"

order *merge*, last
compress
desc
label data "Normalized file with data at the Town level from Population Census 2001"

saveold "`saveas'", replace $saveoldversion

end		// end of normalized_towns



////////////////////////////////////////////////////////////////////////////////////////////////////
// Program to create a normalized file at the MSA level
////////////////////////////////////////////////////////////////////////////////////////////////////

cap program drop normalized_MSA
program define normalized_MSA

syntax using/, saveas(string)

// Compute population observed in "city" files (as opposed to total population in the Urban Agglomeration)
use "`using'", clear

preserve
	tempfile temp_UA_city
	keep if city_file==1
	collapse (sum) city_population = population_town_no_OG, by(MSACode)
	save `temp_UA_city', replace
restore

collapse (sum) population (first) TownName, by(MSACode)
merge 1:1 MSACode using `temp_UA_city', nogen
rename population population_town_directory

clonevar UrbAggCode = MSACode
merge 1:1 UrbAggCode using "../output/urban_agglomerations_2001_within.dta", gen(merge_ua_within) keep(1 3)

clonevar UrbAggCode_cross = MSACode
merge 1:1 UrbAggCode_cross using "../output/urban_agglomerations_2001_cross.dta", gen(merge_ua_cross) keepusing(population_UA_cross UrbAggName_cross)

gen population_MSA = population_town_directory
replace population_MSA = population_UA if population_UA!=.
replace population_MSA = population_UA_cross if population_UA_cross!=.
keep if population_MSA>=100000

gen MSAName = TownName
replace MSAName = UrbAggName if UrbAggName!=""
replace MSAName = UrbAggName_cross if UrbAggName_cross!=""

replace city_population = 0 if city_population==.
gen share_population_city = city_population/population_MSA

// Dummy for hindi-speaking states (http://www.mapsofindia.com/culture/indian-languages.html)
gen StateCode = substr(MSACode,1,2)
destring StateCode, replace
gen hindi1 = ((StateCode>=5 & StateCode<=10) | StateCode==2 | StateCode==20 | StateCode==22 | StateCode==23)
gen hindi2 = (hindi1==1 | StateCode==1 | (StateCode>=25 & StateCode<=27))

// Cosmetics
keep MSACode MSAName share_population_city city_population population_MSA hindi*
order MSA*, first
label variable MSAName "Either Town name or name of the Urban Agglomeration"
label variable share "share of total MSA population observed in 'city' files"
label variable hindi1 "States where is Hindi is the main language"
label variable hindi2 "States where Hindi is spoken by at least 10% of the population"
label variable city_population "population in the MSA constituents for which we have a 'city' file"
label variable population_MSA "total population in the MSA"
label data "Data at the Urban Agglomeration level for 384 agglomerations"
gsort -population_MSA
compress

saveold "`saveas'", replace $saveoldversion

end		// end of normalized_MSA

//EDUCATION WORKERS- 6 GROUPS
cap program drop edu_labels_6
program define edu_labels_6

syntax, lblname(string)

label define `lblname' 1 "Illiterate", add
label define `lblname' 2 "Literate no education", add
label define `lblname' 3 "Literate but below secondary", add
label define `lblname' 4 "Secondary but below graduate", add
label define `lblname' 5 "Diploma not equal to degree", add
label define `lblname' 6 "Graduate degree", add

end

cap program drop edu_labels_7
program define edu_labels_7

syntax, lblname(string)

label define `lblname' 1 "Illiterate", add
label define `lblname' 2 "Literate without education", add
label define `lblname' 3 "Literate but below matric/secondary", add
label define `lblname' 4 "Matric/secondary but below graduate" , add
label define `lblname' 5 "Diploma not equal to degree", add
label define `lblname' 6 "Graduate and above other than technical degree", add
label define `lblname' 7 "Technical degree or diploma equal to degree or post-graduate degree", add

end


cap program drop edu_town_count7
program define edu_town_count7

syntax using/, saveas_B9(string) saveas_sample(string)

//Load raw data
import excel "`using'", sheet("Sheet2") cellrange(A8) clear

rename (B C D E F G H I J T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN) (state_code district_code town_code urban area_name edu main_workers worker_male worker_female A25to29 A25to29_M A25to29_F A30to34 A30to34_M A30to34_F A35to39 A35to39_M A35to39_F A40to49 A40to49_M A40to49_F A50to59 A50to59_M A50to59_F A60to69 A60to69_M A60to69_F A70Plus A70Plus_M A70Plus_F )

keep state_code district_code town_code urban area_name edu main_workers worker_male worker_female A25to29 A25to29_M A25to29_F A30to34 A30to34_M A30to34_F A35to39 A35to39_M A35to39_F A40to49 A40to49_M A40to49_F A50to59 A50to59_M A50to59_F A60to69 A60to69_M A60to69_F A70Plus A70Plus_M A70Plus_F

drop if missing(state_code) & missing(town_code) & missing(edu) //Drop footer

label data "Number of workers in each of 7 education categories, by town"

label var	state_code "State code"
label var	district_code "District code"
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


//confirm that file is balanced
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

//restrict sample to urban population and keep Labor-force participants over age 25
keep if urban=="Urban"
gen A25to59 = A25to29 + A30to34 + A35to39 + A40to49 + A50to59
keep state_code district_code town_code area_name edu A25to59


//"Literate without education" is a residual category that we create
drop if edu=="Total"
bys state_code town_code: egen literate_total = max(A25to59*(edu=="Literate"))
by  state_code town_code: egen educated_total = total(A25to59*(edu!="Literate" & edu!="Total" & edu!="Illiterate"))
replace edu = "Literate without education" if edu=="Literate"
replace A25to59 = literate_total - educated_total if edu== "Literate without education"
drop literate_total educated_total


//Create numeric ordered schooling variable and label it
rename edu edu_string
gen     edu = 1 if edu_string=="Illiterate"
replace edu = 2 if edu_string=="Literate without education"
replace edu = 3 if edu_string=="Literate but below matric/secondary"
replace edu = 4 if edu_string=="Matric/secondary but below graduate"
replace edu = 5 if edu_string=="Technical diploma or certificate not equal to degree"
replace edu = 6 if edu_string=="Graduate and above other than technical degree"
replace edu = 7 if edu_string=="Technical degree or diploma equal to degree or post-graduate degree"
edu_labels_7, lblname(edu_labels)
label values edu edu_labels
drop edu_string

//Generate TownCode, label variables, save
gen TownCode = state_code + town_code
order TownCode area_name edu A25to59
label data "Number of workers in each of 7 education categories, by town"
label var TownCode  "Unique town identifier (digits 1-2 state code and digits 3-8 town code)"
label var area_name "Area name"
label var edu       "Education level"
label var A25to59   "Workers age 25 to 59"
keep TownCode area_name edu A25to59

compress
desc
saveold "`saveas_sample'", replace $saveoldversion

end

//EDUCATION WORKERS- 4 GROUPS
cap program drop edu_town_count4
program define edu_town_count4

syntax using/, saveas(string)

use "`using'", clear

gen edu2 = edu
recode edu2 1=1 2=1 3=2 4=3 5=3 6=4 7=4
label define edu2_aggregated_categories 1 "No education" 2 "Primary" 3 "Secondary" 4 "College graduate"
label values edu2 edu2_aggregated_categories

collapse (sum) A25to59, by(TownCode area_name edu2)

label data "Number of workers in each of 4 education categories, by town"

label var	TownCode "Unique town idetification- first 2 numbers are the state code and next 8 numbers are the town code "
label var	area_name "Area name"
label var 	edu "Education level (collapsed 4 scheme)"
label var	A25to59	"Workers age 25 to 59"

rename edu2 edu
compress
desc
saveold "`saveas'", replace $saveoldversion

end

//EDUCATION TOTAL POPULATION- 10 GROUPS
cap program drop edu_labels_9
program define edu_labels_9

syntax, lblname(string)

label define `lblname'	1	"Illiterate " 	,add
label define `lblname'	2	"Literate without education level  " 	,add
label define `lblname'	3	"Below primary  " 	,add
label define `lblname'	4	"Primary  " 	,add
label define `lblname'	5	"Middle  " 	,add
label define `lblname'	6	"Secondary  " 	,add
label define `lblname'	7	"Higher secondary  " 	,add
label define `lblname'	8	"Diploma not equal to degree" 	,add
label define `lblname'	10	"Graduate and above " 	,add

end

cap program drop edu_totalPop_9
program define edu_totalPop_9

syntax using/, saveas_C8_city(string) saveas_sample(string)

//Load raw data
import excel "`using'", sheet("Sheet1") cellrange(A8) clear

rename (B C D E F G H I J K N Q T W Z AC AF AI AL AO) (state_code district_code town_code urban area_name age total total_male total_female illiterate literate literate_no_edu below_primary primary middle secondary higher_secondary non_technical_dipl technical_dipl graduate_above)

keep state_code district_code town_code urban area_name age total total_male total_female illiterate literate literate_no_edu below_primary primary middle secondary higher_secondary non_technical_dipl technical_dipl graduate_above

label data "Number of individuals (entire population) in each of 10 education categories, by town"

label var	state_code "State code"
label var	district_code "District code"
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
saveold "`saveas_C8_city'", replace $saveoldversion

//restrict sample to urban population and keep Labor-force participants over age 25
keep if urban=="Urban"

drop if age=="All ages"|age=="Age not stated"
drop if age=="0-6"|age=="7"|age=="8"|age=="9"|age=="10"|age=="11"|age=="12"|age=="13"|age=="14"|age=="15"|age=="16"|age=="17"|age=="18"|age=="19"|age=="20-24"
drop if age=="65-69"| age=="70-74"|age=="75-79"|age=="80+"

keep state_code district_code town_code area_name  illiterate- graduate_above

foreach var of varlist illiterate- graduate_above {
	bysort state_code district_code town_code:  egen `var'_C = sum(`var')
}

keep state_code district_code town_code illiterate_C - graduate_above_C

quietly bysort state_code district_code town_code:  gen dup = cond(_N==1,0,_n)

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

reshape long edu, i(state_code district_code town_code) j(edu_level)

edu_labels_9, lblname(name)
label values edu_level name

drop dup
rename edu A25to59
rename edu_level edu

//already in string format so no need to convert
gen TownCode = state_code + town_code

recode edu 9=8
collapse (sum) A25to59, by(TownCode edu)
edu_labels_9, lblname(name2)
label values edu name2

order TownCode edu A25to59

keep TownCode edu A25to59

label data "Number of workers in each of 10 education categories, by town"

label var	TownCode "Unique town idetification- first 2 numbers are the state code and next 8 numbers are the town code "
label var 	edu "Education level"
label var	A25to59	"Total population age 25 to 59"

compress
desc
saveold "`saveas_sample'", replace $saveoldversion

end

//EDUCATION TOTAL POPULATION- 9 GROUPS - STATE LEVEL - INCLUDING URBAN & RURAL POPULATION
cap program drop edu_totalPop_9_state
program define edu_totalPop_9_state

syntax using/, saveas_C8_state(string) saveas_sample(string)

//Load raw data
import excel "`using'", sheet("Sheet1") cellrange(A8) clear

rename (B C D E F G H I J K N Q T W Z AC AF AI AL AO) (state_code district_code tehsil_code area_name pop_type age total total_male total_female illiterate literate literate_no_edu below_primary primary middle secondary higher_secondary non_technical_dipl technical_dipl graduate_above)

keep state_code district_code tehsil_code pop_type area_name age total total_male total_female illiterate literate literate_no_edu below_primary primary middle secondary higher_secondary non_technical_dipl technical_dipl graduate_above

label data "Number of individuals (entire population) in each of 10 education categories, by state"

label var	state_code "State code"
label var	district_code "District code"
label var	tehsil_code "Tehsil code"
label var	area_name "Area name"
label var	pop_type "Discrete variable classifying observation as part of total, rural, or urban"
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
saveold "`saveas_C8_state'", replace $saveoldversion

//restrict sample to urban population and keep Labor-force participants over age 25
drop if age=="All ages"|age=="Age not stated"
drop if age=="0-6"|age=="7"|age=="8"|age=="9"|age=="10"|age=="11"|age=="12"|age=="13"|age=="14"|age=="15"|age=="16"|age=="17"|age=="18"|age=="19"|age=="20-24"
drop if age=="65-69"|age=="70-74"|age=="75-79"|age=="80+"

//drop district_code and tehsil_code as it is not informative, it's always equal to: 0000
keep state_code area_name pop_type illiterate- graduate_above

foreach var of varlist illiterate- graduate_above {
	bysort state_code   pop_type:  egen `var'_C = sum(`var')
}

keep state_code  pop_type illiterate_C - graduate_above_C

quietly bysort state_code  pop_type:  gen dup = cond(_N==1,0,_n)

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

reshape long edu, i(state_code pop_type) j(edu_level)

edu_labels_9, lblname(name)
label values edu_level name

drop dup

rename edu A25to59
rename edu_level edu

recode edu 9=8
collapse (sum) A25to59, by(state_code pop_type edu)
edu_labels_9, lblname(name2)
label values edu name2

order state_code pop_type edu A25to59

keep state_code pop_type edu A25to59

label data "Number of workers in each of 9 education categories, by state"

label var 	edu "Education level"
label var	A25to59	"Total population age 25 to 59"

compress
desc
saveold "`saveas_sample'", replace $saveoldversion

end

//EDUCATION TOTAL POPULATION- 4 GROUPS
cap program drop edu_totalPop_4
program define edu_totalPop_4

syntax using/, saveas(string)

use "`using'", clear

gen edu2 = edu
recode edu2 1=1 2/4=2 5/7=3 8/10=4
label define edu2_aggregated_categories 1 "No education" 2 "Primary" 3 "Secondary" 4 "College graduate"
label values edu2 edu2_aggregated_categories

collapse (sum) A25to59, by(TownCode edu2)

label data "Number of people in each of 4 education categories, by town"

label var	TownCode "Unique town idetification- first 2 numbers are the state code and next 8 numbers are the town code "
label var 	edu "Education level (collapsed 4 scheme)"
label var	A25to59	"Total population age 25 to 59"

rename edu2 edu
compress
desc
saveold "`saveas'", replace $saveoldversion

end


cap program drop normalized_districts
program define normalized_districts

// India 2001 Census
global folder "../input"
local list_files: dir "$folder" files "C_8_*.xls", respectcase
di `list_files'
tempfile tf_all_India_series_C8
foreach file of local list_files {
	display "`file'"
	import excel "${folder}/`file'", sheet("Sheet1")clear
	rename (B C E F G H) (state_code district_code  area_name urban age total_pop)
	keep state_code district_code  area_name urban age total_pop
	drop in 1/7
	destring total_pop, replace
	qui capture confirm file "`tf_all_India_series_C8'"
	qui if (_rc==0) append using "`tf_all_India_series_C8'"
	qui saveold "`tf_all_India_series_C8'", replace
}
saveold "`tf_all_India_series_C8'", replace

label data "Total population by district"

label var	state_code "State code"
label var	district_code "District code"
label var	area_name "Area name"
label var	urban "Discrete variable classifying observation as part of total, rural, or urban"
label var 	age "Age of workers"
label var	total_pop "Total population"

compress
desc
saveold "../output/all_India_series_C8.dta", replace $saveoldversion

//Clean
use "../output/all_India_series_C8.dta", clear

//Check unique towns
drop if district_code=="00" //dropping state level observations

//restrict sample to urban population and keep Labor-force participants over age 25
keep if urban=="Urban"
drop urban
keep if age=="25-29" | age=="30-34" | age=="35-39" | age=="40-44" | age=="45-49" | age=="50-54" | age=="55-59"

bysort state_code district_code: egen total_pop_new = sum(total_pop)
quietly bysort state_code district_code:  gen dup = cond(_N==1,0,_n)
keep if dup==0 | dup==1
drop total_pop
rename total_pop_n total_pop
drop dup age

label data "Total urban population age 25-59 by district"

label var	state_code "State code"
label var	district_code "District code"
label var	area_name "Area name"
label var	total_pop "Total population age 25-59"

gen district_code_unique = state_code + district_code
quietly bysort district_code_unique:  gen dup = cond(_N==1,0,_n)
tab dup
//593 districts
drop state_code district_code
rename district_code_unique district_code
label var district_code "First two numbers are state code second two numbers are district code"
order district_code area_name total_pop
drop dup

compress
saveold "../output/district_pop.dta", replace $saveoldversion
desc

//

use "../output/all_India_series_C8.dta", clear

//Check unique towns
drop if district_code=="00" //dropping state level observations

//restrict sample to urban population and keep Labor-force participants over age 25
keep if urban=="Urban"
drop urban
keep if age=="All ages"
quietly bysort state_code district_code:  gen dup = cond(_N==1,0,_n)
tab dup //593 districts

label data "Total urban population all ages by district"

label var	state_code "State code"
label var	district_code "District code"
label var	area_name "Area name"
label var	total_pop "Total population all ages"

gen district_code_unique = state_code + district_code
//593 districts
drop state_code district_code dup
rename district_code_unique district_code
label var district_code "First two numbers are state code second two numbers are district code"
order district_code area_name total_pop
drop age

compress
saveold "../output/district_pop_allages.dta", replace $saveoldversion
desc

end
