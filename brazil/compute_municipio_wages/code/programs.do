//////////////////////////////////////////////////////////////////////////
// A. Clean individual census data
//////////////////////////////////////////////////////////////////////////

cap program drop clean_census_data
program define clean_census_data
syntax, saveas(string) wagemin(integer) wagemax(integer) ///
  minage(integer) maxage(integer) geovar(string)

tempfile tf_state

foreach x in RR AP AC DF RO SE TO MS AM AL MT ES RN PI PB GO PA MA CE SC PE RJ PR RS BA MG SP {
  use "../input/CENSO10_`x'_pes.dta", clear
    ren (v0001 v0002 v1002 v1003 v0300) (state city_code mesoregion_code microregion_code control_number)
    tostring city_code, replace format("%05.0f")
    tostring mesoregion_code, replace format("%02.0f")
    tostring microregion_code, replace format("%03.0f")
    tostring control_number, replace format("%08.0f")
    tostring munic, replace
    replace munic = string(state) + string(real(subinstr(munic,string(state),"",1)),"%04.0f") if real(substr(munic,1,2))==state
    destring munic, replace

  ren v0010 headcount
  ren (v0601 v0606 v6036 v6400) (sex ethnicity age educ)
  ren (v0653 v6910) (gross_week_hours emp_status)
  ren (v6511 v6521 v6525) (gross_month_inc_main gross_month_inc_other gross_month_inc_all)

  keep munic headcount sex ethnicity gross_week_hours age educ gross_month_inc_main gross_month_inc_other gross_month_inc_all emp_status
  cap append using `tf_state'
  save `tf_state', replace
}

// geographic identifier
ren munic `geovar'
// observation counter
gen id = 1

//clean demographic data
recode sex (1 = 0 "Male") (2 = 1 "Female"), gen(female)
recode ethnicity (1 = 1 "White") (2 = 2 "Black") (3 = 3 "Yellow") (4 = 4 "Brown") (5 = 5 "Indigenous") (9 = 9 "Unknown"), gen(race)
recode educ (1 = 1 "No schooling") (2 = 2 "Elementary Graduate") (3 = 3 "High School Graduate") (4 = 4 "College Graduate") (5 = 5 "Undetermined"), gen(edu)

//wage calculation
gen gross_month_hours = gross_week_hours*4
gen wage = gross_month_inc_main/gross_month_hours // hourly wage = gross monthly income from main job / monthly hours worked at main job
label var wage "hourly wage from main job"
  //winsorize wages
winsor2 wage, replace cuts(`wagemin' `wagemax')
gen tot_annual_inc = (gross_month_inc_all)*12
label var tot_annual_inc "total annual income from all jobs"

//sample selection
keep if emp_status==1 // keep only employed workers
keep if inrange(age,`minage',`maxage')
drop if race==9 // omit unkown race category
drop if edu==5 // omit unknown education category
drop if wage==. & tot_annual_inc==. // drop missing wage data

label var emp_status "employment status"
label var age "Age in years"
label var race "Race/ethnicity"
label var female "1(Female)"
label var edu "Educational attainment"
label var headcount "Sampling weight"
label var id "Observation counter"

label data "Cleaned individual-level wages, income, demographic, and municipio data. Source: 2010 Census"
save "`saveas'.dta", replace

end

//////////////////////////////////////////////////////////////////////////
// B. This program creates a municipio-by-demographic-level wage dataset
//////////////////////////////////////////////////////////////////////////

cap program drop municipio_demo_wages
program define municipio_demo_wages
syntax, saveas(string) using(string) demovar(namelist min=1) geovar(string)

use "`using'.dta", clear

//collapse municipality wages by municipio
collapse (rawsum) id headcount (mean) wage tot_annual_inc [aw=headcount], by(`geovar' `demovar')

label var edu "Educational attainment"
label var race "Race/Ethnicity"
label var female "1(Female)"
label var age "Age in years"
label var headcount "Number of workers (sampling weighted)"
label var wage "Average hourly wage from main job"
label var tot_annual_inc "Total annual income"
label var id "Observation counter"

save "`saveas'.dta", replace
label data "Average earnings and employment population by demographics (age, sex, race, education) by municipio. Source: 2010 Census"

end


///////////////////////////////////////////////////////////////////////////////////
// C. This program collapses the demographic-cell wage data by educational attainment
///////////////////////////////////////////////////////////////////////////////////

cap program drop municipio_edu_wages
program define municipio_edu_wages
syntax, saveas(string) using(string) demovar(namelist min=1) geovar(string)

use "`using'.dta", clear

// obtain individual-level national demographic residuals
foreach x in age race {
  qui tab `x', gen(`x'dummy)
}
local democovs "agedummy* racedummy* female" // exclude education; prepping for skill premia

foreach y in wage tot_annual_inc {
  gen log_`y' = log(`y')
  qui reg log_`y' `democovs' [aw=headcount]
  predict `y'_residuals, residuals
  drop log_`y'
}

// Prepare dataset for skill premia calculation: collapse away demographics by education
collapse (rawsum) id headcount (mean) wage wage_residuals tot_annual_inc tot_annual_inc_residuals [aw=headcount], by(`geovar' `demovar')

label var edu "Educational attainment"
label var headcount "Number of workers (sampling weighted)"
label var wage "Average wage"
label var tot_annual_inc "Total annual income"
label var wage_residuals "Demographic adjusted wage residuals from (log) wage regression."
label var tot_annual_inc_residuals " Demographic adjusted (total) income residuals from (log) income regression."
label var id "Observation counter"

save "`saveas'.dta", replace
label data "Average earnings and employment population by educational attainment by municipio with demographic-adjusted earnings residuals. Source: 2010 Census."

end
