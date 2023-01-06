/* Import data from the folder on your desktop */

proc import datafile='C:\Users\bakem\Desktop\dsba_6201_bia\regression\assignment\College.csv'
DBMS=csv out=college replace;

/* proc print used to print the data out */

proc print data=college;
run;

/* Creating a dummy variable for Private */
data college2;
set college;
if (private='Yes') then private_dummy = 1;
else private_dummy = 0;
run;

proc print data=college2;
run;

proc univariate data=college2 normal plot;
var accept top10perc enroll; run;

/* cutoff value for accept = 2424 + 1.5(1820) = 5124 */
/* cutoff value for top10perc = 35 + 1.5(20) = 65 */
/* cutoff value for enroll = 902 + 1.5(660) = 1892 */

data mod_college2;
set college2;
if accept > 5124 then delete;
if top10perc > 65 then delete;
if enroll > 1892 then delete;
Lp_undergrad = log(p_undergrad);
run;

proc univariate data=mod_college2 normal plot;
var accept top10perc enroll; run;

proc surveyselect data=mod_college2
samprate=0.7
out=sample
outall method=srs;
run;

data enrolltrain;
set sample;
if (Selected =1) then output; run;

data enrolltest; set sample;
if (Selected =0) then output; run;

proc reg data=enrolltrain;
model enroll = accept top10perc f_undergrad Lp_undergrad room_board grad_rate private_dummy / tol vif collin;
plot r. *p.;
run;

data mod_enrolltest;
set enrolltest;
y_bar = 141.12247 + (0.17284*accept) + (0.91533*top10perc) + (0.09121*f_undergrad) + (8.21833*Lp_undergrad) + (-0.03580*room_board) + (0.15473*grad_rate) +(-7.93162*private_dummy);
predicted_err = ((enroll -y_bar)**2);
predicted_mse = (predicted_err/112);
run;

proc print data=mod_enrolltest;
sum predicted_mse;
run;
