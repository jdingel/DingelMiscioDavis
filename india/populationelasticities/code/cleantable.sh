# India population elasticities (2001) table
sed 's/ \& (1) \& (2) \& (3) \\\\//' ../output/edu_popelasticity_B9_4scheme_2001.tex \
| sed 's/VARIABLES \& 0 \& .8 \& .95/Inclusion threshold: \& None \& 0.8 \& 0.95/' \
| sed 's/\& Urban Agglomerations //g' \
| sed 's/^ \\\\$//' \
| sed 's/cc} \\hline/cc} \\toprule/' \
|	sed 's/\\begin{center}//' \
|	sed 's/\\end{center}//' \
| sed 's/\$\\times\$ log population \&/\&/' \
| sed 's/No education \&/No education (\$\\beta_1\$) \&/' \
| sed 's/Primary \&/Primary (\$\\beta_2\$) \&/' \
| sed 's/Secondary \&/Secondary (\$\\beta_3\$) \&/' \
| sed 's/College graduate \&/College graduate (\$\\beta_4\$) \&/' \
| sed 's/Number of geographic units \(.*\) \\hline/Number of metropolitan areas \1/' \
| sed 's/^\\end{tabular}/\\bottomrule \\end{tabular}/' \
> ../output/edu_popelasticity_B9_4scheme_2001_clean.tex
