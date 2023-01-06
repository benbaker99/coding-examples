
/***************************************************************
* Stata program for replication of angrist 1993
* Author: Ben Baker
* Latest update: 12/26/2022
***************************************************************/

clear all //clear everything in memory
set scheme s2color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

cd "G:\dsba_mbad_6201_bia\logit2"
local path "G:\dsba_mbad_6201_bia\logit2"
log using "`path'\logit_example_stata.log", replace //create a log file

/***************************************************************
* Load Data
***************************************************************/

import excel "G:\dsba_mbad_6201_bia\logit2\CSM.xls", sheet("csmdata") firstrow

gen hits = Ratings>6.0

logit hits Likes Comments Screens

probit hits Likes Comments Screens

//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/