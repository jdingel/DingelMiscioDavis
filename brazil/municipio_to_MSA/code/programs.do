//This program preps the commuting data necessary to run Duranton's algorithm.
cap program drop prep_commute
program define prep_commute
syntax, filename(string)

	use "../input/CENSO10_pes.dta", clear
	rename (v0660 munic) (workplace origin) //v0660 is a variable describing the person's workplace
	gen destination = floor(v6604/10)
	drop if v0661==2 // drop those who don't go back home on a daily basis (not really commuters)
	drop if (destination>=540000 | destination==.) & workplace!=1 & workplace!=2 // to eliminate codes like 888888, etc and people not working
	replace destination = origin if (workplace==1 | workplace==2) //workplace == 1 means the person worked from home and workplace == 2 means they worked only in the municipio under v6604, though not at home.
	collapse (sum) x_od = v0010, by(origin destination) //v0010 is the survey sampling weight
	order origin destination x_od
	bys origin: egen resident_origin = total(x_od)
	saveold "../output/`filename'.dta", replace

end

//Thresh defines the commuting threshold above which spatial units are aggregated into the same MSA, as per Duranton (2013).
//Filename defines the name we want to give to the master commuting file used in creating MSAs.
//Saveas defines the ultimate file name that our MSAs will be saved to.
cap program drop MSAcreate
program define MSAcreate
syntax, thresh(integer) filename(string) saveas(string)

// Input 1: commuting threshold in %
global k = `thresh'

tempfile tf0 tf1 tf2

// input 2: file with origin, destination, commuting and population by origin
use "../output/`filename'.dta", clear
save `tf0', replace

keep origin
rename origin old_geo_id
duplicates drop
gen previous_geo_id = old_geo_id
save `tf1', replace

