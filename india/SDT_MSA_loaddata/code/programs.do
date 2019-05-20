// 2001 program
cap program drop make_normalized_geoyear2001
program define make_normalized_geoyear2001
syntax, saveas(string)


// Load subdistrict shapefile (NB: we only have one shapefile, from 2001, but we also use it for 2011).
tempfile normfile_subdistricts
insheet using "../input/india_sub_districts_area.csv", clear case
drop if GEOKEY==34020011 // this obs corresponds to Ozhukarai, a suburb of Pondicherry, because it has exactly the same STATE+DISTRICT+SUBDISTRICT code as Pondicherry and makes the triplet NOT a unique identifier, causing problems down the road.
save `normfile_subdistricts', replace

// Merge metro mappings
foreach x in 10 20 30 40 50 60 {
	insheet using "../input/mapping_sub_districts_2001_NTL`x'.csv", clear case
	count

	rename ntl_id poly`x'
	merge 1:1 GEOKEY using `normfile_subdistricts', nogen
	order poly`x', last
	save `normfile_subdistricts', replace
}
tostring GEOKEY, format( %08.0f) replace
save `normfile_subdistricts', replace


// Merge Subdistrict population from 2001
// TOTAL POPULATION
import excel "../input/admin_level3.xls", sheet("tehsils_total") firstrow clear
rename (geokey tot_p) (GEOKEY pop_2001_total)
drop if GEOKEY=="" 

keep pop_2001_total GEOKEY
merge 1:1 GEOKEY using `normfile_subdistricts', nogen
save `normfile_subdistricts', replace

// URBAN POPULATION
import excel "../input/admin_level3_urban.xls", sheet("urban_merged") firstrow clear
rename (geokey tot_p) (GEOKEY pop_2001_urban)
drop if GEOKEY==""

keep pop_2001_urban GEOKEY
merge 1:1 GEOKEY using `normfile_subdistricts', nogen
save `normfile_subdistricts', replace

destring pop*, replace

// Rename MSAs as digit 9 followed by Sub-District id of most populous constituent.
foreach x in 10 20 30 40 50 60 {
	bys poly`x': egen maxpop = max(pop_2001_total)	if poly`x'!=.
	gen msa`x' = "9" + GEOKEY if pop_2001_total==maxpop

		gsort poly`x' -pop_2001_total
		carryforward msa`x', replace
		replace msa`x' = "" if poly`x'==.
		drop poly`x' maxpop
}


// Cosmetics

drop STATEDIS
label variable GEOKEY "Subdistrict identifier, 2 digit for state, 2 for district, 4 for subdistrict"
label variable STATE "State ID, 2 digits (with leading zeros)"
label variable DISTRICT "District ID, 2 digits (with leading zeros)"
label variable SUB_DIST "Sub-District ID, 4 digits (with leading zeros)"
label variable TOWN "Town identifier, a 0 except for mismatched observations"
label variable SUBDIST2 "Alternative Sub-District ID, matches SUB_DIST for all but 1 obs"
label variable ADMIND_NAM "Sub-District Name"
label variable DIST_NAME "District Name"
label variable STATE_NAME "State Name"
label variable ADMTYPE "State-specific name for level 3 administration, i.e. Sub-Districts"
label variable pop_2001_urban "population in 2001, urban"
label variable pop_2001_total "population in 2001, urban + rural"
label variable msa10 "Nightlight-based MSA, threshold 10, identifier is digit 9 + id of most populous subdistrict"
label variable msa20 "Nightlight-based MSA, threshold 20, identifier is digit 9 + id of most populous subdistrict"
label variable msa30 "Nightlight-based MSA, threshold 30, identifier is digit 9 + id of most populous subdistrict"
label variable msa40 "Nightlight-based MSA, threshold 40, identifier is digit 9 + id of most populous subdistrict"
label variable msa50 "Nightlight-based MSA, threshold 50, identifier is digit 9 + id of most populous subdistrict"
label variable msa60 "Nightlight-based MSA, threshold 60, identifier is digit 9 + id of most populous subdistrict"

drop if GEOKEY=="15050093" // This corresponds to a small village named "Thingsulthliah" that is not in the shapefile. This town has a (rural) population of 4792

save "`saveas'", replace

end
// 2001 program finished


// 2011 program
cap program drop make_normalized_geoyear2011
program define make_normalized_geoyear2011
syntax, saveas(string)

/* Load Crosswalk between 2001 and 2011 subdistrict codes */
tempfile crosswalk_subdistrict_2001_2011
insheet using "../input/town_2011_2001.csv", clear case delimiter(;)
save `crosswalk_subdistrict_2001_2011', replace

forval x = 1/35 {
	insheet using "../input/village_2011_2001_`x'.csv", clear case delimiter(;)
	append using `crosswalk_subdistrict_2001_2011'
	save `crosswalk_subdistrict_2001_2011', replace
}
rename (sub_district_code_2001 sub_district_code_2011) (subdistrict_code_2001 subdistrict_code_2011)
compress
gen TownVillage = .
replace TownVillage = town_code_2011 if town_code_2011!=.
replace TownVillage = village_code_2011 if village_code_2011!=.
save "../output/India_subdistrict_crosswalk_2001_2011.dta", replace


