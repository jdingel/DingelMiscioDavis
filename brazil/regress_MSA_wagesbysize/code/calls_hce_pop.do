set more off
qui do "programs.do"

/************************************
** WAGE PREMIA: Wages across MSA size
************************************/

//clear old output
cap rm ../output/hce_pop_wage_Census2010_upperpanel.tex
cap rm ../output/hce_pop_wage_Census2010_upperpanel.txt
cap rm ../output/hce_pop_wage_Census2010_lowerpanel.tex
cap rm ../output/hce_pop_wage_Census2010_lowerpanel.txt


forvalues x = 10(10)50 {
  //NTL: HKE
  estimationarray_hce_pop, geovardemovarnormfile(../input/BR_MUNICIPIO_demowages_Census2010.dta) ///
    geovarmsavarnormfile(../input/municipios_2010.dta) ///
    msavarnormfile(../input/msa_night_`x'pop_2010.dta) ///
    geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) geovarsecvarpop(edupop) ///
    incvar(wage) geovar(municipio6) msavar(msa_night_`x') secvar(edu) keepif(totalpop>100000) ///
    geodemopop(headcount) msapop(totalpop) demovar(edu race age female) ///
    tablefilename(../output/hce_pop_wage_Census2010_upperpanel) ctitle(Lights: `x') debug
}
forvalues d = 5(10)25 {
  //Commuting: HKE
  estimationarray_hce_pop, geovardemovarnormfile(../input/BR_MUNICIPIO_demowages_Census2010.dta) ///
    geovarmsavarnormfile(../input/municipios_2010.dta) ///
    msavarnormfile(../input/msa_duranton_`d'pop_2010.dta) ///
    geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) geovarsecvarpop(edupop) ///
    incvar(wage) geovar(municipio6) msavar(msa_duranton_`d') secvar(edu) keepif(totalpop>100000) ///
    geodemopop(headcount) msapop(totalpop) demovar(edu race age female) ///
    tablefilename(../output/hce_pop_wage_Census2010_lowerpanel) ctitle(Commuting: `d')
  }
//Arranjos: HKE
estimationarray_hce_pop, geovardemovarnormfile(../input/BR_MUNICIPIO_demowages_Census2010.dta) ///
  geovarmsavarnormfile(../input/municipios_2010.dta) ///
  msavarnormfile(../input/msa_arranjopop_2010.dta) ///
  geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) geovarsecvarpop(edupop) ///
  incvar(wage) geovar(municipio6) msavar(msa_arranjo) secvar(edu) keepif(totalpop>100000) ///
  geodemopop(headcount) msapop(totalpop) demovar(edu race age female) ///
  tablefilename(../output/hce_pop_wage_Census2010_lowerpanel) ctitle(Arranjos)
//Microregions: HKE
estimationarray_hce_pop, geovardemovarnormfile(../input/BR_MUNICIPIO_demowages_Census2010.dta) ///
  geovarmsavarnormfile(../input/municipios_2010.dta) ///
  msavarnormfile(../input/msa_microrregiopop_2010.dta) ///
  geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) geovarsecvarpop(edupop) ///
  incvar(wage) geovar(municipio6) msavar(msa_microrregio) secvar(edu) keepif(totalpop>100000) ///
  geodemopop(headcount) msapop(totalpop) demovar(edu race age female) ///
  tablefilename(../output/hce_pop_wage_Census2010_lowerpanel) ctitle(Microregions)
