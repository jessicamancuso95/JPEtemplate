************************************************
* configuration.do
* Project configuration
************************************************

version 18
clear all
set more off

* Root directory
global path "`c(pwd)'"

* Folders
global code      "${path}/code"
global data      "${path}/Data"
global raw       "${data}/raw_data"
global processed "${data}/processed"
global output    "${path}/output"
global destab    "${output}/descriptives_table"

* Graphics settings
set scheme s1color
graph set window fontface "Arial"