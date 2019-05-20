qui do "programs.do"

edu_shares_india, msavar(MSACode)
listtex edu_ind share_global_ind share_msa_100k_ind  using "../output/edu_shares_UA.tex", replace ///
  rstyle(tabular) ///
  head("\begin{tabular}{lcc} \toprule" "India & All & Metro \\ \midrule") ///
  foot("\bottomrule \end{tabular}")
