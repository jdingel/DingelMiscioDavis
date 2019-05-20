set more off
qui do "programs.do"

/************************************
** Skill premia across MSAs
************************************/

//Clear old output
cap rm ../output/skillpremia3_Census2010_upperpanel.tex
cap rm ../output/skillpremia3_Census2010_upperpanel.txt
cap rm ../output/skillpremia3_Census2010_lowerpanel.tex
cap rm ../output/skillpremia3_Census2010_lowerpanel.txt

//Nightlights
forvalues x = 10(10)50 {
  estimationarray_skillpremia, geovardemovarnormfile(../input/BR_MUNICIPIO_eduwages_Census2010.dta) ///
    geovarmsavarnormfile(../input/municipios_2010.dta) ///
    msavarnormfile(../input/msa_night_`x'pop_2010.dta) ///
    incvar(wage) geovar(municipio6) msavar(msa_night_`x') keepif(totalpop>100000) ///
    geodemopop(headcount) msapop(totalpop) skill(skill3) skillpremia(skillpremia3) ///
    tablefilename(../output/skillpremia3_Census2010_upperpanel) ctitle(Lights: `x')
}
//Commuting
forvalues d = 5(10)25 {
  estimationarray_skillpremia, geovardemovarnormfile(../input/BR_MUNICIPIO_eduwages_Census2010.dta) ///
    geovarmsavarnormfile(../input/municipios_2010.dta) ///
    msavarnormfile(../input/msa_duranton_`d'pop_2010.dta) ///
    incvar(wage) geovar(municipio6) msavar(msa_duranton_`d') keepif(totalpop>100000) ///
    geodemopop(headcount) msapop(totalpop) skill(skill3) skillpremia(skillpremia3) ///
    tablefilename(../output/skillpremia3_Census2010_lowerpanel) ctitle(Commuting: `d')
}
//Arranjos
estimationarray_skillpremia, geovardemovarnormfile(../input/BR_MUNICIPIO_eduwages_Census2010.dta) ///
  geovarmsavarnormfile(../input/municipios_2010.dta) ///
  msavarnormfile(../input/msa_arranjopop_2010.dta) ///
  incvar(wage) geovar(municipio6) msavar(msa_arranjo) keepif(totalpop>100000) ///
  geodemopop(headcount) msapop(totalpop) skill(skill3) skillpremia(skillpremia3) ///
  tablefilename(../output/skillpremia3_Census2010_lowerpanel) ctitle(Arranjos)
//Microregions
estimationarray_skillpremia, geovardemovarnormfile(../input/BR_MUNICIPIO_eduwages_Census2010.dta) ///
  geovarmsavarnormfile(../input/municipios_2010.dta) ///
  msavarnormfile(../input/msa_microrregiopop_2010.dta) ///
  incvar(wage) geovar(municipio6) msavar(msa_microrregio) keepif(totalpop>100000) ///
  geodemopop(headcount) msapop(totalpop) skill(skill3) skillpremia(skillpremia3) ///
  tablefilename(../output/skillpremia3_Census2010_lowerpanel) ctitle(Microregions)
