/*import dataset*/
libname project "\\apporto.com\dfs\CLT\Users\swestfa2_clt\Downloads";
proc import datafile="\\apporto.com\dfs\CLT\Users\swestfa2_clt\Downloads\BRFSS.xlsx"
out=BRFSS DBMS= xlsx replace;
getnames=yes;
run;
/*Remove nulls*/
data project;
set BRFSS;
keep AVEDRNK3 _TOTINDA _VEGESU1 CVDINFR4 _AGE_G SEXVAR _RACE BPHIGH6 TOLDHI3 _SMOKER3 _BMI5;
where AVEDRNK3<77 and AVEDRNK3~=. and _TOTINDA~=9 and _VEGESU1<99998 and CVDINFR4<7 and CVDINFR4~=. and _RACE~=9 and _RACE~=. and BPHIGH6<7 AND BPHIGH6~=. and TOLDHI3<7 and TOLDHI3~=. and _SMOKER3~=9 and _BMI5~=.;
run; 

/*Descriptive statistics for one continuous variable*/
data alcohol;
set project;
where AVEDRNK3~=77 OR 99; /*77= dont know, 99= refused*/
run;
proc univariate data=alcohol normal plot; /*we want a histogram*/
title 'Descriptive statistics for Alcohol Consumption';
var AVEDRNK3;
run;

/*Descriptive statistics for one categorical variable*/
data physicalactivity;
set project;
keep _TOTINDA;
where _TOTINDA~=9;
run;
proc FREQ data=physicalactivity;
title 'Desciptive Statistics for Physical Activity';
tables _TOTINDA;
run;
proc gchart data=physicalactivity;
title 'Physcial Activity';
vbar _TOTINDA / midpoints= 1 to 2 by 1; 
run;
proc gchart data=physicalactivity;
pie _TOTINDA / discrete
value=inside percent=inside slice=outside; 
run;

/*Descriptive Statistics for continuous variable grouped by a categorical variable*/
data BMIbySmoking;
set project;
keep _BMI5 _SMOKER3;
where _SMOKER3 ~=9;
run;
proc means data=BMIbySmoking;
title 'Descriptive Statistics for BMI by Smoking Status';
class _SMOKER3;
var _BMI5;
run;
proc gchart data=BMIbySmoking;
title 'BMI by Smoking Status';
vbar _SMOKER3 / midpoints= 1 to 4 by 1 type=mean;
run;

/*Test of normality*/
data drinknormality;
set project;
where AVEDRNK3~=9 and AVEDRNK3 ne .;
run;
/*Histogram with normal curve overlay*/
ods select Histogram ParameterEstimates GoodnessofFit FitQuantiles Bins;
proc univariate data=drinknormality;
title 'Normality for Drinking';
var AVEDRNK3;
histogram AVEDRNK3 / normal;
run; 
/* QQ plot*/
proc univariate data=drinknormality;
title 'Normality for Drinking';
var AVEDRNK3;
qqplot AVEDRNK3 /normal (MU=EST SIGMA=EST COLOR=RED L=1); 
run;


/* Test for h0 with 95% CI*/
data BMIheartattack;
set project;
keep CVDINFR4 _BMI5;
where CVDINFR4=1;
run;
proc ttest data=BMIheartattack h0=2500 sides=U alpha=0.05 plots= none;
title 'One Sided T-test';
var _BMI5;
run;

/* Chi-square w contingency table*/
data ageMI;
set project;
keep _age_g CVDINFR4;
where CVDINFR4<7;
run;
proc freq data=ageMI order=data;
TITLE 'Chi-Squared Test for Age Group and Heart Attack';
tables CVDINFR4* _AGE_G/chisq measures relrisk;
run;

/*Independent T-test*/
data ageveg;
set project;
keep _VEGESU1 _AGE_G AGEGROUP;
where _VEGESU1<99998;
if 1<_AGE_G<3 then AGEGROUP= 1;
else AGEGROUP= 2;
run;
proc ttest data=ageveg;
title 'Independent T test for Vegetable Consumption and Age'; 
class AGEGROUP;
var _VEGESU1;
run;

