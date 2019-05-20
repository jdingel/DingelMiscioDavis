sed 's/VARIABLES//' ../output/distance_gradient_college_upperpanel.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/cc} \\hline/cc} \\toprule/' \
| sed 's/Distance to MSA center (as fraction of MSA radius)/Distance to metro center/' \
| sed 's/\& Lights: 10/Light threshold \& 10/' \
| grep -v '(1) \& (2)' \
| sed 's/Lights://g' \
| grep -v '\\end{tabular}'| grep -v '\\begin{center}'| grep -v '\\end{center}' \
| sed 's/Observations/Number of municipios/' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
> ../output/distance_gradient_college_nostats.tex

echo "\midrule & \multicolumn{3}{c}{Commuting} & Arranjos & Microregions \\\\ \cline{2-4} " >> ../output/distance_gradient_college_nostats.tex

sed 's/VARIABLES//' ../output/distance_gradient_college_lowerpanel.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/\\end{tabular}/\\bottomrule \\end{tabular}/' \
| sed 's/Distance to MSA center (as fraction of MSA radius)/Distance to metro center/' \
| sed 's/\& Commuting: 5/Threshold \& 5/' \
| sed 's/Commuting://g' \
| sed 's/Arranjos \& Microregions/ NA \& NA/' \
| grep -v ' \& (1) \& (2)' \
| grep -v '\\begin{tabular}'| grep -v '\\begin{center}'| grep -v '\\end{center}' \
| sed 's/Observations/Number of municipios/' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
>> ../output/distance_gradient_college_nostats.tex

sed 's/VARIABLES//' ../output/distance_gradient_college_upperpanel_dist2.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/cc} \\hline/cc} \\toprule/' \
| sed 's/Distance to MSA center (as fraction of MSA radius)/Distance to metro center/' \
| sed 's/\& Lights: 10/Light threshold \& 10/' \
| grep -v '(1) \& (2)' \
| sed 's/Lights://g' \
| grep -v '\\end{tabular}'| grep -v '\\begin{center}'| grep -v '\\end{center}' \
| sed 's/Observations/Number of municipios/' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
> ../output/distance_gradient_college_dist2.tex

echo "\midrule & \multicolumn{3}{c}{Commuting} & Arranjos & Microregions \\\\ \cline{2-4} " >> ../output/distance_gradient_college_dist2.tex

sed 's/VARIABLES//' ../output/distance_gradient_college_lowerpanel_dist2.tex \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/\\end{tabular}/\\bottomrule \\end{tabular}/' \
| sed 's/Distance to MSA center (as fraction of MSA radius)/Distance to metro center/' \
| sed 's/\& Commuting: 5/Threshold \& 5/' \
| sed 's/Commuting://g' \
| sed 's/Arranjos \& Microregions/ NA \& NA/' \
| grep -v ' \& (1) \& (2)' \
| grep -v '\\begin{tabular}'| grep -v '\\begin{center}'| grep -v '\\end{center}' \
| sed 's/Observations/Number of municipios/' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
>> ../output/distance_gradient_college_dist2.tex
