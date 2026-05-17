use raw-data, clear



** Identifer variables **

// Anonymous User ID
egen 	user_id = group(userid)
rename	userid prolific_id
rename	user_id userid

// Task ID per session
gen 		task_id		= substr(taskid, 22,1)
destring	task_id, replace

// Full Sequence (with all 20 trials)
egen full_sequence = group(session order)


// Sequence within a Session
rename order sequence



** Study Condition Variables **

// Accuracy Condition
gen      	system_acc	= substr(taskid, 1, 4)

gen			system_acc_num = .
replace 	system_acc_num = 1 if system_acc == "hhhh"
replace 	system_acc_num = 2 if system_acc == "hhll"
replace 	system_acc_num = 3 if system_acc == "hlll"
replace 	system_acc_num = 4 if system_acc == "llll"
replace 	system_acc_num = 5 if system_acc == "llhh"
replace 	system_acc_num = 6 if system_acc == "lhhh"

drop 		system_acc
rename		system_acc_num system_acc

// Task Uncertainty Condition (diagnostic vs. prognostic)
gen       	task_uncert = substr(taskid, 11, 4)

gen       	diagnostic = task_uncert =="diag"
label var 	diagnostic "diag (vs prog), 1=yes"
drop      	task_uncert

// System Frame Condition (static vs. learning)

gen 		sys_frame	= substr(taskid, 16, 4)
gen       	static		= sys_frame =="stat"
drop		sys_frame


** Task-Based Variables **

// Trust per Trial
alpha 	trust_test_*, item
egen	trust_trial = rowmean(trust_test_*)


** Session-Based Variables **


// Perceived Reliability, 5 Items, 7-Pt-Likert
alpha	hct_01 hct_02 hct_03 hct_04 hct_05, item
egen	reliability = rowmean(hct_01 hct_02 hct_03 hct_04 hct_05)
drop	hct_01 hct_02 hct_03 hct_04 hct_05

// Perceived Faith, 5 Items, 7-Pt-Likert
alpha 	hct_06 hct_07 hct_08 hct_09 hct_10, item
egen	faith = rowmean(hct_06 hct_07 hct_08 hct_09 hct_10)
drop	hct_06 hct_07 hct_08 hct_09 hct_10

// Perceived Technical Competence, 6 Items, 7-Pt-Likert

alpha 	hct_11 hct_12 hct_13 hct_14 hct_15 hct_16, item
egen	competence = rowmean(hct_11 hct_12 hct_13 hct_14 hct_15 hct_16)
drop	hct_11 hct_12 hct_13 hct_14 hct_15 hct_16

// Perceived Usefulness, 5 Items, 7-Pt-Likert
alpha 	pu_01 pu_02 pu_03 pu_04 pu_05, item
egen	usefulness = rowmean(pu_01 pu_02 pu_03 pu_04 pu_05)
drop	pu_01 pu_02 pu_03 pu_04 pu_05

// Perceived Understandability, 5 Items, 7-Pt-Likert
alpha	hct_17 hct_18 hct_19 hct_20 hct_21, item
egen	understandability = rowmean(hct_17 hct_18 hct_19 hct_20 hct_21)
drop	hct_17 hct_18 hct_19 hct_20 hct_21

// Perceived Accuracy, 1 Item, 10-Pt Likert
rename acc_01 accuracy_perception

// Perceived Task Load, 5 Items, 7-Pt-Likert
alpha	ptl_01 ptl_02 ptl_03 ptl_04 ptl_05, item 
egen 	task_load = rowmean (ptl_01 ptl_02 ptl_03 ptl_04 ptl_05)
drop	ptl_01 ptl_02 ptl_03 ptl_04 ptl_05

// Perceived Achievement, 3 Items, 7-Pt-Likert
alpha 	pa_01 pa_02 pa_03, item
egen	achievement = rowmean(pa_01 pa_02 pa_03)	
drop 	pa_01 pa_02 pa_03



** Questionnaires **

// Affinity to Tech, 6-Pt-Likert Scale
alpha 	ati_*,item
// Inverting ati_03, ati_06, ati_08

replace ati_03 = 7 - ati_03
replace ati_06 = 7 - ati_06
replace ati_08 = 7 - ati_08

egen	ati_score = rowmean(ati_*)
drop 	ati_01 ati_02 ati_03 ati_04 ati_05 ati_06 ati_07 ati_08 ati_09

// Decision-Making Style, 7-Pt-Likert Scale
alpha	dms_*, item

replace dms_05 = 8 - dms_05
replace dms_06 = 8 - dms_06
replace dms_07 = 8 - dms_07
replace dms_08 = 8 - dms_08
replace dms_09 = 8 - dms_09
replace dms_10 = 8 - dms_10

egen	dms_score = rowmean(dms_*)
drop 	dms_01 dms_02 dms_03 dms_04 dms_05 dms_06 dms_07 dms_08 dms_09 dms_10


// Decision-Making Style (Sub-Scale)
alpha 	dmq_*, item

egen 	dmq_score = rowmean(dmq_*)
drop	dmq_01 dmq_02 dmq_03 dmq_04 dmq_05 dmq_06

// Domain Expertise

alpha	de_*, item
egen	domain_exp = rowmean(de_*)
drop	de_01 de_02 de_03

// Numeracy Skills, 6-Pt-Likert Scale
alpha	sns_*, item

replace sns_07 = 7 - sns_07

egen 	sns_score = rowmean(sns_*)
drop 	sns_01 sns_02 sns_03 sns_04 sns_05 sns_06 sns_07 sns_08



// Attention Checks

// Also: double check the time-variable(s)



// Organizing a bit

label var  userid              "Person id"
label var  task_id             "Identifier of task within a session, per person (1-5)"
label var  full_sequence       "Task sequence (per person: running from 1-20; 1 was first etc)"
label var  sequence            "Task sequence order within a session (1-5)"
label var  system_acc          "system accuracy 1:HHHH/2:HHLL/3:HLLL/4:LLLL/5:LLHH/6:LHHH"
ren static learning_system
label var  learning_system      "Learning system (1=yes;0=static)"
label var  diagnostic           "Task is diagnostic (1=yes;0=prognostic)"
label var  session              "Session number (1-4)"

label var study_condition       "String representing experimental condition(s)"
ren taskid task_string          
label var  task_string          "String representing tasks in experiment"

order prolific_id userid session task_id full_sequence sequence system_acc learning_system diagnostic study_condition task_string


// Target variable definition

label var ai    "AI suggestion"
label var best  "actual best answer"

// Do they follow the AI suggestion

gen       init_eq_ai = (ai==initialdecision)
label var init_eq_ai "Initial decision matches AI suggestion"

gen       followed_ai = (finaldecision==ai)
replace   followed_ai = . if init_eq_ai==1 
label var followed_ai "Initial decision not equal to AI, final decision is"

gen       changed_altho_thesame = ( (init_eq_ai==1) & (finaldecision~=ai) )     // happens only 6 times
label var changed_altho_thesame "Initially equal to ai, but participant changed to something else"

gen       changed_afterai = (initialdecision~=finaldecision)
label var changed_afterai "Person changed after seeing ai suggestion (but perhaps not to the ai)"

order ai best initialdecision finaldecision init_eq_ai followed_ai changed_altho_thesame, after(task_string)


gen       ai_chose_best = (ai==best)
label var ai_chose_best "AI suggested best answer (1=yes)"




// Do they get better with AI?

	// Here we need the actual cost (or benefit) per route on offer

	

// merging which route options were available
merge m:1 task_string prolific_id using whichrouteisbest



sort prol session full_sequence
keep if _merge==3

list ai best route0 - route4 if _n<100


********************************************************************************
* As of here, you could run analyses at the trial level, controlling for that
* there are multiple measurements per person
********************************************************************************



tab followed_ai   // 50% of the trials they changed to the ai suggestion

bys prolific_id:  egen npers_foll_ai     = total(followed_ai)
bys prolific_id:  egen npers_init_not_ai = total(init_eq_ai)
replace                npers_init_not_ai = 20 - npers_init_not_ai

tab npers_foll_ai if full_sequence==1                		 // how often, per person, they followed ai (probably better to make this a %)
gen perc_change_to_ai = npers_foll_ai / npers_init_not_ai    // in which percentage of cases did a person follow ai when they could


bys prolific_id session: egen ai_acc = total(ai_chose_best)
gen ai_high = (ai_acc==4)
drop ai_acc
label var ai_high "System in session was high acc. (1=yes)"



if 0 {
gen     overreliance = (ai~=best) & (finaldecision==ai)
replace overreliance = . if init_eq_ai==1

gen     underreliance = (ai==best) & (finaldecision~=ai)
replace underreliance = . if init_eq_ai==1
}

encode prolific_id, gen(prol_id)

xtset prol_id
xtlogit followed_ai             // 27 percent at the individual level
xtlogit followed_ai i.session diagnostic learning_system i.sequence ai_chose_best ai_high


destring route0, replace
destring route1, replace
destring route2, replace
destring route3, replace
destring route4, replace


* creating a 'cost' variable based on the routes that were chosen

gen cost_init=.
forvalues i=0/4 {
	replace cost_init = route`i' if initialdecision==`i'
}

gen cost_final=.
forvalues i=0/4 {
	replace cost_final = route`i' if finaldecision==`i'
}

gen cost_improv = cost_init - cost_final

