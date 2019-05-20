#!/bin/bash

#Run this script if you want to skip Brazilian microdata download and all associated tasks.

mkdir initialdata/output/
echo 'skipping microdata' > initialdata/input/CENSO10_pes.dta
echo 'skipping microdata' > initialdata/output/CENSO10_pes.dta

for state in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO 
do
	echo 'skipping microdata' > initialdata/input/CENSO10_${state}_pes.dta
	echo 'skipping microdata' > initialdata/output/CENSO10_${state}_pes.dta
done

unzip census_microdata/output.zip -d census_microdata
touch census_microdata/output/*.dta

unzip municipio_to_MSA/output/CENSO10_commuting.dta.zip -d municipio_to_MSA/output/
touch municipio_to_MSA/output/CENSO10_commuting.dta

unzip compute_municipio_wages/output/BR_MUNICIPIO_demowages_Census2010.dta.zip -d compute_municipio_wages/output/
unzip compute_municipio_wages/output/BR_MUNICIPIO_eduwages_Census2010.dta.zip -d compute_municipio_wages/output/
touch compute_municipio_wages/output/BR_MUNICIPIO_demowages_Census2010.dta
touch compute_municipio_wages/output/BR_MUNICIPIO_eduwages_Census2010.dta
