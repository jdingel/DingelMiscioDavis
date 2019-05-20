sed 's/VARIABLES//'  ../output/distance_gradient_college_townships_2000_msa_night.tex  \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/cc} \\hline/cc} \\toprule/' \
| sed 's/\(60 \\\\ \\hline\)/\1 \n \\multicolumn{4}{l}{\\textit{Panel A: Township-based metropolitan areas}} \\\\ /' \
| sed 's/Distance to MSA center (as fraction of MSA radius)/Distance to metro center/' \
| sed 's/\& Lights: 10/Light threshold \& 10/' \
| sed 's/^ \& 10/Light threshold: \& 10/' \
| grep -v '(1) \& (2)' \
| sed 's/Lights://g' \
| grep -v 'Lights \& Lights' \
| grep -v '\\end{tabular}' | grep -v '\\begin{center}' | grep -v '\\end{center}' \
| sed 's/Observations/Number of townships/' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
> ../output/distance_gradient_college_2000_nostats.tex

echo "\midrule" >> ../output/distance_gradient_college_2000_nostats.tex

sed 's/VARIABLES//' ../output/distance_gradient_college_counties_2000_msa_night.tex  \
| sed 's/\\begin{footnotesize}\\end{footnotesize}//g' \
| sed 's/\\end{tabular}/\\bottomrule \\end{tabular}/' \
| sed 's/\(60 \\\\ \\hline\)/\1 \n \\multicolumn{4}{l}{\\textit{Panel B: County-based metropolitan areas}} \\\\ /' \
| sed 's/Distance to MSA center (as fraction of MSA radius)/Distance to metro center/' \
| sed 's/\& Lights: 10/Light threshold \& 10/' \
| grep -v '(1) \& (2)' \
| sed 's/Lights://g' \
| grep -v 'Lights \& Lights' \
| grep -v 'Light threshold' \
| grep -v '\& 10 \& 20 \& 30' \
| grep -v '\\begin{tabular}' | grep -v '\\begin{center}' | grep -v '\\end{center}' \
| sed 's/Observations/Number of counties/' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
>> ../output/distance_gradient_college_2000_nostats.tex