// Load subdistrict shapefile (NB: we only have one shapefile, from 2001, but we also use it for 2011).
tempfile normfile_subdistricts_2011
insheet using "../input/india_sub_districts_area.csv", clear case
drop if GEOKEY==34020011 // this obs corresponds to Ozhukarai, a suburb of Pondicherry, because it has exactly the same STATE+DISTRICT+SUBDISTRICT code as Pondicherry and makes the triplet NOT a unique identifier, causing problems down the road.
save `normfile_subdistricts_2011', replace

// Merge Subdistrict population from 2011
// TOTAL & URBAN POPULATION
tempfile pop2011
use "../input/subdistricts_directory.dta", clear
keep if Level=="TOWN" | Level=="VILLAGE"
destring TOT_P, replace
bys State District Subdistt TownVillage: egen max_pop = max(TOT_P)
keep if TOT_P==max_pop	// some ~300 towns appear twice, once as a Municipal Corporation, once as MC + "Out Growths"
gen pop_2011_total = TOT_P
gen pop_2011_urban = TOT_P if TRU=="Urban"
drop TOT_P TRU
recode pop_2011_* (. = 0)
destring State District Subdistt TownVillage, replace
duplicates drop State District Subdistt TownVillage pop_2011_total, force // 21 obs are identical except for the name, true duplicates with a typo in the name or two different names for the same location

rename (State District Subdistt) (state_code_2011 district_code_2011 subdistrict_code_2011)
merge 1:m state_code_2011 district_code_2011 subdistrict_code_2011 TownVillage using "../output/India_subdistrict_crosswalk_2001_2011.dta", gen(merge_crosswalk_pop11) // 38 locations have population data but aren't in the crosswalk file, total population is ~370K so I ignore the issue for now.

keep if merge_crosswalk_pop11==3

// if we sum population at this point we have 1.26B rather than 1.21B, so there are 50M extra people due to double counting, i.e. the same 2011 town/village maps to multiple town/town villages. For lack of better solution I'll force drop the duplicate observations, this means that the first pair will be kept, the following ones will be dropped.

duplicates drop state_code_2011 district_code_2011 subdistrict_code_2011 TownVillage, force // this drops 484 obs and now total population is 1.19B, closer to the correct total.

collapse (sum) pop_2011_total pop_2011_urban, by(state_code_2001 district_code_2001 subdistrict_code_2001)
rename (state_code_2001 district_code_2001 subdistrict_code_2001) (STATE DISTRICT SUB_DIST)

merge 1:1 STATE DISTRICT SUB_DIST using `normfile_subdistricts_2011' // 1.16B worth of population is correctly matched as 1:1, additional 39M are mismatched (49 obs), i.e. the subdistrict has a population in 2011 but the code does not appear in the 2001 shapefile

keep if GEOKEY!=.
drop _merge

save `normfile_subdistricts_2011', replace

// Merge nightlight mapping
foreach x in 10 20 30 40 50 60 {
	insheet using "../input/mapping_sub_districts_2011_NTL`x'.csv", clear case
	count

	rename ntl_id poly`x'
	merge 1:1 GEOKEY using `normfile_subdistricts_2011', nogen
	order poly`x', last
	save `normfile_subdistricts_2011', replace
}
tostring GEOKEY, format( %08.0f) replace
save `normfile_subdistricts_2011', replace

order pop*, last


// Rename MSAs as digit 9 followed by Sub-District id of most populous constituent.
foreach x in 10 20 30 40 50 60 {
	bys poly`x': egen maxpop = max(pop_2011_total)	if poly`x'!=.
	gen msa`x' = "9" + GEOKEY if pop_2011_total==maxpop

		gsort poly`x' -pop_2011_total
		carryforward msa`x', replace
		replace msa`x' = "" if poly`x'==.
		drop poly`x' maxpop
}

// Cosmetics

drop STATEDIS
label variable GEOKEY "Subdistrict identifier, 2 digit for state, 2 for district, 4 for subdistrict"
label variable STATE "State ID, 2 digits (with leading zeros)"
label variable DISTRICT "District ID, 2 digits (with leading zeros)"
label variable SUB_DIST "Sub-District ID, 4 digits (with leading zeros)"
label variable TOWN "Town identifier, a 0 except for mismatched observations"
label variable SUBDIST2 "Alternative Sub-District ID, matches SUB_DIST for all but 1 obs"
label variable ADMIND_NAM "Sub-District Name"
label variable DIST_NAME "District Name"
label variable STATE_NAME "State Name"
label variable ADMTYPE "State-specific name for level 3 administration, i.e. Sub-Districts"
label variable pop_2011_urban "population in 2011, urban"
label variable pop_2011_total "population in 2011, urban + rural"
label variable msa10 "Nightlight-based MSA, threshold 10, identifier is digit 9 + id of most populous subdistrict"
label variable msa20 "Nightlight-based MSA, threshold 20, identifier is digit 9 + id of most populous subdistrict"
label variable msa30 "Nightlight-based MSA, threshold 30, identifier is digit 9 + id of most populous subdistrict"
label variable msa40 "Nightlight-based MSA, threshold 40, identifier is digit 9 + id of most populous subdistrict"
label variable msa50 "Nightlight-based MSA, threshold 50, identifier is digit 9 + id of most populous subdistrict"
label variable msa60 "Nightlight-based MSA, threshold 60, identifier is digit 9 + id of most populous subdistrict"

save "`saveas'", replace

end
// 2011 program finished
