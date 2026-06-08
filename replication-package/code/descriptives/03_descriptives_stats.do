************************************************
* 03_descriptives_stats.do
* Produce descriptive statistics table
************************************************

clear all

* Load analysis dataset
use "${processed}/analysis_dataset.dta", clear

************************************************
* Variables for Descriptive Statistics
************************************************

* Macroarea of residence based on region of residence
gen macroarea = .
replace macroarea = 1 if inlist(reg, 1, 2, 3, 7)
replace macroarea = 2 if inlist(reg, 4, 5, 6, 8)
replace macroarea = 3 if inlist(reg, 9, 10, 11, 12)
replace macroarea = 4 if inlist(reg, 13, 14, 15, 16, 17, 18)
replace macroarea = 5 if inlist(reg, 19, 20)

label define macroarea 1 "Northwest" 2 "Northeast" 3 "Center" 4 "South" 5 "Islands"
label values macroarea macroarea
label var macroarea "macroarea of residence"

* Sample groups by treatment status and Bologna Process period
gen sub_sample = .
replace sub_sample = 0 if eligible == 0 & postBP == 0
replace sub_sample = 1 if eligible == 0 & postBP == 1
replace sub_sample = 2 if eligible == 1 & postBP == 0
replace sub_sample = 3 if eligible == 1 & postBP == 1

label define sub_sample 0 "C pre-BP" 1 "C post-BP" 2 "T pre-BP" 3 "T post-BP"
label values sub_sample sub_sample
label var sub_sample "treatment and period groups"

* Female indicator
rename sg11 sex
replace sex = sex - 1

label define sex 0 "male" 1 "female"
label values sex sex
label var sex "female"

************************************************
* Table Labels
************************************************

label var age_degree     "Age at graduation"
label var married        "Ever married"
label var age_marriage   "Age at marriage"
label var atleast_1child "At least one child"
label var more_1child    "More than one child"
label var age_1ch        "Age at first child"
label var sex            "Female"
label var etam           "Age at survey"

************************************************
* Descriptive Statistics Table
************************************************

dtable age_degree married age_marriage atleast_1child ///
       more_1child age_1ch sex etam i.macroarea ///
       [pweight = coef] if anno >= 2013, ///
       by(sub_sample, nototal) ///
       nformat(%9.2f mean sd) ///
       sample(Obs., statistics(freq) place(items)) ///
       factor(i.macroarea, statistics(fvpercent)) ///
       export("${destab}/descriptive_statistics.tex", replace)