/* Scatter Plot/Correlation */
data BMIbyVegetables;
set project;
run;
proc sgplot data=BMIbyVegetables (firstobs=1 obs=500);
title 'BMI by Vegetable Consumption';
scatter x=_BMI5 y=_VEGESU1;
Ellipse x=_BMI5 y=_VEGESU1;
RUN;
proc corr data=BMIbyVegetables;
title 'Linear Correlation for BMI and Vegetable Consumption';
var _BMI5 _VEGESU1;
run;

/*Simple Logistic Regression*/
data simplogistic;
set project;
KEEP _VEGESU1 CVDINFR4;
RUN;
PROC LOGISTIC DATA=simplogistic;
title 'Logistic Regression- Vegetable Consumption and Heart Attack';
MODEL CVDINFR4 (EVENT='1')=_VEGESU1; 
WHERE _VEGESU1<99998 AND CVDINFR4<7 AND CVDINFR4~=.;
RUN;

/*Multiple Logistic Regression*/
data biglogistic;
set project; 
if _BMI5=0 then _BMI5=0; else if 0<_BMI5<9999 then _BMI5=1;
if _RACE=1 then _RACE1=1; else _RACE1=0;
if _RACE=2 then _RACE2=1; else _RACE2=0;
if _RACE=3 then _RACE3=1; else _RACE3=0;
if _RACE=4 then _RACE4=1; else _RACE4=0;
if _RACE=5 then _RACE5=1; else _RACE5=0;
if _RACE=6 then _RACE6=1; else _RACE6=0;
if _RACE=7 then _RACE7=1; else _RACE7=0;
if _RACE=8 then _RACE8=1; else _RACE8=0;
if AVEDRNK3=0 then AVEDRNK3=0; else if 0<AVEDRNK3<76 then AVEDRNK3=1; else AVEDRNK3=0;
if _TOTINDA=1 then _TOTINDA=1; else if _TOTINDA=0 then _TOTINDA=0;
if CVDINFR4=1 then CVDINFR4=1; else if CVDINFR4=0 then CVDINFR4=0;
if SEXVAR-1 then SEXVAR=1; else if SEXVAR=0 then SEXVAR=0;
if _VEGESU1=0 then _VEGESU1=0; else if 0<_VEGESU1<99998 then _VEGEUS1=1;
if BPHIGH6=1 then BPHIGH6=1; else BPHIGH6=0;
if TOLDHI3=1 then TOLDHI3=1; else TOLDHI3=0;
if _AGE_G=1 then _AGE_G1=1; else _AGE_G1=0;
if _AGE_G=2 then _AGE_G2=1; else _AGE_G2=0;
if _AGE_G=3 then _AGE_G3=1; else _AGE_G3=0;
if _AGE_G=4 then _AGE_G4=1; else _AGE_G4=0;
if _AGE_G=5 then _AGE_G5=1; else _AGE_G5=0;
if _AGE_G=6 then _AGE_G1=6; else _AGE_G1=6;
if _SMOKER3=1 then _SMOKER31=1; else _SMOKER31=0;
if _SMOKER3=1 then _SMOKER32=1; else _SMOKER32=0;
if _SMOKER3=3 then _SMOKER33=1; else _SMOKER33=0;
if _SMOKER3=4 then _SMOKER34=1; else _SMOKER34=0;
RUN;
proc logistic data=biglogistic;
title 'Multiple Logistic Regression';
model CVDINFR4(event='1')= AVEDRNK3 _TOTINDA _VEGESU1 _AGE_G SEXVAR _RACE BPHIGH6 TOLDHI3 _SMOKER3 _BMI5 / lackfit;
where CVDINFR4~=7 and CVDINFR4~=9 and CVDINFR4~=.;
run;
