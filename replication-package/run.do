************************************************
* run.do
* Master script for replication package
************************************************

clear all
set more off

cd ".."
cd "C:/Users/Window/Desktop/Dottorato_CCA/Replication_package"

pwd

* Load configuration
do "code/configuration/configuration.do"

* Create folders if needed
cap mkdir "${output}"
cap mkdir "${processed}"
cap mkdir "${descriptives_table}"

* 0 = use provided appended .dta file
* 1 = rebuild appended .dta file from raw TXT files
global rebuild_from_raw 0

* From txt to dta and append the whole dataset
pwd
if $rebuild_from_raw == 1{
	do "code/import_append/01_import_and_append_lfs.do"
}

* Construct variables and save the final sample
pwd
do "code/processed/02_build_analysis_dataset.do"

* Descriptive statistics
do "code//descriptives/03_descriptives_stats.do"

display "Replication completed successfully"
