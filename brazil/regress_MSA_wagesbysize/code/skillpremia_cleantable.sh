sed 's/VARIABLES//' ../output/skillpremia3_Census2010_upperpanel.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/cc} \\hline/cc} \\toprule/' \
| sed 's/Log of Total MSA population/Metro log population/' \
| sed 's/\& Lights: 10/Light threshold \& 10/' \
| grep -v '(1) \& (2)' \
| sed 's/Lights://g' \
| sed 's/Observations \(.*\) \\hline/Number of metropolitan areas \1/' \
| grep -v '\\end{tabular}'  | grep -v '\\begin{center}' | grep -v '\\end{center}' \
> ../output/skillpremia3_Census2010.tex

echo "\midrule & \multicolumn{3}{c}{Commuting} & Arranjos & Microregions \\\\ \cline{2-4} " >> ../output/skillpremia3_Census2010.tex

sed 's/VARIABLES//' ../output/skillpremia3_Census2010_lowerpanel.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/\\end{tabular}/\\bottomrule \\end{tabular}/' \
| sed 's/Log of Total MSA population/Metro log population/' \
| sed 's/\& Commuting: 5/Threshold \& 5/' \
| sed 's/Commuting://g' \
| sed 's/Arranjos \& Microregions/ NA \& NA/' \
| grep -v ' \& (1) \& (2)' \
| sed 's/Observations \(.*\) \\hline/Number of metropolitan areas \1/' \
| grep -v '\\begin{tabular}' | grep -v '\\begin{center}' | grep -v '\\end{center}' \
>> ../output/skillpremia3_Census2010.tex
