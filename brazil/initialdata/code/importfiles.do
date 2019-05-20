cap mkdir "../output", public
import excel using "../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.xls", clear cellrange(A3) firstrow case(lower)
rename (mesorregião nome_mesorregião microrregião nome_microrregião município nome_município) ///
	   (mesorregio  nome_mesorregio  microrregio  nome_microrregio  municipio nome_municipio)
destring uf mesorregio microrregio municipio, replace
save "../output/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta", replace
