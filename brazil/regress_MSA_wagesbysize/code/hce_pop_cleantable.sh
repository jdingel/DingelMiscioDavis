sed 's/VARIABLES//' ../output/hce_pop_wage_Census2010_upperpanel.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/cc} \\hline/cc} \\toprule/' \
| sed 's/Log of Total MSA population/Log population/' \
| sed 's/MSA share of college graduates/College graduate share/' \
| sed 's/\& Lights: 10/Light threshold \& 10/' \
| grep -v '(1) \& (2)' \
| sed 's/Lights://g' \
| grep -v '\\end{tabular}' | grep -v '\\begin{center}' | grep -v '\\end{center}' \
| sed 's/Full Sample \& 3531662 \& 3160137 \& 3100987 \& 3036406 \& 2979547 \\\\//' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
> ../output/hce_pop_wage_Census2010.tex

echo "\midrule & \multicolumn{3}{c}{Commuting} & Arranjos & Microregions \\\\ \cline{2-4} " >> ../output/hce_pop_wage_Census2010.tex

sed 's/VARIABLES//' ../output/hce_pop_wage_Census2010_lowerpanel.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/\\end{tabular}/\\bottomrule \\end{tabular}/' \
| sed 's/Log of Total MSA population/Log population/' \
| sed 's/MSA share of college graduates/College graduate share/' \
| sed 's/\& Commuting: 5/Threshold \& 5/' \
| sed 's/Commuting://g' \
| sed 's/Arranjos \& Microregions/ NA \& NA/' \
| grep -v ' \& (1) \& (2)' \
| grep -v '\\begin{tabular}' | grep -v '\\begin{center}' | grep -v '\\end{center}' \
| sed 's/Full Sample \& 3589723 \& 3032454 \& 2887249 \& 3176523 \& 6416214 \\\\//' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
>> ../output/hce_pop_wage_Census2010.tex