xtset prol_id
xtreg cost_improv                                       if init_eq_ai==0
xtreg cost_improv cost_init followed_ai i.session diagnostic learning_system i.sequence ai_chose_best ai_high


* more or less the same but now for the 'trust_trial' variable

xtset prol_id
xtreg trust_trial if init_eq_ai==0
xtreg trust_trial followed_ai i.session diagnostic learning_system i.sequence ai_chose_best ai_high
// looks like this is more or less the same as measuring whether you followed ai_acc


* using what happened in previous round

bys prolific_id (full_sequence): gen prev_trusttrial = trust_trial[_n-1]

xtreg cost_improv cost_init followed_ai i.session diagnostic learning_system i.sequence ai_chose_best ai_high prev_trusttrial

mixed trust_trial i.session i.system_acc diagnostic learning_system prev_trusttrial || prolific_id:, variance




**** creating the accH variable (which defines HA vs LA sessions)

gen accuracy_dummy = substr(task_string, 9, 1)
gen accuracy_dummy2 = (accuracy_dummy == "h")

rename accuracy_dummy2 accH
drop accuracy_dummy







*** Info on System Accuracy over Session Conditions ****

// system_acc 1 = "hhhh"
// system_acc 2 = "hhll"
// system_acc 3 = "hlll"
// system_acc 4 = "llll"
// system_acc 5 = "llhh"
// system_acc 6 = "lhhh"

/*

// EXAMPLE SYNTAX for plotting the lines over sessions for all 6 accuracy conditions for the DIAGNOSTIC + STATIC system	
preserve
collapse (mean) 	mean_followed_ai= followed_ai (sd) sd_followedai = followed_ai (count) n=followed_ai, by(system_acc diagnostic learning_system session)
bysort system_acc: 	sum mean_followed_ai

generate hi_acc 	= mean_followed_ai + 1.96*(sd_followedai / sqrt(n))
generate low_acc 	= mean_followed_ai - 1.96*(sd_followedai / sqrt(n))

graph twoway 	(connected mean_followed_ai session if diagnostic == 0 & learning_system == 0 & system_acc == 1, color(midgreen)) ///
				(connected mean_followed_ai session if diagnostic == 0 & learning_system == 0 & system_acc == 2, color(blue)) ///
				(connected mean_followed_ai session if diagnostic == 0 & learning_system == 0 & system_acc == 3, color(dkorange)) ///
				(connected mean_followed_ai session if diagnostic == 0 & learning_system == 0 & system_acc == 4, color(red)) ///
				(connected mean_followed_ai session if diagnostic == 0 & learning_system == 0 & system_acc == 5, color(purple)) ///
				(connected mean_followed_ai session if diagnostic == 0 & learning_system == 0 & system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore

*/

// additional variables for accuracy trend over progression
gen acc_trend = .
replace acc_trend =  1 if system_acc == 5 | system_acc == 6 	// Improving accuracy
replace acc_trend =  2 if system_acc == 2 | system_acc == 3 	// Declining accuracy
replace acc_trend =  0 if system_acc == 1 | system_acc == 4  	// Stable accuracy









*******************************************************
*********** Data Analysis 9.4.2025 ********************


*** dropping unreliable participants or test data *****

drop 		if userid == 245 //sara-test
// drop 	if userid ==  86 // failed 3 out of 4 attention checks
// drop 	if userid == 176 // failes 3 out of 4 attention checks



*** Reliance Models ***********************************

** Step 1: defining indicator variables for sub-definitions of reliance based on Schemmer et al. (2023)

gen initial_correct = (initialdecision == best)
gen final_correct 	= (finaldecision == best)
gen ai_correct		= (ai == best)
gen follow_ai		= (finaldecision == ai)
gen nondiagnostic 	= (initialdecision == ai)		// because this means there is no actual reliance (addition, 2.9.)

** Step 2: defining CAIR variable  (correct AI reliance)
gen cair 			= (initial_correct == 0 & ai_correct == 1 & final_correct == 1)
replace cair = . if initialdecision == ai & initialdecision == best									//updated CAIR (19.8.)

tab cair, missing

// CAIR = 0 - 62,6%, 3052 decisions
// CAIR = 1 - 23,2%, 1133 decisions
// CAIR = . - 14,2%, 695 decisions


** Step 3: defining OR Variable (incorrect AI reliance, or: overreliance)
//gen or		 		= (initial_correct == 1 & ai_correct == 0 & final_correct == 0 & follow_ai == 1)

gen or 			= (initial_correct == 1 & ai_correct == 0 & final_correct == 0 & follow_ai == 1)
replace or  	= . if nondiagnostic																// updated OR (2.9.)
tab or, missing

// OR = 0 - 74.10%, 3616 decisions
// OR = 1 - 4,51%, 220 decisions
// OR = . 21,4%, 1044 decisions

** Step 4: defining CSR Variable (correct self-reliance)
gen csr 	= (initial_correct == 1 & ai_correct == 0 & final_correct == 1 & follow_ai == 0)
replace csr = . if nondiagnostic
tab csr, missing

// CSR = 0 - 73,8%, 3602 decisions
// CSR = 1 - 4,9%, 234 decisions
// CSR = . - 21,4%, 1044 decisions


** Step 5: defining UR Variable (incorrect self-reliance, or: underreliance)
gen ur = (initial_correct == 0 & ai_correct == 1 & final_correct == 0 & followed_ai == 0)
replace ur = . if nondiagnostic
tab ur, missing

// UR = 0 - 56,48%, 2756 decisions
// UR = 1 - 22,1%, 1080 decisions
// UR = . - 21,39%, 1044 decisions


// counting decisions where AI and participants initially disagree --> diagnostic filter

count if initial_correct == 1 & initialdecision != ai // participants were correct, and disagreed with AI
// 459 times
count if initial_correct == 0 & initialdecision != ai // participants were wrong, and disagreed with AI
// 3377 times
count if ai_correct == 1 & initialdecision != ai // AI advice was correct, participants initially disagreed with AI
// 2213 times
count if ai_correct == 0 & initialdecision != ai // AI advice was wrong, participants initially disagreed with AI 
// 1623 times 

count if initial_correct==1 & ai_correct==1 & final_correct==1   // Init C, AI C, Final C

count if initial_correct==1 & ai_correct==1 & final_correct==0   // Init C, AI C, Final I

count if initial_correct==0 & ai_correct==0 & final_correct==1   // Init I, AI I, Final C

count if initial_correct==0 & ai_correct==0 & final_correct==0   // Init I, AI I, Final I 


count if initial_correct==1 & ai_correct==0 //CSR, OR
count if initial_correct==0 & ai_correct==1 // CAIR, UR


count if initial_correct==1 & ai_correct==1 // non-diagnostic correct
count if initial_correct==0 & ai_correct==0 // non-diagnostic wrong



gen diagnostic_possible = (initialdecision != ai)

gen reliance_diagnostic = ///
   (initial_correct != ai_correct) & (initialdecision != ai) & ///
   inlist(finaldecision, 0, 1, 2, 3, 4)
   
count if diagnostic_possible       // should be 3836, is 3836!
count if reliance_diagnostic       // should be 2672, is 2672!


count if ai_correct == 1
// 2908 decisions from 4880 decisions --> 60% of all decisions --> high accuracy was 80%, low accuracy was 40%, so correct

** Step 6: Defining RAIR (relative AI reliance)

// RAIR = 1: participants always followed correct AI advice and where right with item
// RAIR = 0: participants never followed AI advice, even would have helped them

gen ca = (initial_correct == 0 & ai_correct == 1)

preserve

gen ra_ir = .
bysort prolific_id (full_sequence): replace ra_ir = sum(cair) / sum(ca) if ca > 0

collapse (sum) cair ca, by(prolific_id)
gen rair = cair / ca
tempfile collapsed
save `collapsed', replace
restore

merge m:1 prolific_id using `collapsed', keep(match master) nogen


** Creating session-based RAIR to see if people improve in relative AI reliance over sessions:

preserve
collapse (sum) cair ca, by(prolific_id session)
gen rair_session = cair / ca
tempfile rairdata
save `rairdata', replace
restore

merge m:1 prolific_id session using `rairdata', keep(match master) nogen


** Step 7: Defining RSR (relative self-reliance) --> empty cells: no trials for participants being correct & ai being wrong

gen ia = (initial_correct == 1 & ai_correct == 0)

preserve
collapse (sum) csr ia, by(prolific_id)
gen rsr = csr / ia
tempfile rsrdata
save `rsrdata', replace
restore

merge m:1 prolific_id using `rsrdata', keep(match master) nogen


** Creating session-based RSR to see if people improve in relative self-reliance over sessions:

preserve
collapse (sum) csr ia, by(prolific_id session)
gen rsr_session = csr / ia

tempfile rsrdata
save `rsrdata', replace
restore

merge m:1 prolific_id session using `rsrdata', keep(match master) nogen

drop _merge



** LAGGED VARs (trial) ***********************************




** making sure the first trial round is not included in our analysis:

// replace csr_lag 		= . if full_sequence == 1
// replace cair_lag 	= . if full_sequence == 1
// replace ur_lag 		= . if full_sequence == 1
// replace or_lag 		= . if full_sequence == 1


** LAGGED VARs (session) ***********************************

preserve
sort prolific_id session

collapse (mean) trust_trial csr cair ur or, by(prolific_id session)

sort prolific_id session

