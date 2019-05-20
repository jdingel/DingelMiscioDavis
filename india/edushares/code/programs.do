cap program drop edu_shares_india
program define edu_shares_india

syntax, msavar(string)

tempfile tf0 tf1

//Global population share
use edu A25to59 state_code pop_type if state_code == "00" & pop_type == "Total" using ///
	"../input/town_edu_count_AllPop_state.dta", clear //Select directly total population for all India
gen edu2 = edu
recode edu2 1=1 2=2 3=2 4=2 5=3 6=3 7=3 8=4 10=4
label define edu2_aggregated_categories 1 "No education" 2 "Primary" 3 "Secondary" 4 "College graduate"
label values edu2 edu2_aggregated_categories
drop edu
rename (edu2 A25to59) (edu edupop)

collapse (sum) edupop, by(edu)
egen total = total(edupop)
gen share = edupop / total
keep edu share
foreach var of varlist share {
	tostring `var', replace format(%3.2f) force
	replace `var' = subinstr(`var',"0.",".",1)
}
rename share share_global_ind
save `tf0', replace

//Population share amongst MSAs with pop>=100000
use "../input/town_edu_count_AllPop_4Groups.dta", clear
rename (A25to59) (edupop)
save `tf1',replace

use TownCode population `msavar' using "../input/town_2001.dta", clear
merge 1:m TownCode using `tf1', keep(match)
keep if inrange(population,100000,.)

collapse (sum) edupop, by(edu)
egen total = total(edupop)
gen share = edupop / total
keep edu share

foreach var of varlist share {
	tostring `var', replace format(%3.2f) force
	replace `var' = subinstr(`var',"0.",".",1)
}

rename share share_msa_100k_ind
save `tf1', replace

merge 1:1 edu using `tf0', assert(3) nogen
gen id=_n
rename edu edu_ind
order id edu_ind share_global_ind share_msa_100k_ind

end
