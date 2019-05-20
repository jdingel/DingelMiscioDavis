use "../input/municipios_2010.dta", clear

order municipio7 nome_municipio lat lon ///
      uf nome_uf microrregio nome_microrregio arranjo msa_duranton* msa_night*

drop year municipio6 urbanpop ruralpop  ///
     mesorregio nome_mesorregio ///
     msa_microrregio msa_mesorregio ///
     msa_ibge_recode msa_arranjo

outsheet municipio7 nome_municipio lat lon population area_km2 ///
         uf nome_uf microrregio nome_microrregio arranjo ///
         msa_duranton* msa_night* ///
         using "../output/municipios_2010.csv", comma replace
