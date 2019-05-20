//This program takes our newly created MSAs and aggregates municipio populations to create MSA populations.
capture program drop msapop
program define msapop
syntax using/

tempfile tf1

//Loading municipio population data
use "../input/BR_MUNICIPIO_POP.dta" if year == 2010, clear
save `tf1', replace

//Creating MSA population file
use "`using'", clear
merge 1:1 municipio_code_full using `tf1', nogen keepusing(totalpop urbanpop ruralpop)
collapse (sum) totalpop urbanpop ruralpop, by(msa)
label var totalpop "Total MSA population"
label var urbanpop "Urban MSA population"
label var ruralpop "Rural MSA population"
label var msa "MSA"
order msa totalpop urbanpop ruralpop
sort msa
compress
desc
label data "MSA Population 2010"
saveold "../output/msapop_2010.dta", replace

end

capture program drop msapop_alt
program define msapop_alt
syntax using/, msavar(string) saveas(string)
use population urbanpop ruralpop area_km2 `msavar' using "`using'", clear
drop if missing(`msavar')==1
collapse (sum) totalpop = population urbanpop ruralpop area_km2, by(`msavar')
label var totalpop "Total MSA population"
label var urbanpop "Urban MSA population"
label var ruralpop "Rural MSA population"
label var area_km2 "MSA land area (km2)"
save `saveas', replace
end


//This program takes in a category (occ, ind or edu) and produces estimation arrays for that category.
//Data set should be either "Census2010" or "RAIS2010".
cap program drop msa_estimation_prep
program define msa_estimation_prep
syntax using/, saveas(string) dataset(string) popthresh(integer) category(string)
use "`using'", clear
merge m:1 state_code municipio_code using "../input/msa_municipio_2010_map.dta", keep(match) nogen
merge m:1 msa10 using "../output/msapop_2010.dta", keep(match) nogen
rename totalpop msapop
keep if msapop >= `popthresh'
collapse (first) msapop (sum) `category'pop, by(msa10 `category')
if ("`category'" == "edu" & "`dataset'" == "RAIS2010") local j = 11 //There are 11 educational groups.
if ("`category'" == "edu" & "`dataset'" == "Census2010") local j = 4 //Working with four educational categories for now.

gen logmsapop = log(msapop)
gen log`category'pop = log(`category'pop)

if ("`category'" == "edu"){
	tab edu, gen(edu)
	forvalues i = 1/`j'{
		gen logpopXedu_`i' = logmsapop * edu`i'
	}
	if (`j' == 4) edulabels_4g
}

label var msa10 "Metropolitan Statistical Area (MSA) code"
label var msapop "MSA population"
label var logmsapop "Log of MSA population"

order msa10 msapop logmsapop `category' `category'pop log`category'pop `category'* logpopX*
sort msa10
compress
desc
if ("`category'" == "edu") label data "Educational group population in Brazil by MSA. 2010. Source: `dataset'."
saveold "`saveas'.dta", replace

end

//This program defines educational category labels in the 4-group case.
cap program drop edulabels_4g
program define edulabels_4g
label var logpopXedu_1 "No schooling"
label var logpopXedu_2 "Elementary graduate"
label var logpopXedu_3 "High school graduate"
label var logpopXedu_4 "College graduate"
end
