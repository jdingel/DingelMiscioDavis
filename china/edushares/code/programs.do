cap program drop edu_shares_china
program define edu_shares_china

syntax, msavar(string) 

tempfile tf_educ_agg_townships_2000 tf_main
tempfile tf0 tf1
use "../input/pop_by_educ_townships_2000.dta", clear
gen educ_agg = educ_cat
recode educ_agg 1=1 2=1 3=1 4=2 5=3 6=3 7=4 8=4 9=4
label define educ_agg 1 "Primary school or less" 2 "Middle school" 3 "High school" 4 "College or university"
label values educ_agg educ_agg
save `tf_educ_agg_townships_2000', replace

//Global population share
rename (pop_educ educ_agg) (edupop edu)
collapse (sum) edupop, by(edu)
egen total = total(edupop)
gen share = edupop / total
keep edu share  

foreach var of varlist share {
	tostring `var', replace format(%3.2f) force
	replace `var' = subinstr(`var',"0.",".",1)
}

rename share share_global_ch
save `tf0', replace

//Produce MSA population file 
tempfile tf_pop_`msavar'
use "../input/townships_2000.dta", clear
collapse (sum) population, by(`msavar')
drop if missing(`msavar')
label variable population "MSA population in 2000"
label data "Township-based MSA populations in 2000"
save `tf_pop_`msavar'', replace 

//Merge with MSA, impose msapopulation>=100k cutoff 
use `tf_educ_agg_townships_2000', clear
merge m:1 gbtown using "../input/townships_2000.dta", gen(merge) keep(master match) keepusing(`msavar') //What should the "assert" on this merge be?
merge m:1 `msavar' using "`tf_pop_`msavar''", gen(merge2) keep(master match) keepusing(population)
keep if missing(population)==0 & population>=100000
keep educ_agg pop_educ `msavar' population
save `tf_main', replace

//Population share amongst MSAs with pop>=100000
use `tf_main',clear
rename (pop_educ educ_agg) (edupop edu)
collapse (sum) edupop, by(edu)
egen total = total(edupop)
gen share = edupop / total
keep edu share 

foreach var of varlist share {
	tostring `var', replace format(%3.2f) force
	replace `var' = subinstr(`var',"0.",".",1)
}

rename share share_msa_100k_ch
save `tf1', replace

merge 1:1 edu using `tf0', assert(3) nogen
gen id = _n
rename edu edu_ch
order id edu_ch share_global_ch share_msa_100k_ch

end

