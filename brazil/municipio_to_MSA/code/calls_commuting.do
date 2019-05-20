set more off
qui do "programs.do"

MSAcreate, thresh(5)  filename(CENSO10_commuting) saveas(geo_crosswalk_5)
MSAcreate, thresh(10) filename(CENSO10_commuting) saveas(geo_crosswalk_10)
MSAcreate, thresh(15) filename(CENSO10_commuting) saveas(geo_crosswalk_15)
MSAcreate, thresh(20) filename(CENSO10_commuting) saveas(geo_crosswalk_20)
MSAcreate, thresh(25) filename(CENSO10_commuting) saveas(geo_crosswalk_25)
