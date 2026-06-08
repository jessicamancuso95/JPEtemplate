************************************************
* 01_import_and_append_lfs.do
* Import ISTAT Labour Force Survey TXT files
* and append quarterly datasets, 2009q1-2020q4
************************************************

clear all

* Quarter names as used in the original ISTAT file names
local quarters "Primo Secondo Terzo Quarto"

* Temporary file used to progressively store the appended dataset
tempfile full_lfs
local first = 1

forvalues y = 2014/2020 {
    
    foreach q of local quarters {
        
        * Path to the quarterly raw TXT file
        local file "${raw}/LFS_`y'/RCFL_Microdati_Anno_`y'_`q'_trimestre.txt"
        
        display as result "Importing: `file'"
        
        import delimited using "`file'", ///
            varnames(1) ///
            clear
        
        * Track source year and quarter
        gen year_file = `y'
        gen quarter_file = "`q'"
        
        compress
        
        if `first' {
            save `full_lfs', replace
            local first = 0
        }
        else {
            append using `full_lfs'
            save `full_lfs', replace
        }
    }
}

use `full_lfs', clear

save "${processed}/lfs_istat_2009_2020_appended.dta", replace