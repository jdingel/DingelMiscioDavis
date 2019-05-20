# full comptable
cat ../output/edupop_elasticities_Census2010_msa_compare.tex |\
sed 's/VARIABLES/\\cmidrule(lr){2-4}\\cmidrule(lr){5-7}/' |\
sed 's/ \& (1) \& (2) \& (3) \& (4) \& (5) \& (6) \& (7) \& (8) \\\\//' |\
sed 's/duranton \& duranton \& duranton/\\multicolumn{3}{c}{Commuting}/' |\
sed 's/night \& night \& night/\\multicolumn{3}{c}{Nightlights}/' |\
sed 's/arranjo \& microrregio/ Arranjos \& Microregions/' |\
sed 's/\\begin{footnotesize}\\end{footnotesize}//g' |\
sed 's/\$\\times\$ log population \&/\&/' |\
sed 's/No schooling \&/No schooling (\$\\beta_1\$) \&/' |\
sed 's/Elementary Graduate \&/Elementary graduate (\$\\beta_2\$) \&/' |\
sed 's/High School Graduate \&/High school graduate (\$\\beta_3\$) \&/' |\
sed 's/College Graduate \&/College graduate (\$\\beta_4\$) \&/' |\
sed 's/cc} \\hline/cc} \\toprule/' |\
sed 's/^\\end{tabular}/\\bottomrule \\end{tabular}/' |\
sed 's/\\begin{center}//' |\
sed 's/\\end{center}//' |\
sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' |\
sed '/^$/d' \
> ../output/edupop_elasticities_Census2010_msa_compare_clean.tex

# Cohort regressions

# commuting
sed 's/VARIABLES/Cohort: /' ../output/agepop_edupop_elasticities_Census2010_msa_duranton.tex |\
sed 's/1 \& 2 \& 3/25-34 \& 35-44 \& 45-54/g' |\
sed 's/ Commute \& Commute \& Commute \& Commute \& Commute \& Commute \& Commute \& Commute \& Commute \\\\/\\multicolumn{9}{c}{Commuting Flow Threshold} \\\\ \\cmidrule(lr){2-10}/' |\
sed 's/ 5 \& 5 \& 5 \& 15 \& 15 \& 15 \& 25 \& 25 \& 25 \\\\/\\multicolumn{3}{c}{5\%} \& \\multicolumn{3}{c}{15\%} \& \\multicolumn{3}{c}{25\%} \\\\ \\cmidrule(lr){2-4}\\cmidrule(lr){5-7}\\cmidrule(lr){8-10}/' |\
sed 's/ \& (1) \& (2) \& (3) \& (4) \& (5) \& (6) \& (7) \& (8) \& (9) \\\\//' |\
sed 's/ \& Age \& Age \& Age \& Age \& Age \& Age \& Age \& Age \& Age \\\\//' |\
sed 's/\$\\times\$ log population \&/\&/' |\
sed 's/No schooling \&/No schooling (\$\\beta_1\$) \&/' |\
sed 's/Elementary Graduate \&/Elementary graduate (\$\\beta_2\$) \&/' |\
sed 's/High School Graduate \&/High school graduate (\$\\beta_3\$) \&/' |\
sed 's/College Graduate \&/College graduate (\$\\beta_4\$) \&/' |\
sed 's/cc} \\hline/cc} \\toprule/' |\
sed 's/^\\end{tabular}/\\bottomrule \\end{tabular}/' |\
sed 's/\\begin{center}//' |\
sed 's/\\end{center}//' |\
sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' |\
sed '/^$/d' \
> ../output/agepop_edupop_elasticities_Census2010_duranton_clean.tex

# lights at night
sed 's/VARIABLES/Cohort: /' ../output/agepop_edupop_elasticities_Census2010_msa_night.tex |\
sed 's/1 \& 2 \& 3/25-34 \& 35-44 \& 45-54/g' |\
sed 's/ Lights \& Lights \& Lights \& Lights \& Lights \& Lights \& Lights \& Lights \& Lights \\\\/\\multicolumn{9}{c}{Light Intensity} \\\\ \\cmidrule(lr){2-10}/' |\
sed 's/ 10 \& 10 \& 10 \& 30 \& 30 \& 30 \& 50 \& 50 \& 50 \\\\/\\multicolumn{3}{c}{10} \& \\multicolumn{3}{c}{30} \& \\multicolumn{3}{c}{50} \\\\ \\cmidrule(lr){2-4}\\cmidrule(lr){5-7}\\cmidrule(lr){8-10}/' |\
sed 's/ \& (1) \& (2) \& (3) \& (4) \& (5) \& (6) \& (7) \& (8) \& (9) \\\\//' |\
sed 's/ \& Age \& Age \& Age \& Age \& Age \& Age \& Age \& Age \& Age \\\\//' |\
sed 's/\$\\times\$ log population \&/\&/' |\
sed 's/No schooling \&/No schooling (\$\\beta_1\$) \&/' |\
sed 's/Elementary Graduate \&/Elementary graduate (\$\\beta_2\$) \&/' |\
sed 's/High School Graduate \&/High school graduate (\$\\beta_3\$) \&/' |\
sed 's/College Graduate \&/College graduate (\$\\beta_4\$) \&/' |\
sed 's/cc} \\hline/cc} \\toprule/' |\
sed 's/^\\end{tabular}/\\bottomrule \\end{tabular}/' |\
sed 's/\\begin{center}//' |\
sed 's/\\end{center}//' |\
sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' |\
sed '/^$/d' \
> ../output/agepop_edupop_elasticities_Census2010_night_clean.tex
