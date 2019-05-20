qui do "programs.do"

edu_shares_china, msavar(msa30_night)
listtex edu_ch share_global_ch share_msa_100k_ch using "../output/edu_shares_msa30_night.tex", replace ///
        rstyle(tabular) ///
        head("\begin{tabular}{lcc} \toprule" "China & All & Metro \\ \midrule") ///
        foot("\bottomrule \end{tabular}")
