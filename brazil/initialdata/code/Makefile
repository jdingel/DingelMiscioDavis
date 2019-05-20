# Definitions
folders=slurmlogs ../input ../output

shp_file_ext := shp shx dbf qpj prj
output_shp_file_ext := shp shx dbf prj
states_list := AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO

input=\
	$(foreach state,$(states_list),../input/CENSO10_$(state)_pes.dta)\
	../input/CENSO10_pes.dta \
	../input/tab3_1.xls \
	../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.xls \
	../input/MCARPs_Chauvin2017.dta \
	$(foreach ext,$(shp_file_ext),../input/all_Municipios_epsg4326.$(ext))

output1=\
	../output/tab3_1.xls \
	../output/census_popmun_1872-2010.xls \
	../output/MCARPs_Chauvin2017.dta 

output2= ../output/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta

output3=\
	../output/F152000.v4b_web.stable_lights.avg_vis.tif \
	../output/F182010.v4d_web.stable_lights.avg_vis.tif

output4=$(foreach ext,$(output_shp_file_ext),../output/municipios_2010.$(ext))

output5= 	../output/CENSO10_pes.dta $(foreach state,$(states_list),../output/CENSO10_$(state)_pes.dta)

# Recipes
all: $(folders) $(output1) $(output2) $(output3) $(output4) $(output5)

$(folders):
	mkdir $@

#required inputs that you have to download from elsewhere
#../input/CENSO10_pes.dta: #To obtain this file, see CENSO10_pes_dta_metadata.txt
#$(foreach state,$(states_list),../input/CENSO10_$(state)_pes.dta):  #To obtain these files, see CENSO10_pes_dta_metadata.txt

$(foreach ext,$(shp_file_ext),../input/all_Municipios_epsg4326.$(ext)): | ../input/all_Municipios_epsg4326.zip
	unzip ../input/all_Municipios_epsg4326.zip -d ../input

# symbolic links
../output/Brazil_2010_mapping_municipios_msa%_raw.csv:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/tab3_1.xls:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/census_popmun_1872-2010.xls:
	wget "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/municipios_1872_1991/Documentacao/pop_mun_TUR_1872_a_2010.xls" -O $@
../output/MCARPs_Chauvin2017.dta:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/CENSO10_pes.dta:  ../input/CENSO10_pes.dta
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi

# retrieved from web
../output/F152000.v4b_web.stable_lights.avg_vis.tif:
	wget "https://ngdc.noaa.gov/eog/data/web_data/v4composites/F152000.v4.tar" -O ../input/F152000.v4.tar
	tar -C ../output/ -xvf ../input/F152000.v4.tar
	gunzip ../output/F152000.v4b_web.stable_lights.avg_vis.tif.gz
../output/F182010.v4d_web.stable_lights.avg_vis.tif:
	wget "https://ngdc.noaa.gov/eog/data/web_data/v4composites/F182010.v4.tar" -O ../input/F182010.v4.tar
	tar -C ../output/ -xvf ../input/F182010.v4.tar
	gunzip ../output/F182010.v4d_web.stable_lights.avg_vis.tif.gz

# produced outputs
../output/CENSO10_%_pes.dta: data_relabeling.do run.sbatch ../input/CENSO10_%_pes.dta | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e data_relabeling.do; fi

../output/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta: ../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.xls importfiles.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e importfiles.do; fi

$(foreach ext,$(output_shp_file_ext),../output/municipios_2010.$(ext)): modify.R run_modify.sbatch $(foreach ext,$(shp_file_ext),../input/all_Municipios_epsg4326.$(ext))
	if command -v sbatch > /dev/null ; then sbatch -W run_modify.sbatch ; else Rscript modify.R ; fi
