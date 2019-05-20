cap program drop edu_shares_census
program define edu_shares_census

syntax using/, [dropif_msapop(string)] outputname(string)

//census
use "`using'", clear

//4 education groups from No schooling to College Graduate drop Undetermined
drop if edu==5
if "`dropif_msapop'"~="" drop if `dropif_msapop'
collapse (sum) edupop, by(edu)
egen total = total(edupop)
gen share = edupop / total
keep edu share

foreach var of varlist share {
	tostring `var', replace format(%3.2f) force
	replace `var' = subinstr(`var',"0.",".",1)
}

listtex edu share using `outputname', replace ///
rstyle(tabular) head("\begin{tabular}{|lc|} \hline" "&Population \\" "Skill (4 groups) &share \\ \hline") foot("\hline \end{tabular}")

end


cap program drop category_shares
program define category_shares

syntax using/,  geosecpop(string) secvar(string) saveas(string)

use "`using'", clear
collapse (sum) `geosecpop', by(`secvar')
egen total = total(`geosecpop')
gen share = `geosecpop' / total
keep `secvar' share
gsort -share

label var share "Share of the population per category"

save `saveas', replace

end