gen trust_lag_session = trust_trial[_n-1] if prolific_id == prolific_id[_n-1]
gen csr_lag_session   = csr[_n-1]         if prolific_id == prolific_id[_n-1]
gen cair_lag_session  = cair[_n-1]        if prolific_id == prolific_id[_n-1]
gen ur_lag_session    = ur[_n-1]          if prolific_id == prolific_id[_n-1]
gen or_lag_session    = or[_n-1]          if prolific_id == prolific_id[_n-1]

tempfile session_lags
save `session_lags'
restore

merge m:1 prolific_id session using `session_lags'

drop _merge


******************************************************************************
*** Descriptives *************************************************************

tab prolific_id

bysort prolific_id: gen obs_per_participant = _N
tab obs_per_participant
** 4,880 trial rounds = 244 participants with 20 trials each


tab study_condition
** evenly distributed participants over the 24 groups

*hhhh_diag_lear |        180        3.69        3.69
*hhhh_diag_stat |        220        4.51        8.20
*hhhh_prog_lear |        200        4.10       12.30
*hhhh_prog_stat |        200        4.10       16.39
*hhll_diag_lear |        260        5.33       21.72
*hhll_diag_stat |        200        4.10       25.82
*hhll_prog_lear |        220        4.51       30.33
*hhll_prog_stat |        200        4.10       34.43
*hlll_diag_lear |        200        4.10       38.52
*hlll_diag_stat |        180        3.69       42.21
*hlll_prog_lear |        180        3.69       45.90
*hlll_prog_stat |        160        3.28       49.18
*lhhh_diag_lear |        180        3.69       52.87
*lhhh_diag_stat |        220        4.51       57.38
*lhhh_prog_lear |        200        4.10       61.48
*lhhh_prog_stat |        160        3.28       64.75
*llhh_diag_lear |        180        3.69       68.44
*llhh_diag_stat |        220        4.51       72.95
*llhh_prog_lear |        220        4.51       77.46
*llhh_prog_stat |        180        3.69       81.15
*llll_diag_lear |        220        4.51       85.66
*llll_diag_stat |        200        4.10       89.75
*llll_prog_lear |        260        5.33       95.08
*llll_prog_stat |        240        4.92      100.00


tab system_acc

* 1: HHHH |        800       16.39       16.39
* 2: HHLL |        880       18.03       34.43
* 3: HLLL |        720       14.75       49.18
* 4: LLLL |        920       18.85       68.03
* 5: LLHH |        800       16.39       84.43
* 6: LHHH |        760       15.57      100.00


// overview reliance variables

foreach var in ur or csr cair {
    tab `var'
}

*         ur |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          0 |      3,800       77.87       77.87
*          1 |      1,080       22.13      100.00
*------------+-----------------------------------
*      Total |      4,880      100.00
*
*
*         or |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          0 |      4,660       95.49       95.49
*          1 |        220        4.51      100.00
*------------+-----------------------------------
*      Total |      4,880      100.00
*
*
*        csr |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          0 |      4,646       95.20       95.20
*          1 |        234        4.80      100.00
*------------+-----------------------------------
*      Total |      4,880      100.00
*
*
*       cair |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          0 |      3,747       76.78       76.78
*          1 |      1,133       23.22      100.00
*------------+-----------------------------------
*      Total |      4,880      100.00

// in 23 percent of all trials do people correctly rely on AI
// in only 5 perecnt of all trials they rely on themselves correctly 
// they rely too less on AI in 22 percent of all trials
// overreliance doe snot seem to be a big issue - only 5 percent of all trials show OR




foreach var in ur or csr cair {
    tab system_acc `var'
}

// it seems that UR is happening in the HHHH the most, and the least in the HLLL and LLLL condition

// OR is happening most in HLLL and LLLL, the least in HHHH (makes sense...)

// CSR is happening the least in LHHH and HHHH (makes sense)

// CAIR is happening the least in LLLL (makes sense)

foreach var in ur or csr cair {
    tab diagnostic `var'
}

foreach var in ur or csr cair {
    tab learning_system `var'
}

foreach var in ur or csr cair {
    tab study_condition `var'
}


// overview covariates 
summarize domain_exp sns_score ati_score dms_score

*    Variable |        Obs        Mean    Std. dev.       Min        Max
*-------------+---------------------------------------------------------
*  domain_exp |      4,880        3.25    1.877551          1          7
*   sns_score |      4,880    4.747951    .8521706          2          6
*   ati_score |      4,880    4.292805    .5570014   2.222222   5.444445
*   dms_score |      4,880     4.90041    .7716273        2.1        6.4



foreach var in domain_exp sns_score ati_score dms_score {
    tabstat `var', by(study_condition) stats(mean sd min max)
}



****** dropping observations *****

drop 	if userid ==  86 // failed 3 out of 4 attention checks
drop 	if userid == 176 // failes 3 out of 4 attention checks



********************************************************************************
** Reliance  *******************************************************************


melogit cair i.accH i.learning_system i.session##i.accH cair_lag_session || prolific_id:

// accuracy sign effect
// learning sign effect
// more cair over session (because we included the interaction term, so the "session" shows the low-accuracy condition results)
// when accuracy is high, increase in cair in s2, s3

margins accH
margins learning_system
margins accH#session
// margins diagnostic
margins session
marginsplot


// plotting the lines over sessions for all 6 accuracy conditions for the DIAGNOSTIC + STATIC system --> for cair, csr, or, ur
preserve
collapse (mean) 	mean_cair= cair (sd) sd_cair = cair (count) n=cair, by(system_acc diagnostic learning_system session)
bysort system_acc: 	sum mean_cair

generate hi_acc 	= mean_cair + 1.96*(sd_cair / sqrt(n))
generate low_acc 	= mean_cair - 1.96*(sd_cair / sqrt(n))

