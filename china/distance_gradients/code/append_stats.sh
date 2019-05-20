# append p-values and N_clusters from Cross-equation test
sed 's/\\bottomrule/\$p\$-value for difference \nClusters \n\\bottomrule/' ../output/distance_gradient_college_2000_nostats.tex > ../output/temp.tex
x=$(grep -n '\$\p\$-value for difference' ../output/temp.tex | cut -d : -f 1)
y=$(grep -n 'Clusters' ../output/temp.tex | cut -d : -f 1)
for bright in {10..60..10}
do
  p_val=$(head -1 ../output/college_distance_gradient_ntl${bright}_townships_counties_tstat.txt)
  clust=$(tail -1 ../output/college_distance_gradient_ntl${bright}_townships_counties_tstat.txt)
  sed -i "${x}s/$/ \& ${p_val}/" ../output/temp.tex
  sed -i "${y}s/$/ \& ${clust}/" ../output/temp.tex
done
sed "${x}s/$/ \\\\\\\\/" ../output/temp.tex | sed "${y}s/$/ \\\\\\\\/" > ../output/distance_gradient_college_2000.tex
rm ../output/temp.tex
