qui do "programs_2001.do"
qui do "programs_2011.do"

// 2001
normalized_towns, saveas(../output/town_2001.dta)
normalized_MSA using "../output/town_2001.dta", saveas(../output/MSAs_2001.dta)
normalized_districts

edu_town_count7 using "../input/B_9_City_india.xls",  ///
						saveas_B9("../output/all_India_series_B9City.dta") ///
						saveas_sample("../output/town_edu_count.dta")

edu_town_count4 using "../output/town_edu_count.dta", ///
						saveas("../output/town_edu_count_4Groups.dta")

edu_totalPop_9 using "../input/C_8_City_India.xls", ///
						saveas_C8_city("../output/all_India_series_C8City.dta") ///
						saveas_sample("../output/town_edu_count_AllPop.dta")

edu_totalPop_9_state using "../input/C_8_India.xls", ///
						saveas_C8_state("../output/all_India_series_C8.dta") ///
						saveas_sample("../output/town_edu_count_AllPop_state.dta")

edu_totalPop_4 using "../output/town_edu_count_AllPop.dta", ///
						saveas("../output/town_edu_count_AllPop_4Groups.dta")

// 2011
edu_town_count7_2011 using "../input/DDWCITY_B_09_0000.xlsx", ///
	saveas_B9("../output/all_India_series_B9City_2011.dta") ///
	saveas_sample("../output/town_edu_count_2011.dta")

edu_town_count4_2011 using "../output/town_edu_count_2011.dta", ///
	saveas("../output/town_edu_count_4Groups_2011.dta")

edu_totalPop_9_2011 using "../input/DDWCT_0000C_08.xlsx", saveas("../output/town_edu_count_AllPop_2011.dta")

edu_totalPop_4_2011 using "../output/town_edu_count_AllPop_2011.dta", saveas("../output/town_edu_count_AllPop_4Groups_2011.dta")