graph twoway 	(connected mean_cair session if diagnostic == 0 & learning_system == 0 & system_acc == 1, color(midgreen)) ///
				(connected mean_cair session if diagnostic == 0 & learning_system == 0 & system_acc == 2, color(blue)) ///
				(connected mean_cair session if diagnostic == 0 & learning_system == 0 & system_acc == 3, color(dkorange)) ///
				(connected mean_cair session if diagnostic == 0 & learning_system == 0 & system_acc == 4, color(red)) ///
				(connected mean_cair session if diagnostic == 0 & learning_system == 0 & system_acc == 5, color(purple)) ///
				(connected mean_cair session if diagnostic == 0 & learning_system == 0 & system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore

preserve
collapse (mean) 	mean_csr= csr (sd) sd_csr = csr (count) n=csr, by(system_acc diagnostic learning_system session)
bysort system_acc: 	sum mean_csr

generate hi_acc 	= mean_csr + 1.96*(sd_csr / sqrt(n))
generate low_acc 	= mean_csr - 1.96*(sd_csr / sqrt(n))

graph twoway 	(connected mean_csr 	session if diagnostic == 0 & learning_system == 0 & system_acc == 1, color(midgreen)) ///
				(connected mean_csr  session if diagnostic == 0 & learning_system == 0 & system_acc == 2, color(blue)) ///
				(connected mean_csr  session if diagnostic == 0 & learning_system == 0 & system_acc == 3, color(dkorange)) ///
				(connected mean_csr  session if diagnostic == 0 & learning_system == 0 & system_acc == 4, color(red)) ///
				(connected mean_csr  session if diagnostic == 0 & learning_system == 0 & system_acc == 5, color(purple)) ///
				(connected mean_csr  session if diagnostic == 0 & learning_system == 0 & system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore


preserve
collapse (mean) 	mean_or= or (sd) sd_or = or (count) n=or, by(system_acc diagnostic learning_system session)
bysort system_acc: 	sum mean_or

generate hi_acc 	= mean_or + 1.96*(sd_or / sqrt(n))
generate low_acc 	= mean_or - 1.96*(sd_or / sqrt(n))

graph twoway 	(connected mean_or 	session if diagnostic == 0 & learning_system == 0 & system_acc == 1, color(midgreen)) ///
				(connected mean_or  session if diagnostic == 0 & learning_system == 0 & system_acc == 2, color(blue)) ///
				(connected mean_or  session if diagnostic == 0 & learning_system == 0 & system_acc == 3, color(dkorange)) ///
				(connected mean_or  session if diagnostic == 0 & learning_system == 0 & system_acc == 4, color(red)) ///
				(connected mean_or  session if diagnostic == 0 & learning_system == 0 & system_acc == 5, color(purple)) ///
				(connected mean_or  session if diagnostic == 0 & learning_system == 0 & system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore


preserve
collapse (mean) 	mean_or= or (sd) sd_or = or (count) n=or, by(system_acc session)
bysort system_acc: 	sum mean_or

generate hi_acc 	= mean_or + 1.96*(sd_or / sqrt(n))
generate low_acc 	= mean_or - 1.96*(sd_or / sqrt(n))

graph twoway 	(connected mean_or 	session if  system_acc == 1, color(midgreen)) ///
				(connected mean_or  session if  system_acc == 2, color(blue)) ///
				(connected mean_or  session if  system_acc == 3, color(dkorange)) ///
				(connected mean_or  session if  system_acc == 4, color(red)) ///
				(connected mean_or  session if  system_acc == 5, color(purple)) ///
				(connected mean_or  session if  system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore

preserve
collapse (mean) 	mean_cair= cair (sd) sd_cair = cair (count) n=cair, by(system_acc session)
bysort system_acc: 	sum mean_cair

generate hi_acc 	= mean_cair + 1.96*(sd_cair / sqrt(n))
generate low_acc 	= mean_cair - 1.96*(sd_cair / sqrt(n))

graph twoway 	(connected mean_cair 	session if  system_acc == 1, color(midgreen)) ///
				(connected mean_cair  session if  system_acc == 2, color(blue)) ///
				(connected mean_cair  session if  system_acc == 3, color(dkorange)) ///
				(connected mean_cair  session if  system_acc == 4, color(red)) ///
				(connected mean_cair  session if  system_acc == 5, color(purple)) ///
				(connected mean_cair  session if  system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore


preserve
collapse (mean) 	mean_cair= cair (sd) sd_cair = cair (count) n=cair, by(system_acc session)
bysort system_acc: 	sum mean_cair

generate hi_acc 	= mean_cair + 1.96*(sd_cair / sqrt(n))
generate low_acc 	= mean_cair - 1.96*(sd_cair / sqrt(n))

graph twoway 	(connected mean_cair 	session if  system_acc == 1, color(midgreen)) ///
				(connected mean_cair  session if  system_acc == 2, color(blue)) ///
				(connected mean_cair  session if  system_acc == 3, color(dkorange)) ///
				(connected mean_cair  session if  system_acc == 4, color(red)) ///
				(connected mean_cair  session if  system_acc == 5, color(purple)) ///
				(connected mean_cair  session if  system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore


preserve
collapse (mean) 	mean_trust_trial= trust_trial (sd) sd_trusttrial = trust_trial (count) n=trust_trial, by(system_acc session)
bysort system_acc: 	sum mean_trust_trial

generate hi_acc 	= mean_trust_trial + 1.96*(sd_trusttrial / sqrt(n))
generate low_acc 	= mean_trust_trial - 1.96*(sd_trusttrial / sqrt(n))

graph twoway 	(connected mean_trust_trial session if system_acc == 1, color(midgreen)) ///
				(connected mean_trust_trial session if system_acc == 2, color(blue)) ///
				(connected mean_trust_trial session if system_acc == 3, color(dkorange)) ///
				(connected mean_trust_trial session if system_acc == 4, color(red)) ///
				(connected mean_trust_trial session if system_acc == 5, color(purple)) ///
				(connected mean_trust_trial session if system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore



preserve
collapse (mean) 	mean_reliability= reliability (sd) sd_reliability = reliability (count) n=reliability, by(system_acc session)
bysort system_acc: 	sum mean_reliability

generate hi_acc 	= mean_reliability + 1.96*(sd_reliability / sqrt(n))
generate low_acc 	= mean_reliability - 1.96*(sd_reliability / sqrt(n))

graph twoway 	(connected mean_reliability session if system_acc == 1, color(midgreen)) ///
				(connected mean_reliability session if system_acc == 2, color(blue)) ///
				(connected mean_reliability session if system_acc == 3, color(dkorange)) ///
				(connected mean_reliability session if system_acc == 4, color(red)) ///
				(connected mean_reliability session if system_acc == 5, color(purple)) ///
				(connected mean_reliability session if system_acc == 6, color(magenta)), ///
	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore

// the old models with all system accuracy definition, seeing the interactions with session
melogit cair i.system_acc i.session i.system_acc#session || prolific_id:


margins session#system_acc
marginsplot


// the old models with all system accuracy definition, seeing the interactions with session
mixed trust_trial i.system_acc i.session i.system_acc#session || prolific_id:


margins session#system_acc
marginsplot

// hypotheses 2A
mixed trust_trial i.system_acc i.session i.system_acc#session if system_acc == 2 | system_acc == 1 || prolific_id:

mixed trust_trial i.system_acc i.session i.system_acc#session if system_acc == 3 | system_acc == 1 || prolific_id:


melogit cair i.system_acc i.session i.system_acc#session if system_acc == 2 | system_acc == 1 || prolific_id:
// no OR / underreliance 

melogit cair i.system_acc i.session i.system_acc#session if system_acc == 3 | system_acc == 1 || prolific_id:

//modelling the contrast between s1+2 vs s3+4
gen step_2_to_3 = .

replace step_2_to_3 = 1 if session > 2
replace step_2_to_3 = 0 if session < 3

// checking whether H2 is holding --> contrasting the H vs L sessions for HHLL vs. LLHH
melogit cair i.system_acc i.step_2_to_3 i.system_acc#step_2_to_3 if system_acc == 2 | system_acc == 1 || prolific_id:

melogit cair i.system_acc i.step_2_to_3 i.system_acc#step_2_to_3 if system_acc == 5 | system_acc == 1 || prolific_id:


// modelling the contrast between s1 vs. s2,3,4
gen step_1_to_2 = .

replace step_1_to_2 = 1 if session == 1
replace step_1_to_2 = 0 if session > 1


// checking whether H2 is holding --> contrasting the H vs L sessions for HHLL vs. LLHH

melogit cair i.system_acc i.step_1_to_2 i.system_acc#step_1_to_2 if system_acc == 3 | system_acc == 1 || prolific_id:

melogit cair i.system_acc i.step_1_to_2 i.system_acc#step_1_to_2 if system_acc == 6 | system_acc == 1 || prolific_id:







*** Data Analysis Session with Martijn 11.4. ***********************************

// visualizing HHHH and LLLL for trust + CAIR

// graph with four sessions
preserve
collapse (mean) 	mean_trust_trial= trust_trial (sd) sd_trusttrial = trust_trial (count) n=trust_trial, by(system_acc session)
bysort system_acc: 	sum mean_trust_trial

generate hi_acc 	= mean_trust_trial + 1.96*(sd_trusttrial / sqrt(n))
generate low_acc 	= mean_trust_trial - 1.96*(sd_trusttrial / sqrt(n))

graph twoway 	(connected mean_trust_trial session if system_acc == 1, color(midgreen)) ///
				(connected mean_trust_trial session if system_acc == 4, color(red)) ///

	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore


// graph with 20 trials
preserve
collapse (mean) 	mean_trust_trial= trust_trial (sd) sd_trusttrial = trust_trial (count) n=trust_trial, by(system_acc full_sequence)
bysort system_acc: 	sum mean_trust_trial

generate hi_acc 	= mean_trust_trial + 1.96*(sd_trusttrial / sqrt(n))
generate low_acc 	= mean_trust_trial - 1.96*(sd_trusttrial / sqrt(n))

graph twoway 	(connected mean_trust_trial full_sequence if system_acc == 1, color(midgreen)) ///
				(connected mean_trust_trial full_sequence if system_acc == 4, color(red)) ///

	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore


// gaph with 4 sessions
preserve
collapse (mean) 	mean_cair= cair (sd) sd_cair = cair (count) n=cair, by(system_acc session)
bysort system_acc: 	sum mean_cair

generate hi_acc 	= mean_cair + 1.96*(sd_cair / sqrt(n))
generate low_acc 	= mean_cair - 1.96*(sd_cair / sqrt(n))

graph twoway 	(connected mean_cair session if system_acc == 1, color(midgreen)) ///
				(connected mean_cair session if system_acc == 4, color(red)) ///

//	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
//	graphregion(color(white)) ///
//	xtitle(" ") ///
//	// xsize(2.5) ///
//	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
//	ylabel(1(1)6) ///
//	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
//	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore

// graph with 20 trials
preserve
collapse (mean) 	mean_cair= cair (sd) sd_cair = cair (count) n=cair, by(system_acc full_sequence)
bysort system_acc: 	sum mean_cair

generate hi_acc 	= mean_cair + 1.96*(sd_cair / sqrt(n))
generate low_acc 	= mean_cair - 1.96*(sd_cair / sqrt(n))

graph twoway 	(connected mean_cair full_sequence if system_acc == 1, color(midgreen)) ///
				(connected mean_cair full_sequence if system_acc == 4, color(red)) ///

	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
//	graphregion(color(white)) ///
//	xtitle(" ") ///
//	// xsize(2.5) ///
//	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
//	ylabel(1(1)6) ///
//	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
//	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore



// for H1, H2, H5, H6, we apply linear contrasting for the session variable (update made May 9)
gen session_linearcont = session - 2.5			// linear contrasting for the HHHH and LLLL trajectories



// H1 / H2 / H5 / H6 --> modeling the contrast variables to compare HHHH and LLLL
gen always_high = .
replace always_high = 1 if system_acc == 1 // HHHH
replace always_high = 0 if system_acc == 4 // LLLL

preserve
keep if inlist(system_acc, 1, 4)
restore 

// TRUST 

mixed 	trust_trial always_high	|| prolific_id: // Model 1


mixed 	trust_trial always_high##i.session 	|| prolific_id:
// H1a is not supported: no significant difference between trust in HHHH and LLLL
// H1b is not supported: no io effect of sessions for HHHH (vs LLLL)

mixed 	trust_trial always_high c.session_linearcont || prolific_id:
// Model 2 - giving overall trend over time indep. of acc

mixed 	trust_trial always_high##c.session_linearcont || prolific_id:
// Model 3

// predicted margins trust
margins always_high, at(session_linearcont=(1 2 3 4))
marginsplot

margins always_high, at(session=(1 2 3 4))
marginsplot



mixed 	trust_trial always_high c.session_linearcont || prolific_id: 

margins always_high#session_linearcont		

margins always_high, at(session_linearcont=(1 2 3 4))
marginsplot

mixed 	trust_trial always_high##c.session_linearcont || prolific_id:

margins always_high, at(session_linearcont=(1 2 3 4))
marginsplot



// CAIR

melogit cair always_high		|| prolific_id:
// Model 4


melogit cair always_high##i.session 		|| prolific_id:
// H2a supported: cair is higher for HHHH compared to LLLL (beta=0.67, p=0.012)
// H2b not supported: no effect of sessions for HHHH (vs LLLL)

margins always_high#session			// comparing CAIR rates conditional on eligibility --> y margins: in HHHH, CAIR was 34-41% and in LLLL, CAIR was 13-22%


margins always_high, at(session=(1 2 3 4)) post
marginsplot


melogit cair always_high c.session_linearcont 		|| prolific_id:					//H2a updated with new CAIR definition (25.8.)

melogit cair always_high##c.session_linearcont		|| prolific_id:					//H2b updated with new CAIR definition (25.8.)


// predicted margins CAIR
margins always_high, at(session=(1 2 3 4)) predict(pr)
marginsplot

margins always_high, at(session_linearcont=(1 2 3 4)) predict(pr)
marginsplot


// Additional analyses following H1 and H2, which will be exploratory (in the appendix)

// CSR 
melogit csr always_high##i.session 					|| prolific_id:
// csr is not higher for HHHH compared to LLLL
// csr also does not increase over sessions 

melogit csr always_high c.session_linearcont  		|| prolific_id:
melogit csr always_high##c.session_linearcont		|| prolific_id:					// model of additional analyses for H2 (25.8.)


melogit csr always_high								|| prolific_id:
melogit csr always_high c.session_linearcont 		|| prolific_id:
melogit csr always_high##c.session_linearcont		|| prolific_id:
// new models for additional exploration of CSR


// predicted margins of csr
margins always_high, at(session=(1 2 3 4)) predict(pr)
marginsplot

margins always_high, at(session_linearcont=(1 2 3 4)) predict(pr)
marginsplot



// OR  
melogit or always_high##i.session 		|| prolific_id:
// sign less overreliance for HHHH compared to LLLL (beta=-1.53, p=0.19)

melogit or always_high c.session_linearcont  		|| prolific_id: //M7
melogit or always_high##c.session_linearcont		|| prolific_id: //M8			// model of additional analysies for H2 (25.8.)


melogit or always_high								|| prolific_id:
melogit or always_high c.session_linearcont 		|| prolific_id:
melogit or always_high##c.session_linearcont		|| prolific_id:
// new models for additional exploration of OR


// predicted margins OR
margins always_high, at(session=(1 2 3 4)) predict(pr)
marginsplot

margins always_high, at(session_linearcont=(1 2 3 4)) predict(pr)
marginsplot



// UR 
melogit ur always_high##i.session 		|| prolific_id:								// model of additional analysies for H2 (25.8.)
// sign. more underreliance for HHHH (beta=+.1.14, p<0,001)

// updated once again on september 3 - I did not include the table of this one.


melogit ur always_high								|| prolific_id:
melogit ur always_high c.session_linearcont 		|| prolific_id:
melogit ur always_high##c.session_linearcont		|| prolific_id:
// new models for additional exploration of UR

// predicted margins UR
margins always_high, at(session=(1 2 3 4)) predict(pr)
marginsplot

**********************************************************************
**** Revision FB Vincent Buskens **************************************

// Trust H1a: Trust is higher for HHHH compared to LLLL.
mixed 	trust_trial always_high c.session_linearcont || prolific_id:

// Trust H1b: Trust increases more over time for HHHH compared to LLLL (adding interaction term)
mixed 	trust_trial always_high##c.session_linearcont || prolific_id:

margins always_high, at(session_linearcont=(1 2 3 4))
marginsplot


// CAIR H2a: CAIR is higher for HHHH compared to LLLL.
melogit cair always_high c.session_linearcont 		|| prolific_id:

// CAIR H2b: CAIR increases more over time for HHHH compared to LLLL.
melogit cair always_high##c.session_linearcont		|| prolific_id:

margins always_high, at(session_linearcont = (-1.5 -0.5 0.5 1.5)) // predicted probabilities
marginsplot
// PK: comparing CAIR rates conditional on eligibility --> margins: in HHHH, CAIR was 34-41% and in LLLL, CAIR was 13-22%


//significant difference of CAIR in HHHH vs LLLL (main effect) - we accept H2a
// this is supported by the predicted probabilities --> for LLLL: 15-20%, for HHHH: 33 - 39% 
//non-significant difference of CAIR over time in HHHH vs LLLL (interaction effect) - we reject H2b

// Mixed-effects logistic regression revealed a significant main effect of accuracy condition on CAIR. Participants in the HHHH condition showed consistently higher levels of correct reliance compared to the LLLL condition (b = 1.03, SE = 0.17, p < .001). To interpret these effects more directly, we computed predicted probabilities of CAIR from the model. These probabilities represent the likelihood that a participant, given their condition and session, relied on the AI when it was correct - when their initial decision was not. Importantly, predicted probabilities capture the conditional likelihood of CAIR, independent of how often correct AI advice occurred, ensuring that these results are not biased by differences in the availability of correct advice across conditions. In the LLLL condition, the chance of showing CAIR was only about 15–20% across sessions, meaning that most participants either failed to follow correct advice or followed incorrect advice. In contrast, in the HHHH condition, the chance of CAIR was roughly 33–39%, indicating that participants were about twice as likely to rely on the AI appropriately.

//For both accuracy conditions, CAIR showed a slight upward trend over sessions (b = 0.10, SE = 0.06, p = .071), although this effect was only marginally significant. Importantly, the interaction between accuracy and session was not significant (b = –0.03, SE = 0.11, p = .793), indicating that while CAIR rates were higher in HHHH, the developmental trajectory over time did not differ between conditions.


************************************************************************
************************************************************************

// some additions on august 25, 2025 from pk

gen IWR = (ai == best & finaldecision != ai & finaldecision != best)
tab IWR

count if cair==1
display "CAIR: " r(N)

count if or==1
display "OR: " r(N)

count if ur==1
display "UR: " r(N)

count if csr==1
display "CSR: " r(N)

count if IWR==1
display "IWR (remaining): " r(N)

tabstat cair csr or ur, by(system_acc) stat(mean sd n)

//////

//H3: testing whether HHLL and/or HLLL lead to overreliance

// system_acc 1 = "hhhh"
// system_acc 2 = "hhll"
// system_acc 3 = "hlll"
// system_acc 4 = "llll"
// system_acc 5 = "llhh"
// system_acc 6 = "lhhh"

preserve
collapse (mean) 	mean_or= or (sd) sd_or = or (count) n=or, by(system_acc session)
bysort system_acc: 	sum mean_or

generate hi_acc 	= mean_or + 1.96*(sd_or / sqrt(n))
generate low_acc 	= mean_or - 1.96*(sd_or / sqrt(n))

graph twoway 	(connected mean_or session if system_acc == 2, color(midgreen)) ///
				(connected mean_or session if system_acc == 3, color(red)) ///

	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore


melogit or i.session if system_acc == 2 || prolific_id:			// slightly diffrent values, but same results on 3.9.

// sign increase in OR in S3 (beta= +1.31, p=0.023)
// sign increase in OR in S4 (beta= +1.64, p=0.003)
// H3 for HHLL supported

margins session
marginsplot

melogit or i.session if system_acc == 3 || prolific_id:			// slightly diffrent values, but same results on 3.9.
// sign increase in OR in S3 (beta= +1.08, p=0.018) but not in S2 and S4
// H3 partially supported?

margins session
marginsplot



//H4: testing whether LLHH or LHHH read to underreliance
//plotting LLHH and LHHH

preserve
collapse (mean) 	mean_ur= ur (sd) sd_ur = ur (count) n=ur, by(system_acc session)
bysort system_acc: 	sum mean_ur

generate hi_acc 	= mean_ur + 1.96*(sd_ur / sqrt(n))
generate low_acc 	= mean_ur - 1.96*(sd_ur / sqrt(n))

graph twoway 	(connected mean_ur session if system_acc == 5, color(midgreen)) ///
				(connected mean_ur session if system_acc == 6, color(red)) ///

	// (rcap hi_acc low_acc session, color(black) lwidth(thin)), ///
	graphregion(color(white)) ///
	xtitle(" ") ///
	// xsize(2.5) ///
	xlabel(-0.3 " " 0 "Low" 1 "High" 1.3 " ", noticks) ///
	ylabel(1(1)6) ///
	ytitle("Reliance_Learning_Diagnostic", height(6)) ///
	legend(region(lwidth(none)) row(1) order(1 "hhhh" 2 "hhll" 3 "hlll" 4 "llll" 5 "llhh" 6 "lhhh"))
 
restore



// running the UR model for LLHH												// re-ran on 3.9.
melogit ur i.session if system_acc == 5 || prolific_id:

// significant UR in S3 (beta= +0.62, p=0.014) --> people do not trust it the HA yet!
// H4 partially accepted for LLHH - there is some underreliance in S3

margins session
marginsplot



// running the UR model for LHHH
melogit ur i.session if system_acc == 6 || prolific_id:
// S2 (beta= +0.14, p<0,001), S3 (beta= +1.18, p<0,001), S4 (beta= +0.79, p=.004) show underreliance!
// H4 for LHHH supported!

margins session
marginsplot



// additional models for H4 analysis on feb 16, 2026 //

mixed reliability i.session if system_acc == 5 || prolific_id:
margins session
marginsplot

mixed faith i.session if system_acc == 5 || prolific_id:
margins session
marginsplot

mixed reliability i.session if system_acc == 6 || prolific_id:
margins session
marginsplot

mixed faith i.session if system_acc == 6 || prolific_id:
margins session
marginsplot


mixed reliability i.session if system_acc == 2 || prolific_id:
margins session
marginsplot

mixed faith i.session if system_acc == 2 || prolific_id:
margins session
marginsplot

mixed reliability i.session if system_acc == 3 || prolific_id:
margins session
marginsplot

mixed faith i.session if system_acc == 3 || prolific_id:
margins session
marginsplot


/*

// H4a: Overreliance is higher for (HHLL) compared to (HLLL)

gen h4_condition = .
replace h4_condition = 1 if system_acc == 2 //HHLL 
replace h4_condition = 0 if system_acc == 3 //HLLL 

label define h4_condition 0 "HLLL" 1 "HHLL"
label values h4_condition h4_label

melogit or i.h4_condition##i.session if h4_condition < . || prolific_id: // not centered (old model)


melogit or i.h4_condition##c.session_linearcont if h4_condition < . || prolific_id:  // new models 13.5.


// H4b: Underreliance is higher for (LLHH) compared to (LHHH)

gen h4b_condition = .
replace h4b_condition = 1 if system_acc == 5 //LLHH 
replace h4b_condition = 0 if system_acc == 6 //LHHH 

label define h4b_condition 0 "LHHH" 1 "LLHH"
label values h4b_condition h4b_label


melogit ur i.h4b_condition##i.session if h4b_condition < . || prolific_id:

melogit ur i.h4b_condition##c.session_linearcont if h4b_condition < . || prolific_id: // new model 13.5.

*/
/*

********* modelling with martijn (16.5.) ****************************************


// H4a: OR is higher in the HHLL than HLLL
// H4b: UR is higher for LLHH than LHHH

// generating weighted contrasts - is S1 different to S1-4
gen step_1 = .
replace step_1 = 1 if session == 1
replace step_1 = -(1/3) if session > 1 

// generating weighted contrasts - is S1-2 different to S3-4
gen step_2 = .
replace step_2 = 0.5 if session < 3
replace step_2 = -0.5 if session > 2


// generate a linear contrast for DECAY OVER TIME - from High to Low (OR)

// isolating the slope between sessions 2 and 4 (for the HHLL condition)
gen step_1_lin = 0 
replace step_1_lin = 1 if session == 2
replace step_1_lin = -1 if session == 4

// isolating the slope between sessions 1 and 4 (for the HLLL condition)
gen step_2_lin = 0 
replace step_2_lin = 1 if session == 3
replace step_2_lin = -1 if session == 4



// OR models for the HLLL and HHLL conditions --> H4a

melogit or step_1 step_1_lin if system_acc == 3 || prolific_id:
// step_1 shows contrast between S1 and S2-4
// step_1_lin shows decay between S2 - 4

melogit or step_2 step_2_lin if system_acc == 2 || prolific_id:
// step_2 shows contrast between S1-2 and S3-4
// step_2_lin shows decay between S3-4



// UR for the LHHH and LLHH conditions --> H4b

melogit ur step_1 step_1_lin if system_acc == 6 || prolific_id:
// step_1 shows contrast between S1 and S2-4
// step_1_lin shows decay between S2 - 4

melogit ur step_2 step_2_lin if system_acc == 5|| prolific_id:
// step_2 shows contrast between S1-2 and S3-4
// step_2_lin shows decay between S3-4


// optional: this is just an additional check on the same models for CAIR
melogit cair step_1 step_1_lin if system_acc == 3 || prolific_id:
melogit cair step_2 step_2_lin if system_acc == 2|| prolific_id:
melogit cair step_1 step_1_lin if system_acc == 6 || prolific_id:
melogit cair step_2 step_2_lin if system_acc == 5|| prolific_id:



// defining the step to compare the HLLL / LHHH vs. HHLL / LLHH --> H5

// this version below did not work for the stata code
gen step = .
replace step = step_1 if system_acc == 3 | system_acc == 6
replace step = step_2 if system_acc == 2 | system_acc == 5

gen step_lin = .
replace step_lin = step_1_lin if system_acc == 3 | system_acc == 6
replace step_lin = step_2_lin if system_acc == 2 | system_acc == 5


melogit or step if system_acc == 3 | system_acc == 6|| prolific_id:
melogit ur step if system_acc == 2 | system_acc == 5|| prolific_id:

// generating another dummy to compare the difference between the early and later step (acc 2 vs. 5, 3 vs. 6) --> including the interaction in the models above

gen short_anchor = .
replace short_anchor = 1 if system_acc == 3 | system_acc == 6
replace short_anchor = 0 if system_acc == 2 | system_acc == 5

gen short_step = short_anchor*step

gen short_step_lin = short_anchor*step_lin

melogit cair short_anchor step short_step if system_acc == 2 | system_acc == 3 || prolific_id:

// 
melogit or short_anchor step short_step if system_acc == 2 | system_acc == 3 || prolific_id:
// long vs. short is not different from each other

melogit ur short_anchor step short_step if system_acc == 5 | system_acc == 6 || prolific_id:
// long vs. short is not different from each other 


// this is including the models above, but then again, we have the linear models
melogit or step short_step short_anchor step_lin short_step_lin if system_acc == 2 | system_acc == 3 || prolific_id:

margins system_acc, at(session_linearcont=(0 1 2 3))
marginsplot


melogit or step short_step short_anchor step_lin short_step_lin if system_acc == 5 | system_acc == 6 || prolific_id:
marginsplot


melogit cair short_anchor##c.session_linearcont 	|| prolific_id:

melogit or short_anchor##c.session_linearcont 	|| prolific_id:
melogit ur short_anchor##c.session_linearcont 	|| prolific_id:





melogit ur i.system_acc##c.session_linearcont if inlist(system_acc, 2, 3, 5, 6) || prolific_id:

margins system_acc, at(session_linearcont=(0 1 2 3))
marginsplot


melogit cair i.system_acc##c.session_linearcont if inlist(system_acc, 2, 3, 5, 6) || prolific_id:

margins system_acc, at(session_linearcont=(0 1 2 3))
marginsplot


melogit or i.system_acc##c.session_linearcont if inlist(system_acc, 2, 3, 5, 6) || prolific_id:

margins system_acc, at(session_linearcont=(0 1 2 3))
marginsplot


melogit ur i.system_acc##c.session_linearcont if inlist(system_acc, 2, 3, 5, 6) || prolific_id:

melogit ur i.system_acc##c.session_linearcont if inlist(system_acc, 2, 3, 5, 6) || prolific_id:


margins system_acc, at(session_linearcont=(0 1 2 3))
marginsplot

 */

****** Session May 22 **********************************

// system_acc 1 = "hhhh"
// system_acc 2 = "hhll"
// system_acc 3 = "hlll"
// system_acc 4 = "llll"
// system_acc 5 = "llhh"
// system_acc 6 = "lhhh"


// generating grouping variables for anchor comparisons
gen 	short_anchor = .
replace short_anchor = 1 if inlist(system_acc, 3, 6)	// short anchor: initially high/low
replace short_anchor = 0 if inlist(system_acc, 2, 5)	// long anchor: stepwise high/low


// generating the contrasts between S1 and the rest
gen step_1 = .
replace step_1 = 1 if session == 1
replace step_1 = -1/3 if inlist(session, 2, 3, 4)


// generating the contrasts between S1-2 and the rest
gen step_2 = .
replace step_2 = 0.5 if inlist(session, 1, 2)
replace step_2 = -0.5 if inlist(session, 3, 4)

// merging the contrast variables as preparation for the interaction
gen step = .
replace step = step_1 if system_acc == 3 | system_acc  == 6
replace step = step_2 if system_acc == 2 |  system_acc == 5

// interaction term to see whether trend is different for anchors
gen anchor_slope = short_anchor * step	


//H4a 															// re-run 4.9., but minor changes in values (no directional changes)
melogit or short_anchor if inlist(system_acc, 2,3) || prolific_id:
// the short anchor (HLLL) shows margin. sign. higher OR than long anchor (HHLL) - opposite findings of what we hypothesized
// b = +0.44, SE = 0.23, p = 0.052
// the intercept shows that OR probability is low for HHLL 

//H4b															// re-run 4.9., but minor changes in values (no directional changes)
melogit ur short_anchor if inlist(system_acc, 5,6) || prolific_id:
// the short anchor (LHHH) has sign. higher UR than long anchor (LLHH) - opposite than what we assumed
// b = +0.40, SE = 0.20, p = 0.043



//H5a											// re-run 4.9., but minor changes in values (no directional changes)				
melogit or short_anchor##c.step if inlist(system_acc, 2, 3) || prolific_id:
// HLLL has higher OR overall


//H5b											// re-run 4.9., but minor changes in values (no directional changes)
melogit ur short_anchor##c.step if inlist(system_acc, 5,6) || prolific_id:


// box plots to see the diffrence for H4a - not needed
label define anchor_h4a 0 "Long Anchor (HHLL)" 1 "Short Anchor (HLLL)"
label values short_anchor anchor_h4a

graph bar or if inlist(system_acc, 2, 3), over(short_anchor, label(labsize(small))) ///
    ytitle("Mean Overreliance") title("H4a: OR by Anchor Type") ///
    bargap(25) bar(1, color(skyblue)) bar(2, color(orange)) ///
    graphregion(color(white))


// box plots to see the difference for H4b - not needed
label define anchor_h4b 0 "Long Anchor (LLHH)" 1 "Short Anchor (LHHH)"
label values short_anchor anchor_h4b

graph bar ur if inlist(system_acc, 5, 6), over(short_anchor, label(labsize(small))) ///
    ytitle("Mean Underreliance") title("H4b: UR by Anchor Type") ///
    bargap(25) bar(1, color(skyblue)) bar(2, color(orange)) ///
    graphregion(color(white))


	
	
/*
//H5 --> wrong / old stuff


gen post_shift = .
replace post_shift = session - 1 if system_acc == 3 //HLLL accuracy drops after S1
replace post_shift = session - 2 if system_acc == 2 //HHLL accuracy drops after S2

gen post_shift2 = .
replace post_shift2 = session  -1 if system_acc == 6 //LHHH accuracy drops after S1
replace post_shift2 = session  -2 if system_acc == 5 //LLHH accuracy drops after S2


//H5a
melogit or i.h4_condition##c.post_shift if h4_condition < . & post_shift >= 1 || prolific_id:

//H5b:
melogit ur i.h4b_condition##c.post_shift2 if h4b_condition < . & post_shift2 >= 2 || prolific_id:

*/






//H6a: Trust and CAIR increase more over time in the Learning Frame condition for High Accuracy (HHHH) than for Low Accuracy (LLLL).

gen session_linearcont = session - 2.5			// linear contrasting for the HHHH and LLLL trajectories


mixed 	trust_trial 	i.learning_system##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4 || prolific_id:
melogit cair 			i.learning_system##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4 || prolific_id:		// the model that I ran based on the revised CAIR definition (25.8.)
melogit or 				i.learning_system##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4 || prolific_id:
melogit	ur				i.learning_system##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4 || prolific_id:

/* old code
//H6a, H7a
melogit cair 		learning_system##i.session  if always_high == 1 || prolific_id:
melogit or 			learning_system##i.session 	if always_high == 1 || prolific_id:
melogit ur 			learning_system##i.session 	if always_high == 1 || prolific_id:
mixed trust_trial 	learning_system##i.session 	if always_high == 1 || prolific_id:

melogit cair 		learning_system##c.session_linearcont   if always_high == 1 || prolific_id:
melogit or 			learning_system##c.session_linearcont 	if always_high == 1 || prolific_id:
melogit ur 			learning_system##c.session_linearcont 	if always_high == 1 || prolific_id:
mixed trust_trial 	learning_system##c.session_linearcont 	if always_high == 1 || prolific_id:

//H6b, H7b
melogit cair 		learning_system##i.session  if always_high == 0 || prolific_id:
melogit or 			learning_system##i.session 	if always_high == 0 || prolific_id:
melogit ur 			learning_system##i.session 	if always_high == 0 || prolific_id:
mixed trust_trial 	learning_system##i.session 	if always_high == 0 || prolific_id:

melogit cair 		learning_system##c.session_linearcont   if always_high == 0 || prolific_id:
melogit or 			learning_system##c.session_linearcont  	if always_high == 0 || prolific_id:
melogit ur 			learning_system##c.session_linearcont  	if always_high == 0 || prolific_id:
mixed trust_trial 	learning_system##c.session_linearcont  	if always_high == 0 || prolific_id:

// dieselben schritte mache ich für die task uncertainty, auch wieder split up between HHHH and LLLL für die effekte
*/



// visualizing static vs. learning for the HHHH condition - TRUST
preserve
collapse (mean) trust_trial (semean) trust_se = trust_trial, by(learning_system session) 

gen trust_upper = trust_trial + trust_se
gen trust_lower = trust_trial - trust_se

twoway ///
    (rcap trust_upper trust_lower session if learning_system==0, lcolor(blue)) ///
    (line trust_trial session if learning_system==0, lpattern(solid) lcolor(blue)) ///
    (rcap trust_upper trust_lower session if learning_system==1, lcolor(red)) ///
    (line trust_trial session if learning_system==1, lpattern(dash) lcolor(red)), ///
    legend(label(2 "Static") label(4 "Learning")) ///
    title("Trust Development in HHHH: Learning vs. Static") ///
    ytitle("Mean Trust") xtitle("Session") ///
    graphregion(color(white))

restore


// visualizing static vs. learning for the HHHH condition - CAIR
preserve

// Keep only HHHH condition
keep if system_acc == 1

// Collapse: mean CAIR and standard error
collapse (mean) cair (semean) cair_se = cair, by(learning_system session)

// Create upper/lower bounds for error bars
gen cair_upper = cair + cair_se
gen cair_lower = cair - cair_se

// Plot CAIR development for HHHH
twoway ///
    (rcap cair_upper cair_lower session if learning_system==0, lcolor(blue)) ///
    (line cair session if learning_system==0, lpattern(solid) lcolor(blue)) ///
    (rcap cair_upper cair_lower session if learning_system==1, lcolor(red)) ///
    (line cair session if learning_system==1, lpattern(dash) lcolor(red)), ///
    legend(label(2 "Static") label(4 "Learning")) ///
    title("CAIR Development in HHHH: Learning vs. Static") ///
    ytitle("Correct AI Reliance (CAIR)") xtitle("Session") ///
    graphregion(color(white))

restore



// visualizing static vs. learning for the LLLL condition - CAIR
preserve

// Keep only LLLL condition
keep if system_acc == 4

// Collapse: mean CAIR and standard error
collapse (mean) cair (semean) cair_se = cair, by(learning_system session)

// Create upper/lower bounds for error bars
gen cair_upper = cair + cair_se
gen cair_lower = cair - cair_se

// Plot CAIR development for HHHH
twoway ///
    (rcap cair_upper cair_lower session if learning_system==0, lcolor(blue)) ///
    (line cair session if learning_system==0, lpattern(solid) lcolor(blue)) ///
    (rcap cair_upper cair_lower session if learning_system==1, lcolor(red)) ///
    (line cair session if learning_system==1, lpattern(dash) lcolor(red)), ///
    legend(label(2 "Static") label(4 "Learning")) ///
    title("CAIR Development in LLLL: Learning vs. Static") ///
    ytitle("Correct AI Reliance (CAIR)") xtitle("Session") ///
    graphregion(color(white))

restore



// visualizing static vs. learning for the LLLL condition - TRUST

preserve

// Keep only LLLL condition
keep if system_acc == 4

// Collapse trust: mean and standard error
collapse (mean) trust_trial (semean) trust_se = trust_trial, by(learning_system session)

// Generate upper and lower bounds for error bars
gen trust_upper = trust_trial + trust_se
gen trust_lower = trust_trial - trust_se

// Plot: Trust development by framing
twoway ///
    (rcap trust_upper trust_lower session if learning_system==0, lcolor(blue)) ///
    (line trust_trial session if learning_system==0, lpattern(solid) lcolor(blue)) ///
    (rcap trust_upper trust_lower session if learning_system==1, lcolor(red)) ///
    (line trust_trial session if learning_system==1, lpattern(dash) lcolor(red)), ///
    legend(label(2 "Static") label(4 "Learning")) ///
    title("Trust Development in LLLL: Learning vs. Static") ///
    ytitle("Mean Trust") xtitle("Session") ///
    graphregion(color(white))

restore




// visualizing static vs. learning for the LLLL condition - CAIR
preserve

// Keep only LLLL condition
keep if system_acc == 4

// Collapse: mean CAIR and standard error
collapse (mean) cair (semean) cair_se = cair, by(learning_system session)

// Create upper/lower bounds for error bars
gen cair_upper = cair + cair_se
gen cair_lower = cair - cair_se

// Plot CAIR development for LLLL
twoway ///
    (rcap cair_upper cair_lower session if learning_system==0, lcolor(blue)) ///
    (line cair session if learning_system==0, lpattern(solid) lcolor(blue)) ///
    (rcap cair_upper cair_lower session if learning_system==1, lcolor(red)) ///
    (line cair session if learning_system==1, lpattern(dash) lcolor(red)), ///
    legend(label(2 "Static") label(4 "Learning")) ///
    title("CAIR Development in LLLL: Learning vs. Static") ///
    ytitle("Correct AI Reliance (CAIR)") xtitle("Session") ///
    graphregion(color(white))

restore




//H8a and H8b

melogit cair 	diagnostic##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4  || prolific_id:
melogit csr 	diagnostic##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4  || prolific_id:
melogit or 		diagnostic##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4  || prolific_id:
melogit ur 		diagnostic##c.session_linearcont##i.system_acc if system_acc == 1 | system_acc == 4  || prolific_id:
// running this model after revising CAIR definition (25.8. and 11.9.)

// visualizing CAIR for diagnostic vs. prognostic in the HHHH condition 
preserve

collapse (mean) cair, by(system_acc diagnostic session)

twoway (line cair session if system_acc==1 & diagnostic==0, lpattern(solid) lcolor(blue)) ///
       (line cair session if system_acc==1 & diagnostic==1, lpattern(dash) lcolor(red)), ///
       legend(label(1 "Diagnostic") label(2 "Prognostic")) ///
       title("CAIR over Sessions (HHHH)") ///
       xtitle("Session") ytitle("Mean CAIR") ///
       graphregion(color(white))
restore


// visualizing CAIR for diagnostic vs. prognostic in the LLLL condition 
preserve
mixed trust_trial i.session i.high_vs_low i.diagnostic i.learning_system c.competence || prolific_id: session // baseline + usefulness

collapse (mean) cair, by(system_acc diagnostic session)

twoway (line cair session if system_acc==4 & diagnostic==0, lpattern(solid) lcolor(blue)) ///
       (line cair session if system_acc==4 & diagnostic==1, lpattern(dash) lcolor(red)), ///
       legend(label(1 "Diagnostic") label(2 "Prognostic")) ///
       title("CAIR over Sessions (LLLL)") ///
       xtitle("Session") ytitle("Mean CAIR") ///
       graphregion(color(white))
restore



/*// additional analyses with co-variates (13.1.2026) - I commented them out as they were the wrong models (as we were not looking for moderation effects but main effects on reliability and faith)

// coding binary conditions for accuracy for the following analyses - having only HHHH and LLLL -- wrong models for the analysis for NHB

generate 	high_vs_low = .
replace		high_vs_low = 1 if system_acc == 1 // HHHH
replace		high_vs_low = 0 if system_acc == 4 // LLLL
	

mixed trust_trial i.session i.high_vs_low i.diagnostic i.learning_system || prolific_id: session // baseline model per session on trust

mixed trust_trial i.session i.high_vs_low i.diagnostic i.learning_system c.competence || prolific_id: session // baseline + competence
mixed trust_trial i.session i.high_vs_low i.diagnostic i.learning_system c.usefulness || prolific_id: session // baseline + usefulness (smaller effect than perceived competence)
mixed trust_trial i.session i.high_vs_low i.diagnostic i.learning_system c.reliability || prolific_id: session // baseline + reliability (similarly strong in effect to competence)
mixed trust_trial i.session i.high_vs_low i.diagnostic i.learning_system c.understandability || prolific_id: session // baseline + understandability (apparentlich, understanding matters less for trust, also considering time - it is not necessary for trust development over time)


melogit cair i.session i.high_vs_low i.diagnostic i.learning_system || prolific_id:  // baseline model for correct AI reliance

melogit cair i.session i.high_vs_low i.diagnostic i.learning_system c.competence || prolific_id:  // baseline + competence
melogit cair i.session i.high_vs_low i.diagnostic i.learning_system c.usefulness || prolific_id:  // baseline + usefulness (smaller effect than perceived competence)
melogit cair i.session i.high_vs_low i.diagnostic i.learning_system c.reliability || prolific_id:  // baseline + reliability (similarly strong in effect to competence)
melogit cair i.session i.high_vs_low i.diagnostic i.learning_system c.understandability || prolific_id:  // baseline + understandability (apparentlich, understanding matters less for trust, also considering time - it is not necessary for trust development over time)
*/



****************************************************************************************
// PK April 2, 2026
// FINAL MODELS for reliance measures, cognitive trust (trial level) and ...
// ADDITIONAL analyses with faith and reliability as DVs in the models (post-task)
****************************************************************************************

******* ACCURACY (HHHH vs. LLLL) *********

melogit cair		always_high c.session_linearcont 		|| prolific_id: // main effects
melogit cair 		always_high##c.session_linearcont		|| prolific_id:	// interactions

mixed 	trust_trial always_high c.session_linearcont 		|| prolific_id: // main effects
mixed 	trust_trial always_high##c.session_linearcont 		|| prolific_id: // interactions


mixed 	reliability 	always_high c.session_linearcont 	|| prolific_id:	// main effects
mixed 	reliability 	always_high##c.session_linearcont 	|| prolific_id: // interactions
mixed 	faith       	always_high c.session_linearcont 	|| prolific_id: // main effects
mixed 	faith       	always_high##c.session_linearcont 	|| prolific_id: // interactions


// additional exploratory analyses to CSR, OR, and UR:
melogit csr always_high								|| prolific_id:
melogit csr always_high c.session_linearcont 		|| prolific_id:
melogit csr always_high##c.session_linearcont		|| prolific_id:

melogit or always_high								|| prolific_id:
melogit or always_high c.session_linearcont 		|| prolific_id:
melogit or always_high##c.session_linearcont		|| prolific_id:


melogit ur always_high								|| prolific_id:
melogit ur always_high c.session_linearcont 		|| prolific_id:
melogit ur always_high##c.session_linearcont		|| prolific_id:




****** LEARNING FRAME (HHHH and LLLL only) *******
melogit cair 			i.learning_system##c.session_linearcont##i.system_acc 	if system_acc == 1 | system_acc == 4 || prolific_id:
melogit cair 			c.session_linearcont##i.learning_system 			  	if system_acc == 1 | system_acc == 4 || prolific_id: 



// Simple slopes for learning frame (2-way, HHHH and LLLL only)
mixed 	trust_trial   	i.learning_system##c.session_linearcont##i.system_acc 	if system_acc == 1 | system_acc == 4 || prolific_id:
mixed 	trust_trial 	c.session_linearcont##i.learning_system 			  	if system_acc == 1 | system_acc == 4 || prolific_id: 


// Simple slopes for learning frame (2-way, HHHH and LLLL only)
mixed 	trust_trial 		c.session_linearcont##i.learning_system 			if system_acc == 1 || prolific_id:
mixed 	trust_trial 		c.session_linearcont##i.learning_system 			if system_acc == 4 || prolific_id:



mixed	reliability 	i.learning_system##c.session_linearcont##i.system_acc 	if system_acc == 1 | system_acc == 4 || prolific_id:
mixed 	faith       	i.learning_system##c.session_linearcont##i.system_acc 	if system_acc == 1 | system_acc == 4 || prolific_id:

// additional exploratory analyses OR and UR
melogit or 				i.learning_system##c.session_linearcont##i.system_acc 	if system_acc == 1 | system_acc == 4 || prolific_id:
melogit	ur				i.learning_system##c.session_linearcont##i.system_acc 	if system_acc == 1 | system_acc == 4 || prolific_id:




******* TASK UNCERTAINTY  HHHH and LLLL only) *******
melogit cair 			i.diagnostic##c.session_linearcont##i.system_acc 		if system_acc == 1 | system_acc == 4  || prolific_id:
melogit cair 			i.diagnostic##c.session_linearcont 				 		if system_acc == 1 | system_acc == 4  || prolific_id:


// Simple slopes for task uncertainty (2-way, HHHH and LLLL only)
melogit csr 			i.diagnostic##c.session_linearcont##i.system_acc 		if system_acc == 1 | system_acc == 4  || prolific_id:
melogit or 				i.diagnostic##c.session_linearcont##i.system_acc 		if system_acc == 1 | system_acc == 4  || prolific_id:
melogit ur 				i.diagnostic##c.session_linearcont##i.system_acc 		if system_acc == 1 | system_acc == 4  || prolific_id:

mixed 	trust_trial   	i.diagnostic##c.session_linearcont##i.system_acc 		if system_acc == 1 | system_acc == 4 || prolific_id:


mixed 	reliability 	i.diagnostic##c.session_linearcont##i.system_acc 		if system_acc == 1 | system_acc == 4 || prolific_id:
mixed 	faith       	i.diagnostic##c.session_linearcont##i.system_acc 		if system_acc == 1 | system_acc == 4 || prolific_id:





******* ACCURACY CHANGE (improving / declining) conditions (HHLL, HLLL + LLHH, LHHH) ********

// Declining (HHLL, HLLL)
melogit or 			i.session if system_acc == 2 || prolific_id:	
melogit or 			i.session if system_acc == 3 || prolific_id:	

mixed reliability 	i.session if system_acc == 2 || prolific_id:
mixed faith       	i.session if system_acc == 2 || prolific_id:

mixed reliability 	i.session if system_acc == 3 || prolific_id:
mixed faith       	i.session if system_acc == 3 || prolific_id:

// Improving (LLHH, LHHH)
melogit ur 			i.session if system_acc == 5 || prolific_id:
melogit ur 			i.session if system_acc == 6 || prolific_id:


mixed reliability 	i.session if system_acc == 5 || prolific_id:
mixed faith       	i.session if system_acc == 5 || prolific_id:

mixed reliability 	i.session if system_acc == 6 || prolific_id:
mixed faith       	i.session if system_acc == 6 || prolific_id:




******* ANCHOR COMPARISONS  ********

// Declining accuracy (HHLL vs. HLLL)
melogit or			short_anchor 			if inlist(system_acc, 2,3) 	|| prolific_id:
melogit or 			short_anchor##c.step 	if inlist(system_acc, 2, 3) || prolific_id:

mixed reliability 	short_anchor			if inlist(system_acc, 2, 3) || prolific_id:
mixed reliability 	short_anchor##c.step 	if inlist(system_acc, 2, 3) || prolific_id:

mixed faith       	short_anchor    		if inlist(system_acc, 2, 3) || prolific_id:
mixed faith       	short_anchor##c.step 	if inlist(system_acc, 2, 3) || prolific_id:


// Improving accuracy (LLHH vs. LHHH)
melogit ur			short_anchor            if inlist(system_acc, 5, 6) || prolific_id:
melogit ur 			short_anchor##c.step 	if inlist(system_acc, 5,6) 	|| prolific_id:

mixed reliability 	short_anchor            if inlist(system_acc, 5, 6) || prolific_id:
mixed reliability 	short_anchor##c.step 	if inlist(system_acc, 5, 6) || prolific_id:

mixed faith       	short_anchor            if inlist(system_acc, 5, 6) || prolific_id:
mixed faith       	short_anchor##c.step 	if inlist(system_acc, 5, 6) || prolific_id:
