
/***************************************************************
* Stata program for replication of angrist 1993
* Author: Ben Baker
* Latest update: 12/26/2022
***************************************************************/

clear all //clear everything in memory
set scheme s2color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

cd "G:\econ_6112\replication_project\part1_2"
local path "G:\econ_6112\replication_project\part1_2"
log using "`path'\angrist1993replication_stata.log", replace //create a log file

/***************************************************************
* Load Data
***************************************************************/

	use Angrist1993Replication.dta
	
/*

Replicating all of Table 1 from Angrist (1993)

Based on the note under Table 1, the sample criteria is:
1. Only men
2. Served in the Vietnam Era (8/5/64-5/7/75) or the early AVF (5/8/75-9/7/80)
3. At least 9 years of schooling at entry to service
4. A non-negative increment in schooling since entering the service
5. Restricted to men aged 30-54 years old in 1987
6. 1-15 years of active duty service

Rounding out to 2,388 veterans who met these criteria.

*/

*female variable is a dummy variable, 1 for female, 0 for male
	drop if female == 1
	
*drops if the veteran did not serve in the vietnam era or the early avf era
	drop if viet_era == 0 & early_avf_era == 0
	
*drops if years of schooling for the veteran at entry of service is less than 9 years
	drop if entgrade < 9
	
*drops if veteran does not have a non-negative increment in schooling since entering the service
	drop if grade_inc < 0
	
*drops if the veteran is not aged in the 30-54 range in 1987
	drop if age_cat < 32
	drop if age_cat > 52
	
*drops if the veteran served less or more than 1-15 years of active duty service
	drop if years_serv_cat < 1
	drop if years_serv_cat > 15
	
/*

To check the numbers in the table, I will tabulate age, years of service, and branch of service for the top half of the table, then summarize the data to get the bottom half of the table.

*/

	tab age_cat
	tab years_serv_cat
	tab branch
	
	summarize
	
/*

replicating Figures 1 and 2.

*/
	
*Figure 1

*This line of code makes a box plot graph with earned earnings in 1986 on the y-axis and highest grade completed on the x-axis. It also renames the graph to figure 1, and creates a title for the graph. Lastly, it makes the graph color a white background.

	graph box earn86, over(curgrade) title(Figure 1: Earnings by Highest Grade Completed) graphregion(color(white)) name(figure1)
	
	graph export "`output'figure1.png", replace
	
*Figure 2

*This line of code makes a twoway histogram that showcases highest grade completed and grade level at entry. It assigns highest grade to the color white and entry grade to the color red.

	twoway (histogram entgrade, start(5) width(1.05) color(red) graphregion(color(white))) (histogram curgrade, start(5) width(1.05) fcolor(none) lcolor(black)), legend(order(1 "Grade Completed at Entry" 2 "Highest Grade Completed")) ylabel(0(0.1) 0.5) title(Figure 2: Grade Completion) name(figure2)
	
	graph export "`output'figure2.png", replace

*Displaying the data type for each category
	tab age_cat
	tab age_cat, nol
	tab years_serv_cat
	tab years_serv_cat, nol

/*

Generating dummy variables for Age Category amd Years of Service Category. In the paper, it says there "are 19 such interactions" of dummy variables dealing with age category and years of service category

*/

*Generating 5 dummy variables for the age category section
	gen age_cat_32 = age_cat==32
	gen age_cat_37 = age_cat==37
	gen age_cat_42 = age_cat==42
	gen age_cat_47 = age_cat==47
	gen age_cat_52 = age_cat==52
	
*Generating 4 dummy variables for the years served category section
	gen years_serv_cat_2 = years_serv_cat==2
	gen years_serv_cat_4 = years_serv_cat==4
	gen years_serv_cat_8 = years_serv_cat==8
	gen years_serv_cat_13 = years_serv_cat==13
	
*Generating 20 dummy variables for the interaction of age category and years served categories
	gen age_year_32_2 = age_cat_32*years_serv_cat_2
	gen age_year_32_4 = age_cat_32*years_serv_cat_4
	gen age_year_32_8 = age_cat_32*years_serv_cat_8
	gen age_year_32_13 = age_cat_32*years_serv_cat_13
	gen age_year_37_2 = age_cat_37*years_serv_cat_2
	gen age_year_37_4 = age_cat_37*years_serv_cat_4
	gen age_year_37_8 = age_cat_37*years_serv_cat_8
	gen age_year_37_13 = age_cat_37*years_serv_cat_13
	gen age_year_42_2 = age_cat_42*years_serv_cat_2
	gen age_year_42_4 = age_cat_42*years_serv_cat_4
	gen age_year_42_8 = age_cat_42*years_serv_cat_8
	gen age_year_42_13 = age_cat_42*years_serv_cat_13
	gen age_year_47_2 = age_cat_47*years_serv_cat_2
	gen age_year_47_4 = age_cat_47*years_serv_cat_4
	gen age_year_47_8 = age_cat_47*years_serv_cat_8
	gen age_year_47_13 = age_cat_47*years_serv_cat_13
	gen age_year_52_2 = age_cat_52*years_serv_cat_2
	gen age_year_52_4 = age_cat_52*years_serv_cat_4
	gen age_year_52_8 = age_cat_52*years_serv_cat_8
	gen age_year_52_13 = age_cat_52*years_serv_cat_13
	
/*

age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13

*/

*Column 1 Regression
	reg curgrade nonwhite viet_era officer drafted curmar anyva age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13

*F-test for joint significance of all the dummies in the regression for column 1
	test age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13

*Column 3 Regression
	reg grade_inc nonwhite viet_era officer drafted mardif anyva age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
*F-test for joint significance of all the dummies in the regression for column 3
	test age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
	
*Generating dependent variable for columns 4-7
	gen logearn86 = log(earn86)
	
*Column 4 Regression
	reg logearn86 nonwhite viet_era officer drafted curmar curgrade age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
	
*F-test for joint significance of all the dummies in the regression for column 4
	test age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
	
*Column 5 Regression
	reg logearn86 nonwhite viet_era officer drafted curmar entgrade grade_inc age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
	
*F-test for joint significance of all the dummies in the regression for column 5
	test age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13

*Column 6 Regression
	reg logearn86 nonwhite viet_era officer drafted curmar entgrade anyva age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
	
*F-test for joint significance of all the dummies in the regression for column 6
	test age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
	
*Column 7 Regression
	reg logearn86 nonwhite viet_era officer drafted curmar entgrade anyva grade_inc age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13
	
*F-test for joint significance of all the dummies in the regression for column 7
	test age_cat_32 age_cat_37 age_cat_42 age_cat_47 age_cat_52 years_serv_cat_2 years_serv_cat_4 years_serv_cat_8 years_serv_cat_13 age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 age_year_52_13


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/