global i = 1	// start iteration counter, this indexes files taken by iteration i as input
global to_merge = 1000	// value to initialise loop, any value > 0 is fine
while $to_merge>0 {

	use `tf0', replace
	drop if origin==destin
	gen share = 100 * x_od/resident_origin
	egen max_share = max(share)
	keep if max_share==share	// across all origins, keep only pair with largest flow

	qui {
		sum origin
		global old = `r(mean)'
		sum destin
		global new = `r(mean)'
	}
	// We merge a single spatial unit in each iteration, this rules out the possibility that
	// in any one round, i->j while at the same time j->i, or that a i->k while k->j, etc.

	// update aggregation_reference_$k.dta and aggregation_reference_steps_$k.dta
	use `tf1', replace
	gen new_geo_id = previous_geo_id
	replace new_geo_id = $new if new_geo_id==$old
	drop previous_geo_id
	rename new_geo_id previous_geo_id
	save `tf1', replace


	clear
	set obs 1
	gen step = $i
	gen old = $old
	gen new = $new
	capture confirm file `tf2'
	if _rc==0 append using `tf2'
	save `tf2', replace

	// update file with commuting flows
	use `tf0', replace

	replace origin=$new if origin==$old
	replace destin=$new if destin==$old

	collapse (sum) x_od, by(origin destin)
	bys origin: egen resident_origin = total(x_od)
	save `tf0', replace

	global i = $i+1
	drop if origin==destin
	gen share = 100*x_od/resident_origin
	drop if share==. | share<$k
	count
	global to_merge = `r(N)'
}

use "../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta", clear
gen municipio7 = municipio
gen municipio6 = floor(municipio7/10)
gen micro = microrregio
gen meso = mesorregio
gen old_geo_id = municipio6
merge 1:1 old_geo_id using `tf1', nogen keep(3)


//Extracting municipio and state codes.
rename (previous_geo_id municipio7) (msa$k municipio_code_full)
tostring municipio_code_full, replace
gen state_code = substr(municipio_code_full, 1, 2)
gen municipio_code = substr(municipio_code_full, 3, 4)
destring municipio_code_full state_code municipio_code, replace

if ($k == 5) replace msa$k = 290400 if municipio6== 290400

//This file will contain municipio-MSA mappings as well as MSA mappings with a few other geographical regions defined by the Brazilian census (i.e. mesoregions).
compress
desc
label data "MSA mappings across geographical units (municipios, mesoregions and microregions)"
saveold "../output/`saveas'.dta", replace

if ($k == 10){
//This file will contain only municipio-MSA mappings.
keep msa$k municipio_code_full state_code municipio_code
label var msa$k "Metropolitan Statistical Area"
label var municipio_code_full "Full 7-digit municipio code"
label var state_code "State code"
label var municipio_code "municipio code"
order msa$k municipio_code_full state_code municipio_code
sort msa$k
compress
desc
label data "MSA-municipio Mappings, 2010"
saveold "../output/msa_municipio_2010_map.dta", replace
}

end


//Program to create a normalized file at the municipio-year level
capture program drop make_normalized_geoyear
program define make_normalized_geoyear
syntax, commuting(numlist min=1) [nightlights(namelist min=1)] outputfile(string)

	tempfile tf0
	use "../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta", clear
	rename municipio municipio7
	gen municipio6 = floor(municipio7/10)

	// Merge 2010 population
	gen year = 2010
	gen municipio_code_full = municipio7
	merge 1:1 municipio_code_full year using "../input/BR_MUNICIPIO_POP.dta", nogen keepusing(*pop) keep(3)
	drop municipio_code_full
	rename totalpop population

	// Merge area
	preserve
		tempfile area
		insheet using "../input/brazil_municipios_area.csv", comma clear
		keep cd_geocodm area_km2 lon lat
		rename cd_geocodm municipio7
		save `area', replace
	restore

	merge 1:1 municipio7 using `area', nogen keep(1 3)

	// Merge identifiers of commuting derived MSAs
	foreach x in `commuting' {
		merge 1:1 municipio6 using "../output/geo_crosswalk_`x'.dta", nogen keepusing(msa`x')

	// Create new MSA identifiers = digit "9" + id of largest constituent (e.g. largest municipio)
	// This is done so we can compare individual MSAs across definition
	// Otherwise the MSA identifiers are meaningless.

		rename msa`x' temp_`x'
		bys temp_`x': egen temp_max_pop = max(population) if temp_`x'!=.
		gen long msa`x' = municipio6 if temp_max_pop == population
		tostring msa`x', replace
		replace msa`x' = "9" + msa`x' if msa`x'!="."
		destring msa`x', ignore(.) replace
		format msa`x' %12.0f

		gsort temp_`x' -population
		by temp_`x': carryforward msa`x', replace
		drop temp*
		label variable msa`x' "MSA mapping with minimum commuting threshold `x'%"
		unique msa`x'
		rename msa`x' msa_duranton_`x'
	}

	// Merge identifiers of nightlight derived MSAs
	foreach x in `nightlights' {

		preserve
			local i = substr("`x'",-2,2)  //grab the "20" in msa20
			import delimited using "../input/municipios_2010_NTL`i'.csv", clear
			keep polygon_id cd_geocodm
			rename (polygon_id cd_geocodm) (`x' municipio7)
			tempfile nightlight_msa
			save `nightlight_msa', replace
		restore

		merge 1:1 municipio7 using `nightlight_msa',  nogen keep(1 3) keepusing(`x')

	// Create new MSA identifiers = digit "9" + id of largest constituent (e.g. largest municipio)
	// This is done so we can compare individual MSAs across definition
	// Otherwise the MSA identifiers are meaningless.

		rename `x' temp_`x'
		bys temp_`x': egen temp_max_pop = max(population) if temp_`x'!=.
		gen long `x' = municipio6 if temp_max_pop == population
		tostring `x', replace
		replace `x' = "9" + `x' if `x'!="."
		destring `x', ignore(.) replace
		format `x' %12.0f

		gsort temp_`x' -population
		by temp_`x': carryforward `x', replace
		drop temp*
		local mylabel = substr("`x'",4,length("`x'")-strpos("`x'","_")-1)
		label variable `x' "MSA mapping with nightlight threshold `mylabel'"
		unique `x'
		rename `x' msa_night_`mylabel'
	}

	//Adding msa_microrregio & msa_mesorregio
	foreach x in microrregio mesorregio{
		gen temp_`x' = `x'
		bys temp_`x': egen temp_max_pop = max(population) if temp_`x'!=.
		gen long msa_`x' = municipio6 if temp_max_pop == population
		tostring msa_`x', replace
		replace msa_`x' = "9" + msa_`x' if msa_`x'!="."
		destring msa_`x', ignore(.) replace
		format msa_`x' %12.0f

		gsort temp_`x' -population
		by temp_`x': carryforward msa_`x', replace
		drop temp*
		unique msa_`x'
		}
	save `tf0', replace

	//Adding msa_ibge
	tempfile msa_ibge
	import excel municipio_name = A population = B municipio7 = K using "../input/tab3_1.xls", sheet("Tabela 3.1") cellrange(A9:W2023) clear
	drop if municipio_name=="Homens" | municipio_name=="Mulheres" | population==.
	gen msa_ibge = municipio7 if municipio7<=999999
	gen msa_name = municipio_name if msa_ibge!=.
	carryforward msa_name msa_ibge, replace
	drop if msa_ibge == municipio7
	bys msa_ibge: egen msa_ibge_components = count(population)
	bys msa_ibge: egen maxpop = max(population)
	gen msa_ibge_recode = "9" + substr(string(municipio7),1,6) if population == maxpop
	destring msa_ibge_recode, replace
	gsort msa_ibge -population
	carryforward msa_ibge_recode, replace
	save `msa_ibge'

	use `tf0', clear
	merge 1:1 municipio7 using `msa_ibge', nogen keepusing(msa_ibge_recode)

	//Merge with arranjos and identify arranjos by their most populous municipio
	clonevar code_muni = municipio7
	merge 1:1 code_muni using "../input/MCARPs_Chauvin2017.dta", assert(match) nogen keepusing(arranjo)
	tempvar tv1
	gsort arranjo -population
	by arranjo: egen double `tv1'  = max(population)
	gen msa_arranjo = real("9" + string(municipio6)) if missing(arranjo)==0 & `tv1'==population //identify arranjos by their most populous municipio
	by arranjo: carryforward msa_arranjo, replace
	label variable msa_arranjo "Arranjo (via JP Chauvin)"
	unique msa_arranjo
	drop code_muni `tv1'

	//Adding msa_municipio6
	gen msa_municipio6 = real("9"+string(municipio6))

	// Cosmetics
	label variable uf "State id"
	label variable nome_uf "State name"
	label variable mesorregio "Meso-region id"
	label variable nome_mesorregio "Meso-region name"
	label variable microrregio "Micro-region id"
	label variable nome_microrregio "Micro-region name"
	label variable municipio7 "Municipio id (7 digits)"
	label variable nome_municipio "Municipio name"
	label variable municipio6 "Municipio id (6 digits)"
	label variable msa_municipio6 "municipio6 recoded to look like an MSA code"
	label variable year
	label variable population "Total population in municipio"
	label variable urbanpop "Urban population in municipio"
	label variable ruralpop "Rural population in municipio"
	label variable msa_microrregio "microrregio recoded to look like an MSA code"
	label variable msa_mesorregio "mesorregio recoded to look like an MSA code"
	label variable msa_ibge "msa_ibge recoded to look like an MSA code"
	order *municipio* population *pop* area lat lon, first

	saveold "`outputfile'", replace

end

cap program drop add_geographic_coordinates
program define add_geographic_coordinates
syntax using/, geofile(string) saveas(string)

tempfile tf0
insheet using "`geofile'", comma clear
keep cd_geocodm area_km2 lon lat
rename cd_geocodm municipio7
save `tf0', replace

use "`using'", clear
merge 1:1 municipio7 using `tf0', nogen keep(3) assert(1 3)

saveold "`saveas'", replace

end

//Purpose: Summarize number of municipios assigned to each MSA under different schemes
capture program drop summarize_assignments
program define summarize_assignments

	syntax using/, outputtextfile(string) outputtablefile(string)

//Load municipio to MSA mapping
use `using', clear

//Output files
cap rm "`outputtextfile'"
cap rm "`outputtablefile'"
file open outputfile using "`outputtextfile'", write
file open outputtable using "`outputtablefile'", write

file write outputtable "scheme & median & median >100k & multi-unit MSAs & multi-unit MSAs > 100k \\" _n

foreach msavar of varlist msa_* {

	bys `msavar': egen total = total(1)
	by  `msavar': egen msapop = total(population)
	egen tag = tag(`msavar')

	file write outputfile "`msavar':" _n
	file write outputtable "`msavar': & "

	qui summ total if tag==1, d
	file write outputfile "The median number of geographic units per MSA is `r(p50)' in the `msavar' scheme." _n
	file write outputtable "`r(p50)' & "

	qui summ total if tag==1 & msapop>=100000, d
	file write outputfile "The median number of geographic units per MSA is `r(p50)' for MSAs with more than 100,000 population in the `msavar' scheme." _n
	file write outputtable "`r(p50)' & "

	qui count if total>1 & tag==1
	file write outputfile "There are `r(N)' MSAs containing more than one geographic unit in the `msavar' scheme." _n
	file write outputtable "`r(N)' & "

	qui count if total>1 & tag==1 & msapop>=100000
	file write outputfile "There are `r(N)' MSAs with more than 100,000 population and containing more than one geographic unit in the `msavar' scheme." _n
	file write outputtable "`r(N)' \\" _n

	drop tag total msapop
}

file close outputfile
file close outputtable

end
