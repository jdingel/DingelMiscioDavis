## NTL 2000 table
sed 's/VARIABLES/\\cmidrule(lr){2-4}\\cmidrule(lr){5-7} Light intensity threshold:/' ../output/popelast_eduagg_2000_100k_townships_counties_raw.tex \
| sed 's/^ \& (1) \& (2) \& (3) \& (4) \& (5) \& (6).*\\\\//' \
| sed 's/Township-based \& Township-based \& Township-based/\\multicolumn{3}{c}{Township-based}/' \
| sed 's/County-based \& County-based \& County-based/\\multicolumn{3}{c}{County-based}/' \
| sed 's/cc} \\hline/cc} \\toprule/' \
|	sed 's/^\\end{tabular}/\\bottomrule \\end{tabular}/' \
|	sed 's/\\begin{center}//' \
|	sed 's/\\end{center}//' \
|	sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
|	sed 's/\$\\times\$ log population \&/\&/' \
|	sed 's/Primary school or less \&/Primary school or less (\$\\beta_1\$) \&/' \
|	sed 's/Middle school \&/Middle school (\$\\beta_2\$) \&/' \
|	sed 's/High school \&/High school (\$\\beta_3\$) \&/' \
|	sed 's/College or university \&/College or university (\$\\beta_4\$) \&/' \
| sed '/^$/d' \
> ../output/popelast_eduagg_2000_100k_townships_counties.tex
