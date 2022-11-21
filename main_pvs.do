* PVS Main file 
* September 2022
* N. Kapoor 
* This file sets all macros and runs all .do files

************************************************
* Drop all macros
macro drop _all

*Project settings
*Individual users 
*global user "/Users/nek096"
*global user "/Users/tol145"
global user "/Users/rodba"

* Path to data folder 
global data "$user/Dropbox (Harvard University)/SPH-Kruk Team/QuEST Network/Core Research/People's Voice Survey/PVS External/Data"

* Path to multi-country data folder (includes input and output folders for HFCs)
global data_mc "$data/Multi-country"

* Path to HFC output folders - may change
global output "$data_mc/03 test output/Output"

* Path to GitHub folder 
global github "$user/Documents/GitHub/PVS-code"

************************************************
* Required packages 
* IPA's Stata Package for HFCs
net install ipacheck, all replace from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master")
ipacheck update

************************************************

* Initial data cleaning and creating multi-country dataset 
run "$github/cr01_pvs_cln.do"

* Deriving variables for analysis
run "$github/cr02_pvs_der.do"

* Descriptive analysis (megatables)
run "$github/an01_pvs.do"

