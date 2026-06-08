************************************************
* 02_build_analysis_dataset.do
* Build analysis dataset from appended ISTAT LFS data
************************************************

clear all

* Load appended dataset
use "${processed}/lfs_istat_2009_2020_appended.dta", clear

************************************************
* Initial Data Cleaning
************************************************

* Keep first-wave interviews only
keep if wavqua == 1

* Convert string variables used in the analysis to numeric format
destring tistud sg25 sg26 sg27 sg27a amatri dovris regpre propre i12 i13, replace

* Create household and individual identifiers by quarter and year
gen mfrhh_trimyear = string(trim, "%02.0f") + substr(string(anno, "%04.0f"), 3, 2) + string(mfrfam)
label var mfrhh_trimyear "household identifier by quarter and year"
destring mfrhh_trimyear, replace

gen mfrind_trimyear = string(trim, "%02.0f") + substr(string(anno, "%04.0f"), 3, 2) + string(mfrind)
label var mfrind_trimyear "individual identifier by quarter and year"
destring mfrind_trimyear, replace

* Harmonize highest education variable across survey years
gen highest_educ = .
replace highest_educ = tistud if anno >= 2014

* Compute approximate year of university enrollment
gen year_enrollment = .
replace year_enrollment = anno - etam + 19 - 1 if inlist(trim, 1, 2)
replace year_enrollment = anno - etam + 19     if inlist(trim, 3, 4)


************************************************
* Main Outcome Variables
************************************************

* Age at graduation
gen age_degree = etam - (anno - sg26) if sg26 != . & sg26 != 997 & sg26 != 998
replace age_degree = sg27 if sg26 == . | sg26 == 997 | sg26 == 998

* Number of children for reference persons and their partners
gen children1 = inlist(relpar, 6, 7)
label var children1 "1 = child of reference person and/or partner; 0 = otherwise"

bysort mfrhh_trimyear (mfrind_trimyear): egen total_children = total(children1)
gen num_children = total_children if inlist(relpar, 1, 2, 3)
label var num_children "number of children"

* Number of children for other household members
gen children2 = inlist(relpar, 10, 11)
label var children2 "1 = child of other household member; 0 = otherwise"

bysort mfrhh_trimyear (mfrind_trimyear): egen total_children2 = total(children2)
replace num_children = total_children2 if inlist(relpar, 6, 7, 8, 9)


* Indicators for fertility outcomes
gen atleast_1child = (num_children > 0 & num_children != .)
label var atleast_1child "1 = has at least one child; 0 = otherwise"

gen more_1child = (num_children > 1 & num_children != .)
label var more_1child "1 = has more than one child; 0 = otherwise"

* Marriage indicator
gen married = (amatri != .)
label var married "1 = ever married; 0 = otherwise"

* Age at marriage
gen age_marriage = amatri - (anno - etam) if amatri != . & amatri > 1900
label var age_marriage "age at marriage"

* Age at first child
bysort mfrhh_trimyear: egen first_child = max(etam) if inlist(relpar, 6, 7)
bysort mfrhh_trimyear: egen hh_first_child = max(first_child)
gen age_1ch = etam - hh_first_child if inlist(relpar, 1, 2, 3)

drop first_child hh_first_child

label var age_1ch "age at first child"


************************************************
* Analysis Sample Definition
************************************************

* Keep cohorts enrolled between 1993 and 2006
keep if inrange(year_enrollment, 1993, 2006)

* Drop early adopters
drop if year_enrollment == 2000

* Keep individuals with tertiary education
keep if inrange(highest_educ, 8, 10)


************************************************
* Treatment Definition
************************************************

* Treatment dummy
gen eligible = .
replace eligible = 1 if sg25 != 23 & sg25 != 24 & year_enrollment < 2001
replace eligible = 1 if inlist(highest_educ, 8, 9) & year_enrollment >= 2001
replace eligible = 0 if highest_educ == 10 & inlist(sg25, 23, 24)

label define eligible 0 "control group" 1 "treatment group"
label values eligible eligible
label var eligible "treatment group"

* Avoid treatment-status misclassification
drop if inlist(highest_educ, 8, 9) & year_enrollment < 2001
drop if eligible >= 1 & year_enrollment > 1999 & highest_educ == 10

* Pre/post Bologna Process indicator
gen postBP = .
replace postBP = 1 if inrange(year_enrollment, 2001, 2006)
replace postBP = 0 if inrange(year_enrollment, 1993, 1999)

label define postBP 0 "pre Bologna Process" 1 "post Bologna Process"
label values postBP postBP
label var postBP "post Bologna Process"

************************************************
* Save Final Analytical Dataset
************************************************

save "${processed}/analysis_dataset.dta", replace