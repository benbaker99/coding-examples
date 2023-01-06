
/***************************************************************
* Stata program for summary stats of Subperfect Game: Profitable Biases of NBA Referees
* using data from ESPN.com play-by-play data
* Author: Ben Baker
* Latest update: 02/09/2022
***************************************************************/

clear all //clear everything in memory
cd "G:\econ_6901_rm1\replication\sub-perfect game (1)\sub-perfect game\replication_data_code"
set scheme s1color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

local path "G:\econ_6901_rm1\replication\sub-perfect game (1)\sub-perfect game\replication_data_code"
log using "`path'\summarystats.log", replace //create a log file
ssc install estout, replace

/***************************************************************
* Load Data
***************************************************************/

use "`path'\minute_data_final.dta", clear

label variable travel "Travel"
label variable threesec "Three Seconds"
label variable ofoul "Offensive Foul"
label variable ogt "Offensive Goal-Tend"
label variable badpass "Bad Pass"
label variable lostball "Lost Ball"
label variable sclock "Shot Clock"
label variable fpers "Personal Foul"
label variable floose "Loose Ball Foul"
label variable finb "Inbounds Foul"
label variable fclear "Clearing Foul"
label variable faway "Away From Ball Foul"
label variable fshoot "Nonflagrant Foul"
label variable fflag "Flagrant Foul"

drop if score==.

drop if minu <3

****minimize size of data set so can have room for fe poisson regression
quietly xi: reg tod homeg ha attend sd1 sd2 sd3 sd4 i.quarter, robust cluster(date)
keep if e(sample)

***Table 2: summary stats
bysort homeg: eststo: estpost sum travel threesec ofoul ogt badpass lostball sclock fpers floose finb fclear faway fshoot fflag

eststo hadiff1: quietly estpost ttest travel, by(homeg) unequal
eststo hadiff2: quietly estpost ttest threesec, by(homeg) unequal
eststo hadiff3: quietly estpost ttest ofoul, by(homeg) unequal
eststo hadiff4: quietly estpost ttest ogt, by(homeg) unequal
eststo hadiff5: quietly estpost ttest badpass, by(homeg) unequal
eststo hadiff6: quietly estpost ttest lostball, by(homeg) unequal
eststo hadiff7: quietly estpost ttest sclock, by(homeg) unequal
eststo hadiff8: quietly estpost ttest fpers, by(homeg) unequal
eststo hadiff9: quietly estpost ttest floose, by(homeg) unequal
eststo hadiff10: quietly estpost ttest finb, by(homeg) unequal
eststo hadiff11: quietly estpost ttest fclear, by(homeg) unequal
eststo hadiff12: quietly estpost ttest fawa, by(homeg) unequal
eststo hadiff13: quietly estpost ttest fshoot, by(homeg) unequal
eststo hadiff14: quietly estpost ttest fflag, by(homeg) unequal

gen winning = 0
replace winning = 1 if sd > 0

bysort winning: eststo: estpost sum travel threesec ofoul ogt badpass lostball sclock fpers floose finb fclear faway fshoot fflag

eststo lwdiff1: quietly estpost ttest travel, by(winning) unequal 
eststo lwdiff2: quietly estpost ttest threesec, by(winning) unequal
eststo lwdiff3: quietly estpost ttest ofoul, by(winning) unequal
eststo lwdiff4: quietly estpost ttest ogt, by(winning) unequal
eststo lwdiff5: quietly estpost ttest badpass, by(winning) unequal
eststo lwdiff6: quietly estpost ttest lostball, by(winning) unequal
eststo lwdiff7: quietly estpost ttest sclock, by(winning) unequal
eststo lwdiff8: quietly estpost ttest fpers, by(winning) unequal
eststo lwdiff9: quietly estpost ttest floose, by(winning) unequal
eststo lwdiff10: quietly estpost ttest finb, by(winning) unequal
eststo lwdiff11: quietly estpost ttest fclear, by(winning) unequal
eststo lwdiff12: quietly estpost ttest fawa, by(winning) unequal
eststo lwdiff13: quietly estpost ttest fshoot, by(winning) unequal
eststo lwdiff14: quietly estpost ttest fflag, by(winning) unequal

esttab est* using "summarystats.csv", csv label noobs title("Table II. Minute-Level Summary Statistics") mtitle("Away" "Home" "Losing/Tied" "Winning") cells((mean(fmt(4)) sd(par fmt(3)))) nonumbers replace

esttab hadiff* lwdiff* using "diff.csv", csv star(* 0.1 ** 0.05 *** 0.01) label noobs nonumbers replace


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/
