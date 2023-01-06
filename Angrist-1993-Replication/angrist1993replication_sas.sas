/* must change this line to where data is saved */
proc import datafile="C:\Users\bakem\Desktop\ECON 6112 - Econometrics\Replication Project\a1993rep.xls"
DBMS=xls out=vet replace;

proc print data=vet;
run;

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

data vet2;
set vet;
if female = 1 then delete;
if viet_era = 0 & early_avf_era = 0 then delete;
if entgrade < 9 then delete;
if grade_inc < 0 then delete;
if age_cat < 32 then delete;
if age_cat > 52 then delete;
if years_serv_cat < 1 then delete;
if years_serv_cat > 15 then delete;
run;

proc freq data=vet2 NLEVELS;
table age_cat years_serv_cat branch;
run;

proc means data=vet2;
run;

/*
Replicating Figure 1. 
Makes a box plot graph with earned earnings in 1986 on the y-axis and highest grade completed on the x-axis. 
*/

proc sgplot data=vet2;
vbox earn86/ category=curgrade;
run;

/*
Replicating Figure 2.
Makes a twoway histogram that showcases highest grade completed and grade level at entry.
*/

proc sgplot data=vet2;
histogram entgrade / binwidth=1 transparency=0.5 
	name="entry" legendlabel="Grade Completed at Entry";
histogram curgrade / binwidth=1 transparency=0.5 
	name="highest" legendlabel="Highest Grade Completed";
xaxis min=5;
run;

/*
Replicating columns (1) and (3)-(7) of Table 2 from Angrist (1993).
*/

data mod_vet2;
set vet2;

*age category dummies;
if (age_cat=32) then age_cat_32=1; else age_cat_32=0;
if (age_cat=37) then age_cat_37=1; else age_cat_37=0;
if (age_cat=42) then age_cat_42=1; else age_cat_42=0;
if (age_cat=47) then age_cat_47=1; else age_cat_47=0;
if (age_cat=52) then age_cat_52=1; else age_cat_52=0;

*years served category dummies;
if (years_serv_cat=2) then years_serv_cat_2=1; else years_serv_cat_2=0;
if (years_serv_cat=4) then years_serv_cat_4=1; else years_serv_cat_4=0;
if (years_serv_cat=8) then years_serv_cat_8=1; else years_serv_cat_8=0;
if (years_serv_cat=13) then years_serv_cat_13=1; else years_serv_cat_13=0;

*generating 20 interaction dummies between age category and years served category;
age_year_32_2 = age_cat_32*years_serv_cat_2;
age_year_32_4 = age_cat_32*years_serv_cat_4;
age_year_32_8 = age_cat_32*years_serv_cat_8;
age_year_32_13 = age_cat_32*years_serv_cat_13;
age_year_37_2 = age_cat_37*years_serv_cat_2;
age_year_37_4 = age_cat_37*years_serv_cat_4;
age_year_37_8 = age_cat_37*years_serv_cat_8;
age_year_37_13 = age_cat_37*years_serv_cat_13;
age_year_42_2 = age_cat_42*years_serv_cat_2;
age_year_42_4 = age_cat_42*years_serv_cat_4;
age_year_42_8 = age_cat_42*years_serv_cat_8;
age_year_42_13 = age_cat_42*years_serv_cat_13;
age_year_47_2 = age_cat_47*years_serv_cat_2;
age_year_47_4 = age_cat_47*years_serv_cat_4;
age_year_47_8 = age_cat_47*years_serv_cat_8;
age_year_47_13 = age_cat_47*years_serv_cat_13;
age_year_52_2 = age_cat_52*years_serv_cat_2;
age_year_52_4 = age_cat_52*years_serv_cat_4;
age_year_52_8 = age_cat_52*years_serv_cat_8;
age_year_52_13 = age_cat_52*years_serv_cat_13;

*generating dependent variable for columns 4-7;
logearn86 = log(earn86);

run;

*Column 1 regression;
proc reg data=mod_vet2;
model curgrade = nonwhite viet_era officer drafted curmar anyva age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 / tol vif collin;
plot r. *p.;
test age_year_32_2, age_year_32_4, age_year_32_8, age_year_32_13, age_year_37_2, age_year_37_4, age_year_37_8, age_year_37_13, age_year_42_2, age_year_42_4, age_year_42_8, age_year_42_13, age_year_47_2, age_year_47_4, age_year_47_8, age_year_47_13, age_year_52_2, age_year_52_4, age_year_52_8;
run;

*Column 3 regression;
proc reg data=mod_vet2;
model grade_inc = nonwhite viet_era officer drafted mardif anyva age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_2 age_year_52_4 age_year_52_8 / tol vif collin;
test age_year_32_2, age_year_32_4, age_year_32_8, age_year_32_13, age_year_37_2, age_year_37_4, age_year_37_8, age_year_37_13, age_year_42_2, age_year_42_4, age_year_42_8, age_year_42_13, age_year_47_2, age_year_47_4, age_year_47_8, age_year_47_13, age_year_52_2, age_year_52_4, age_year_52_8;
run;

*Column 4 regression;
proc reg data=mod_vet2;
model logearn86 = nonwhite viet_era officer drafted curmar curgrade age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_4 age_year_52_8 / tol vif collin;
test age_year_32_2, age_year_32_4, age_year_32_8, age_year_32_13, age_year_37_2, age_year_37_4, age_year_37_8, age_year_37_13, age_year_42_2, age_year_42_4, age_year_42_8, age_year_42_13, age_year_47_2, age_year_47_4, age_year_47_8, age_year_47_13, age_year_52_4, age_year_52_8;
run;

*Column 5 regression;
proc reg data=mod_vet2;
model logearn86 = nonwhite viet_era officer drafted curmar entgrade grade_inc age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_4 age_year_52_8 / tol vif collin;
test age_year_32_2, age_year_32_4, age_year_32_8, age_year_32_13, age_year_37_2, age_year_37_4, age_year_37_8, age_year_37_13, age_year_42_2, age_year_42_4, age_year_42_8, age_year_42_13, age_year_47_2, age_year_47_4, age_year_47_8, age_year_47_13, age_year_52_4, age_year_52_8;
run;

*Column 6 regression;
proc reg data=mod_vet2;
model logearn86 = nonwhite viet_era officer drafted curmar entgrade anyva age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_4 age_year_52_8 / tol vif collin;
test age_year_32_2, age_year_32_4, age_year_32_8, age_year_32_13, age_year_37_2, age_year_37_4, age_year_37_8, age_year_37_13, age_year_42_2, age_year_42_4, age_year_42_8, age_year_42_13, age_year_47_2, age_year_47_4, age_year_47_8, age_year_47_13, age_year_52_4, age_year_52_8;
run;

*Column 7 regression;
proc reg data=mod_vet2;
model logearn86 = nonwhite viet_era officer drafted curmar entgrade anyva grade_inc age_year_32_2 age_year_32_4 age_year_32_8 age_year_32_13 age_year_37_2 age_year_37_4 age_year_37_8 age_year_37_13 age_year_42_2 age_year_42_4 age_year_42_8 age_year_42_13 age_year_47_2 age_year_47_4 age_year_47_8 age_year_47_13 age_year_52_4 age_year_52_8 / tol vif collin;
test age_year_32_2, age_year_32_4, age_year_32_8, age_year_32_13, age_year_37_2, age_year_37_4, age_year_37_8, age_year_37_13, age_year_42_2, age_year_42_4, age_year_42_8, age_year_42_13, age_year_47_2, age_year_47_4, age_year_47_8, age_year_47_13, age_year_52_4, age_year_52_8;
run;
