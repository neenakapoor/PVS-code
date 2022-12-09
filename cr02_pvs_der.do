* PVS deriving variables for aanalysis 
* September 2022
* N. Kapoor 

/*

This file loads creates derived variables for analysis from the multi-country 
dataset created in the cr01 file. 

*/

***************************** Deriving variables *****************************

u "$data_mc/02 recoded data/pvs_ke_et_lac_01.dta", clear

*------------------------------------------------------------------------------*

* age_calc: exact respondent age or middle of age range 
gen age_calc = q1 
recode age_calc (.r = 23.5) if q2 == 0
recode age_calc (.r = 34.5) if q2 == 1
recode age_calc (.r = 44.5) if q2 == 2
recode age_calc (.r = 54.5) if q2 == 3
recode age_calc (.r = 64.5) if q2 == 4
recode age_calc (.r = 74.5) if q2 == 5
recode age_calc (.r = 80) if q2 == 6
lab def ref .r "refused"
lab val age_calc ref

* age_cat: categorical age 
gen age_cat = q2
recode age_cat (.a = 0) if q1 >= 18 & q1 <= 29
recode age_cat (.a = 1) if q1 >= 30 & q1 <= 39
recode age_cat (.a = 2) if q1 >= 40 & q1 <= 49
recode age_cat (.a = 3) if q1 >= 50 & q1 <= 59
recode age_cat (.a = 4) if q1 >= 60 & q1 <= 69
recode age_cat (.a = 5) if q1 >= 70 & q1 <= 79
recode age_cat (.a = 6) if q1 >= 80
lab val age_cat age_cat

* female: gender 	   
gen gender = q3
lab val gender gender

* NOTE: I renamed this from female to gender because 'another gender' 
* 		Let me know if you disagree  

* covid_vax
recode q14 ///
	(0 = 0 "Unvaccinated (0 doses)") (1 = 1 "Partial vaccination (1 dose)") /// 
	(2 3 4 = 2 "Fully vaccinated (2+ doses)") (.r = .r Refused) (.a = .a NA), ///
	gen(covid_vax)
	
* covid_vax_intent 
gen covid_vax_intent = q15 
lab val covid_vax_intent yes_no_doses

* patient_activiation
* NOTE: See if this code makes sense 
gen patient_activation = 2 if q16 == 3 & q17 == 3	
recode patient_activation (. = 1) if q16 == 3 & q17 == 2 | q16 == 2 & q17 == 3 | /// 
						  q16 == 2 & q17 == 2	
recode patient_activation (. = .r) if q16 == .r | q17 == .r
recode patient_activation (. = 0) if q16 == 0 | q16 == 1 | q17 == 0 | q17 == 1
lab def pa 0 "Not activated (Not too confident and Not at all confident for either category)" ///
			1 "Somewhat activated (Very or somewhat confident on Q16 and Q17)" /// 
			2 "Activated (Very confident on Q16 and Q17)" .r "Refused", replace
lab val patient_activation pa

* usual_reason
recode q21 (2 = 1 "Convenience (short distance)") /// 
			(1 8 = 2 "Cost (low cost, covered by insurance)") ///
			(4 = 3 "Techincal quality (provider skills)") ///
			(3 5 = 4 "Interpersonal quality (short waiting time, respect)") ///
			(6 = 5 "Service readiness (medicines and equipment available)") ///
			(7 = 6 "Only facility available") ///
			(.r 9 = .r "Other or Refused") ///
			(.a = .a "NA") , gen(usual_reason)

* visits
gen visits = 0 if q23 == 0 | q24 == 0
recode visits (. = 1) if q23 >=1 & q23 <= 4 | q24 == 1
recode visits (. = 2) if q23 > 4 & q23 < . | q24 == 2 | q24 == 3
recode visits (. = .r) if q23 == .r | q24 == .r
lab def visits 0 "Non-user (0 visits)" 1 "Occasional usuer (1-4 visits)" ///
			   2 "Frequent user (more than 4)" .r "Refused"
lab val visits visits	

* visits_covid
gen visits_covid = q25_b
recode visits_covid (.a = 1) if q25_a == 1

*fac_number
* NOTE: what to do with people who say 0 or 1 for Q27? It's 24 people - for now put them in 0 group
gen fac_number = 0 if q26 == 1 | q27 == 0 | q27 == 1
recode fac_number (. = 1) if q27 == 2 | q27 == 3
recode fac_number (. = 2) if q23 > 3
recode fac_number (. = .a) if q26 == .a | q27 == .a
recode fac_number (. = .r) if q26 == .r | q27 == .r
lab def fn 0 "1 facility (Q26 is yes)" 1 "2-3 facilities (Q27 is 2 or 3)" ///
		   2 "More than 3 facilities (Q27 is 4 or more)" .a "NA" .r "Refused"
lab val fac_number fn

* visits_total
gen visits_total = q23 + q28_a + q28_b
* NOTE: 
* something strange may be happening with Q28_A refuse 
* ^ future NRK does not remember why past NRK wrote that
recode visits_total (. = .r) if q23 == .d | q23 == .r | q28_a == .d | q28_a == .r ///
								| q28_b == .d | q28_b == .r
* ^just changing them all to refuse for now

* systems_fail 
* NOTE: see if systems_fail code makes sense
gen system_fail = 1 if q39 == 1 | q40 == 1	   
recode system_fail (. = 0) if q39 == 0 & q40 == 0	
recode system_fail (. = .r) if q39 == .r | q40 == .r	      
recode system_fail (. = .a) (0 = .a) (1 = .a) if q39 == .a | q40 == .a	   
lab val system_fail yes_no_na

* unmet_reason 
recode q42 (1 = 1 "Cost (High cost)") ///
			(2 = 2 "Convenience (Far distance)") ///
			(3 5 = 3 "Interpersonal quality (Long waiting time, Respect)") ///
			(4 = 4 "Technical quality (Poor provider skills)") ///
			(6 = 5 "Service readiness (Medicines and equipment not available)") ///
			(8 9 = 6 "COVID (COVID restritions or COVID fear)") ///
			(10 = 7 "Other") ///
			(.a 7 = .a "NA or Illness not serious") ///
			(.r = .r "Refused"), gen(unmet_reason)

* last_reason
gen last_reason = q45
lab def lr 1 "Urgent or new problem" 2 "Follow-up for chronic disease" ///
		   3 "Preventative or health check" 995 "Other" .a "NA" .r "Refused"
lab val last_reason lr

*last_wait_time
gen last_wait_time = 0 if q46_min <= 15
recode last_wait_time (. = 1) if q46_min >= 15 & q46_min < 60
recode last_wait_time (. = 2) if q46_min >= 60 & q46_min < .
recode last_wait_time (. = .a) if q46_min == .a
recode last_wait_time (. = .r) if q46_min == .r
lab def lwt 0 "Short (15 minutes)" 1 "Moderate (< 1 hour)" 2 "Long (> 1 hour)" ///
			.r "Refused" .a "NA"
lab val last_wait_time lwt

*last_visit_time
gen last_visit_time = 0 if q47_min <= 15
recode last_visit_time (. = 1) if q47_min > 15 & q47_min < .
recode last_visit_time (. = .a) if q47_min == .a
recode last_visit_time (. = .r) if q47_min == .r
lab def lvt 0 "<= 15 minutes" 1 "> 15 minutes " ///
			.r "Refused" .a "NA"
lab val last_visit_time lvt

* last_promote
gen last_promote = 0 if q49 < 8
recode last_promote (. = 1) if q49 == 8 | q49 == 9 | q49 == 10
recode last_promote (. = .a) if q49 == .a
recode last_promote (. = .r) if q49 == .r
lab def lp 0 "Detractor" 1 "Promoter" .r "Refused" .a "NA"
lab val last_promote lp

* system_outlook 
gen system_outlook = q57
lab val system_outlook system_outlook

* system_reform 
gen system_reform = q58
lab def sr 1 "Health system needs to be rebuilt" 2 "Health system needs major changes" /// 
		3 "Health system only needs minor chanes" .r "Refused", replace
lab val system_reform sr

**** Yes/No Questions ****

* insured, health_chronic, ever_covid, covid_confirmed, usual_source inpatient
* unmet_need 
* Yes/No/Refused -Q6 Q11 Q12 Q13 Q18 Q29 Q41 
gen insured = q6 
gen health_chronic = q11
gen ever_covid = q12
gen covid_confirmed = q13 
gen usual_source = q18
gen inpatient = q29 
gen unmet_need = q41 
lab val insured health_chronic ever_covid covid_confirmed usual_source ///
		inpatient unmet_need yes_no

* blood_pressure mammogram cervical_cancer eyes_exam teeth_exam blood_sugar  
* blood_chol care_mental 
* Yes/No/Don't Know/Refused - Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q66 
gen blood_pressure = q30 
gen mammogram = q31
gen cervical_cancer = q32
gen eyes_exam = q33
gen teeth_exam = q34
gen blood_sugar = q35 
gen blood_chol = q36
gen care_mental = q38 
lab val blood_pressure mammogram cervical_cancer eyes_exam teeth_exam /// 
	blood_sugar blood_chol care_mental yes_no_dk
	
**** Excellent to Poor scales *****	   
* NOTE: I left my previous code commented out for now, Todd you can delete 

* health, health_mental, last_qual, last_skills, last_supplies, last_respect, 
* last_explain, last_decision, last_visit_rate, last_wait_rate, vignette_poor,
* vignette_good

* recode Q9 Q10 Q48_A Q48_B Q48_C Q48_D Q48_F Q48_G Q48_H Q48_I Q60 Q61 /// 
*	   (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") /// 
*	   (.r = .r "Refused") (.a = .a NA), pre(der)label(exc_poor_der2)
	   	   
* ren (derQ9 derQ10 derQ48_A derQ48_B derQ48_C derQ48_D derQ48_F derQ48_G derQ48_H /// 
*	 derQ48_I derQ60 derQ61) (health health_mental last_qual last_skills /// 
*	 last_supplies last_respect last_explain last_decisions ///
*	 last_visit_rate last_wait_rate vignette_poor vignette_good)

gen health = q9 
gen health_mental = q10 
gen last_qual = q48_a 
gen last_skills = q48_b 
gen last_supplies = q48_c 
gen last_respect = q48_d 
gen last_explain = q48_f 
gen last_decisions = q48_g
gen last_visit_rate = q48_h 
gen last_wait_rate = q48_i 
gen vignette_poor = q60
gen vignette_good = q61
lab val health health_mental last_qual last_skills last_supplies last_respect /// 
last_explain last_decisions last_visit_rate last_wait_rate vignette_poor /// 
vignette_good exc_poor

* usual_quality,last_know, last_courtesy 

*recode Q22 (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
*	   (.a = .a "I did not receive healthcare form this provider in the past 12 months"), /// 
*	   pre(der)label(exc_pr_hlthcare_der)

*recode Q48_E (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
*	   (.a = .a "I have not had prior visits or tests"), /// 
*	   pre(der)label(exc_pr_visits_der)

*recode Q48_J (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
*	   (.a = .a "The clinic had no other staff"), /// 
*	   pre(der)label(exc_pr_staff_der)

* phc_women phc_child phc_chronic phc_mental

* recode Q50_A Q50_B Q50_C Q50_D ///
*	   (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
*	   (.d = .d "The clinic had no other staff"), /// 
*	   pre(der) label(exc_pr_judge_der)

* ren (derQ50_A derQ50_B derQ50_C derQ50_D) ///
*	(phc_women phc_child phc_chronic phc_mental)
	   

gen usual_quality =q22
gen last_know = q48_e
gen last_courtesy = q48_j
lab val usual_quality exc_pr_hlthcare
lab val last_know exc_pr_visits
lab val last_courtesy exc_poor_staff

gen phc_women = q50_a
gen phc_child = q50_b
gen phc_chronic = q50_c
gen phc_mental = q50_d
lab val phc_women phc_child phc_chronic phc_mental exc_poor_judge

* qual_public qual_private qual_ngo covid_manage

* recode q54 q55 q56_ke_et q56_pe q56_uy q59 /// 
*	   (0 1 = 0 "fair/poor") (2 = 1 "good") ( 3 4 = 2 "excellent/very good") /// 
*	   (.r = .r "refused") (.a = .a na), pre(der) label(exc_poor_der3)

*ren (derq54 derq55 derq56_ke_et derq56_pe derq56_uy derq59) ///
*    (qual_public qual_private qual_ngo_ke qual_ss_pe qual_mut_uy covid_manage)
	
gen qual_public = q54
gen qual_private = q55 
gen qual_ngo_ke = q56_ke_et
gen qual_ss_pe = q56_pe
gen qual_mut_uy = q56_uy
gen covid_manage = q59
lab val qual_public qual_private qual_ngo_ke qual_ss_pe qual_mut_uy covid_manage exc_poor

**** All Very Confident to Not at all Confident scales ****

* conf_sick conf_afford conf_opinion

recode q51 q52 q53 ///
	   (3 = 1 "Very confident") ///
	   (0 1 2 = 0 "Somewhat confident/Not too confident/Not at all confident") /// 
	   (.r = .r refused) (.a = .a na), /// 
	   pre(der) label(vc_nc_der)

ren (derq51 derq52 derq53) (conf_sick conf_afford conf_opinion)

**** COUNTRY SPECIFIC ****
* NOTE to Rodrigo: 
* An important thing to review with these items will be that there is no overlap 
* in numbers between two categories - that will results in error in the recode
* Browsing var # by derived variable will be a good way to review work as well as 
* two-way tab 
* Another thing you could do is look at the megatables to see if the percents
* are what is expected between the Q# and derived variable (same idea as two-way tab)

* urban: type of region respondent lives in 
recode q4 (6 7 9 10 12 13 = 1 "Urban") (8 11 14 = 0 "Rural") ///
		  (.r = .r "Refused"), gen(urban)
*Ro comment: value lables 1-4, 15-17 are missing. Described below:
	*1=city, 2=suburb of city, 3=small town, 4=rural area, 15=city, 16=town, 17=village
	

* insur_type 
* NOTE: check other, specify later
* Javier said Mutualists is not public or private

recode q7 (1 3 15 16 17 18 10 11 12 19 22 = 0 Public) (2 4 5 6 7 28 13 21 = 1 Private) /// 
		  (20 995 = 3 Other) ///
		  (.r = .r "Refused") (.a = .a NA), gen(insur_type)
*Ro comment: value labels 8, 9, 14, 23, 24, 25, 26, 27, 28 are missing. Described below:
	*8=hospital plan, 9=hospital plan with day-to-day benefits, 14=you don't have insurance, 23=central government health scheme (cghs), 24=state government health scheme, 25=employee state health insurance scheme (ESI), 26=Ayushman Bharat Pradhan Mantri Jan Arogya Yojna (PMJAY), 27=private health insurance, 28=private 

* education 
recode q8 (1 2 7 25 26 18 19 32 33 = 0 "None") /// 
		  (3 8 27 20 34 = 1 "Primary") (4 9 28 21 35 = 2 "Secondary") /// 
	      (5 10 11 29 30 31 22 23 24 36 37 38 = 3 "Post-secondary") ///
		  (.r = .r "Refused"), gen(education)
*Ro comment: value lables 5, 6, 12, 13, 14, 15, 16, 17, 39-44 are missing. Described below:
	*6=Degree and above, 12 No schooling, 13 Some primary education, 14 Primary education completed, 15 Some secondary education, 16 Secondary education completed, 17 Tertiary education, 39 Never attended or only kindergarten, 40 Class 1 to class 8 (elementary), 41 Class 9 to class 11 (some high school), 42 Class 12 or GED (High school graduate), 43 College 1 year to 3 years (Diploma or College Degree), 44 College 4 years or more (Post-graduate)

recode q19_ke_et (1 = 0 Public) (2 3 = 1 Private) (4 = 2 other) /// 
		(.a = .a NA) (.r = .r Refused), ///
		gen(usual_type_own)
recode usual_type_own (.a = 0) if q19_co == 1 | q19_pe == 1 | q19_uy == 1
recode usual_type_own (.a = 1) if q19_co == 2 | q19_pe == 2 | q19_uy == 2 
recode usual_type_own (.a = 2) if q19_uy == 5 | q19_uy == 995
recode usual_type_own (.a = .r) if q19_co == .r | q19_pe == .r | q19_uy == .r | q19_uy == .r
*Ro comment: q19_co and q19_pe have value 5=mutual as a label, not used in the code.

* usual_type_lvl 
recode q20 (1 2 3 6 7 8 11 23 12 14 15 17 18 20 80 85 90 40 43 45 47 48 92 94 96 98 100 102 104 = 0 "Primary") /// 
		   (4 5 9 13 19 21 81 82 86 87 41 42 44 46 49 93 97 101 103 105 = 1 "Secondary (or higher)") ///
		   (.a = .a "NA") (995 .r = .r "Refused"), gen(usual_type_lvl)
*Ro comments: 
*What's a primary hospital (value 3)? Is it primary or secondary level? I imagine it's a hospital would basic services, so who knows where it fits. In usal_type_lvl it is coded as "primary" and in last_type level it's coded as "secondary".
*values 46, 82, 87 are "clinic" but they are in secondary on the code
*Value labels 16, 23-37, 50-76, 83, 84, 88, 89, 91, 95, 99 are missing. Described below:
	*16 Mobile clinic, 23 Mobile clinic, 24 Ward-based outreach care, 25 Health posts,26 Department of health clinic, 27 Municipal clinic, 28 Department of health community health centre, 29 District hospital, 30 Department of health hospital (Regional, Tertiary and Central hospitals), 31 General practitioner practices, 32 Private clinics, 33 Private health centres, 34 Specialist private practices, 35 Private hospital, 36 Faith-based or mission clinic, 37 Faith-based or mission hospital, 50 Other primary care facility, specify, 51 Other secondary care facility or more, specify, 67 Sub-centre/Health and Wellness Centre, 68 Primary Health Centre, 69 Community Health Centre, 70 District Hospital, 71 Medical College, 72 Informal Providers (RMP), 73 Private clinic, 74 Private nursing home, 75 Private hospital, 76 Faith-based or charitable hospital (religion or sect based facility),  83 Other primary care facility, specify, 84 Another secondary care facility or more, specify,  88 Other primary care facility, specify, 89 Other secondary care facility or more, specify, 91 Other secondary care facility or more, specify, 95 Another secondary care establishment or more, specify, 99 Another secondary care establishment or more, specify
  
* usual_type_own_lvl
gen usual_type_own_lvl = . 
recode usual_type_own_lvl (. = 0) if usual_type_own == 0 & usual_type_lvl == 0
recode usual_type_own_lvl (. = 1) if usual_type_own == 0 & usual_type_lvl == 1
recode usual_type_own_lvl (. = 2) if usual_type_own == 1 & usual_type_lvl == 0
recode usual_type_own_lvl (. = 3) if usual_type_own == 1 & usual_type_lvl == 1
recode usual_type_own_lvl (. = 4) if usual_type_own == 2 & usual_type_lvl == 0
recode usual_type_own_lvl (. = 5) if usual_type_own == 2 & usual_type_lvl == 1
recode usual_type_own_lvl (. = .a) if usual_type_own == .a | usual_type_lvl == .a
recode usual_type_own_lvl (. = .r) if usual_type_own == .r | usual_type_lvl == .r
lab def fac_own_lvl 0 "Public primary" 1 "Public secondary (or higher)" 2 "Private primary" /// 
					3 "Private secondary (or higher)" 4 "Other primary" 5 "Other secondary (or higher)" ///
					.a NA .r Refused, replace
lab val usual_type_own_lvl fac_own_lvl

* last_type_own
recode q43_ke_et (1 = 0 Public) (2 3 = 1 Private) (4 = 2 other) /// 
		(.a = .a NA) (.r = .r Refused), ///
		gen(last_type_own)
recode last_type_own (.a = 0) if q43_co == 1 | q43_pe == 1 | q43_uy == 1
recode last_type_own (.a = 1) if q43_co == 2 | q43_pe == 2 | q43_uy == 2 | q43_uy == 3
recode last_type_own (.a = 2) if q43_uy == 5
recode last_type_own (.a = .r) if q43_co == .r | q43_pe == .r | q43_uy == .r | q43_uy == .r
*Ro comment: q43_co and q43_pe have value 5=mutual as a label, not used in the code.

* last_type_lvl 

recode q44 (1 2 6 7 11 23 12 14 15 17 18 20 80 85 90 40 43 45 47 48 92 94 96 98 100 102 104 = 0 "Primary") /// 
		   (3 4 5 8 9 13 19 21 81 82 86 87 41 42 44 46 49 93 97 101 103 105 = 1 "Secondary (or higher)") ///
		   (.a = .a "NA") (995 .r = .r "Refused"), gen(last_type_lvl)
*Ro comments: 
*What's a primary hospital (value 3)? Is it primary or secondary level? I imagine it's a hospital would basic services, so who knows where it fits. In usal_type_lvl it is coded as "primary" and in last_type level it's coded as "secondary".
*values 46, 82, 87 are "clinic" but they are in secondary on the code
*Value labels 16, 23-37, 50-76, 83, 84, 88, 89, 91, 95, 99 are missing. Described below:
	*16 Mobile clinic, 23 Mobile clinic, 24 Ward-based outreach care, 25 Health posts,26 Department of health clinic, 27 Municipal clinic, 28 Department of health community health centre, 29 District hospital, 30 Department of health hospital (Regional, Tertiary and Central hospitals), 31 General practitioner practices, 32 Private clinics, 33 Private health centres, 34 Specialist private practices, 35 Private hospital, 36 Faith-based or mission clinic, 37 Faith-based or mission hospital, 50 Other primary care facility, specify, 51 Other secondary care facility or more, specify, 67 Sub-centre/Health and Wellness Centre, 68 Primary Health Centre, 69 Community Health Centre, 70 District Hospital, 71 Medical College, 72 Informal Providers (RMP), 73 Private clinic, 74 Private nursing home, 75 Private hospital, 76 Faith-based or charitable hospital (religion or sect based facility),  83 Other primary care facility, specify, 84 Another secondary care facility or more, specify,  88 Other primary care facility, specify, 89 Other secondary care facility or more, specify, 91 Other secondary care facility or more, specify, 95 Another secondary care establishment or more, specify, 99 Another secondary care establishment or more, specify
		   
* last_type_own_lvl
gen last_type_own_lvl = . 
recode last_type_own_lvl (. = 0) if last_type_own == 0 & last_type_lvl == 0
recode last_type_own_lvl (. = 1) if last_type_own == 0 & last_type_lvl == 1
recode last_type_own_lvl (. = 2) if last_type_own == 1 & last_type_lvl == 0
recode last_type_own_lvl (. = 3) if last_type_own == 1 & last_type_lvl == 1
recode last_type_own_lvl (. = 4) if last_type_own == 2 & last_type_lvl == 0
recode last_type_own_lvl (. = 5) if last_type_own == 2 & last_type_lvl == 1
recode last_type_own_lvl (. = .a) if last_type_own == .a | last_type_lvl == .a
recode last_type_own_lvl (. = .r) if last_type_own == .r | last_type_lvl == .r
lab def fac_own_lvl 0 "Public primary" 1 "Public secondary (or higher)" 2 "Private primary" /// 
					3 "Private secondary (or higher)" 4 "Other primary" 5 "Other secondary (or higher)" ///
					.a NA .r Refused, replace
lab val last_type_own_lvl fac_own_lvl

* Previous code for facility type

* usual_type 
* recode Q20 (1 2 12 14 15 16 23 80 82 83 40 43 92 94 = 0 "Public primary") /// 
*		   (3 4 5 13 81 84 41 42 44 93 = 1 "Public Secondary") ///
*		   (6 7 11 17 18 20 85 87 88 45 46 47 48 96 97 98 100 101 102 = 2 "Private primary") /// 
*		   (8 9 19 21 86 89 49 99 103 = 3 "Private secondary") ///
*		   (90 104 51 105 995 = 4 "Other") ///
*		   (.a = .a "NA") ( .r = .r "Refused"), gen(usual_type)
		   
* last_type 
* recode Q44 (1 2 12 14 15 16 23 80 82 83 40 43 92 94 = 0 "Public primary") /// 
*		   (3 4 5 13 81 84 41 42 44 93 = 1 "Public Secondary") ///
*		   (6 7 11 17 18 20 85 87 88 45 46 47 48 96 97 98 100 101 102 = 2 "Private primary") /// 
*		   (8 9 19 21 86 89 49 99 103 = 3 "Private secondary") ///
*		   (90 104 51 50 91 105 995 = 4 "Other") ///
*		   (.a = .a "NA") (.r = .r "Refused"), gen(last_type)

* native language
recode q62 (1 5 8 9 10 11 12 13 14 15 23 24 25 26 27 28 29 30 31 32 ///
			44 45 49 81 = 0 "Minority group languages") /// 
		   (2 3 4 6 7 21 22 53 87 = 1 "Majority group languages") /// 
		   (995 998 = 2 "Other") ///
		   (.r = .r "Refused") (.a = .a "NA"), gen(native_lang)
*Ro comment: how do you know if they are minority or majority, do you have a list? 
*30, 31 and 32 don't seem to be a value in the labels51 (q62 value label).
*There are several values not included: 33 Sepedi, 34 Sesotho,35 Setswana,36 siSwati,37 Tshivenda,38 Xitsonga,39 Afrikaans,40 English, 41 isiNdebele,42 isiXhosa,43 isiZulu,46 Ashaninka,47 Awajún/Aguaruna,48 Shipibo/Konibo, 50 Matsigenka/ Machiguenga,51 Achua,52 Other native or original language,54 Portuguese,55 Assamese,56 Bengali,57 Bodo,58 Dogri,59 Gujarati,60 Hindi,61 Kannada,62 Kashmiri,63 Konkani,64 Maithili,65 Malayalam,66 Manipuri,67 Marathi,68 Nepali,69 Odia,70 Punjabi,71 Sanskrit,72 Santali,73 Sindhi,74 Tamil,75 Telugu,76 Urdu,77 Lenguas arawak,78 Lenguas barbacoanas,79 Lenguas witoto,80 Lenguas caribes,82 Lenguas chocó,83 Lenguas guahibanas, 84 Lenguas makú,85 Lenguas quechuas,86 Lenguas tucanas, 88 Portuguese,89 English

* income
recode q63 (1 2 9 10 39 40 48 31 32 38 49 50 61 = 0 "Lowest income") /// 
		   (3 4 5 11 12 41 42 43 33 34 35 51 52 53 = 1 "Middle income") /// 
		   (6 7 13 14 44 45 36 37 54 55 = 2 "Highest income") ///
		   (.r = .r "Refused") (.d = .d "Don't know"), gen(income)
*Ro comment: what was the reference to classify them?
*14,11,12,10,9,13 don't seem to be a value in the labels52 (q63 value label).
*15-30, 45-48, 56-61 are not included.
		   
* NOTE: Ignored country-specific questions Q13B and Q13E

**** Order Variables ****
		   
order respondent_serial respondent_id psu_id interviewerid_recoded /// 
	  interviewer_language interviewer_gender mode country language date ///
	  time int_length q1_codes q1 q2 q3 q3a q4 q5 q6 q7 ///
	  q7_other  q8 q9 q10 q11 q12 q13 q13b q13e q13e_10 q14 q15 q16 q17 q18 ///
	  q19_ke_et q19_co q19_pe q19_uy q19_other q20 q20_other q21 q21_other q22 ///
	  q23 q24 q25_a q25_b q26 q27 q28_a q28_b q29 q30 q31 q32 q33 q34 q35 q36 ///
	  q38 q39 q40 q41 q42 q42_other q43_ke_et q43_co q43_pe q43_uy q43_other q44 ///
	  q44_other q45 q45_other q46 q46_min q46_refused q47 q47_min q47_refused ///
	  q48_a q48_b q48_c q48_d q48_e q48_f q48_g q48_h q48_i q48_j q49 q50_a ///
	  q50_b q50_c q50_d q51 q52 q53 q54 q55 q56_ke_et q56_pe q56_uy q57 q58 q59 ///
	  q60 q61 q62 q62_other q63 q64 q65 age_calc age_cat gender ///
	  urban insured insur_type education health health_mental health_chronic ///
	  ever_covid covid_confirmed covid_vax covid_vax_intent patient_activation ///
	  usual_source usual_type_own usual_type_lvl usual_type_own_lvl ///
	  usual_reason usual_quality visits visits_covid ///
	  fac_number visits_total inpatient blood_pressure mammogram ///
	  cervical_cancer eyes_exam teeth_exam blood_sugar blood_chol care_mental /// 
	  system_fail unmet_need unmet_reason last_type_own last_type_lvl ///
	  last_type_own_lvl last_reason last_wait_time ///
	  last_visit_time last_qual last_skills last_supplies last_respect last_know ///
	  last_explain last_decisions last_visit_rate last_wait_rate last_courtesy ///
	  last_promote phc_women phc_child phc_chronic phc_mental conf_sick ///
	  conf_afford conf_opinion qual_public qual_private qual_ngo_ke qual_ss_pe ///
	  qual_mut_uy system_outlook system_reform covid_manage vignette_poor /// 
	  vignette_good native_lang income 

***************************** Labeling variables ***************************** 
 
lab var age_calc "Exact respondent age or middle number of age range (Q1 & Q2)"
lab var age_cat "Age (categorical) (Q1 &Q2)"
lab var gender "Gender (Q3)" 
lab var urban "Type of region respondent lives in (Q4)"
lab var insured "Insurance status (Q6)"
lab var insur_type "Type of insurance (for those who have insurance) (Q7)" 
lab var education "Highest level of education completed (Q8)"
lab var	health "Self-rated health (Q9)"
lab var	health_mental "Self-rated mental health (Q10)"
lab var	health_chronic "Longstanding illness or health problem (chronic illness) (Q11)"
lab var	ever_covid "Ever had COVID-19 or coronavirus (Q12)"
lab var	covid_confirmed	"COVID-19 or coronavirus confirmed by a COVID-19 test (Q13)"
lab var	covid_vax "COVID-19 vaccination status (Q14)"
lab var	covid_vax_intent "Intent to receive all COVID vaccine doses if available (Q15)"
lab var	patient_activation "Patient activation: manage overall health and tell a provider concerns (Q16/Q17)"
lab var	usual_source "Usual source of care (Q18)"
lab var	usual_type_own "Facility ownership for usual source of care (Q19)"
lab var	usual_type_lvl "Facility level for usual source of care (Q20)"
lab var	usual_type_own_lvl "Facility ownership and level for usual source of care (Q19 & Q20)"
lab var	usual_reason "Main reason for choosing usual source of care facility (Q21)"
lab var	usual_quality "Overall quality rating of usual source of care (Q22)"
lab var	visits "Visits made in-person to a facility in past 12 months (Q23 & Q24)"
lab var	visits_covid "Number of visits made for COVID in past 12 months (Q25A/Q25B)"
lab var	fac_number "Number of facilities visited during the past 12 months (Q26/Q27)"
lab var	visits_total "Total number of healthcare contacts: facility, home, and tele (Q23/Q28A/Q28B)"
lab var	inpatient "Stayed overnight as a facility in past 12 months (inpatient care) (Q29)"
lab var	blood_pressure "Blood pressure checked by healthcare provider in past 12 months (Q30)"
lab var	mammogram "Mammogram done by healtchare provider in past 12 months (Q31)"
lab var	cervical_cancer "Cervical cancer screening done by healthcare provider in past 12 months (Q32)"
lab var	eyes_exam "Eyes checked by healthcare provider in past 12 months (Q33)"
lab var	teeth_exam "Teeth checked by healthcare provider in past 12 months (Q34)"
lab var	blood_sugar "Blood sugar tested by healthcare provider in past 12 months (Q35)"
lab var	blood_chol "Blood cholesterol tested by healthcare provider in past 12 months (Q36)"		
*lab var	hiv_test "HIV test done by healthcare provider in past 12 months"
lab var	care_mental	"Received care for depression, anxiety or another mental health condition (Q38)"
lab var	system_fail	"Failed by the health system: mistake made or discriminated against (Q39/Q40)"	
lab var	unmet_need "Needed medical attention but did not get healthcare (Q41)"
lab var	unmet_reason "Reason for not getting healthcare when needed medical attention (Q42)"
lab var	last_type_own "Facility ownership for last visit to a healthcare provider (Q43)"
lab var	last_type_lvl "Facility level for last visit to a healthcare provider (Q44)"
lab var last_type_own_lvl "Facility ownership and level for last visit to a healthcare provider (Q43/Q44)"
lab var	last_reason	"Reason for last healthcare visit (Q45)" 
lab var	last_wait_time "Length of time waited for last visit to a healthcare provider (Q46)"
lab var	last_visit_time "Length of time spent with the provider during last healthcare visit (Q47)"
lab var	last_qual "Last visit rating: overall quality (Q48A)"
lab var	last_skills "Last visit rating: knowledge and skills of provider (Care competence) (Q48B)"
lab var	last_supplies "Last visit rating: equipment and supplies provider had available (Q48C)"
lab var	last_respect "Last visit rating: provider respect (Q48D)"
lab var	last_know "Last visit rating: knowledge of prior tests and visits (Q48E)"
lab var	last_explain "Last visit rating: explained things in an understradable way (Q48F)"
lab var	last_decisions "Last visit rating: involved you in decisions about your care (Q48G)"
lab var	last_visit_rate "Last visit rating: amount of time provider spent with you (Q48H)"
lab var	last_wait_rate "Last visit rating: amount of time you waited before being seen (Q48I)"
lab var	last_courtesy "Last visit rating: courtesy and helpfulness of the staff (Q48J)"
*lab var	last_comp_index "System competence composite index (average of X items)"
*lab var	last_user_index "User experience composite index (average of X items)"
lab var	last_promote "Net promoter score for facility visited for last visit (Q49)"
lab var	phc_women "Public primary care system rating for: pregnant women (Q50A)"
lab var	phc_child "Public primary care system rating for: children (Q50B)"
lab var	phc_chronic "Public primary care system rating for: chronic conditions (Q50C)"
lab var	phc_mental "Public primary care system rating for: mental health (Q50D)"
*lab var	phc_index "Public primary care system composite index"
lab var	conf_sick "Confidence in receiving good quality healthcare if became very sick (Q51)"
lab var	conf_afford	"Confidence in ability to afford care healthcare if became very sick (Q52)"
lab var	conf_opinion "Confidence that the gov considers public's opinion when making decisions (Q53)"
lab var	qual_public	"Overall quality rating of gov or public healthcare system in country (Q54)"
lab var	qual_private "Overall quality rating of private healthcare system in country (Q55)"
lab var qual_ss_pe "Peru: Overall quality rating of social security system in country (Q56)"
lab var qual_mut_uy "Uruguay: Overall quality rating of mutual healthcare system in country (Q56)"
lab var qual_ngo_ke "Kenya: Overall quality rating of NGO healthcare system in country (Q56)"  
lab var	system_outlook "Health system opinion: getting better, staying the same, or getting worse (Q57)"
lab var	system_reform "Health system opinion: minor, major changes, or must be completely rebuilt (Q58)" 
lab var	covid_manage "Respondent's rating the government's management of the COVID-19 pandemic (Q59)" 
lab var	vignette_poor "Rating of vignette in Q60 (poor care)"
lab var	vignette_good "Rating of vignette in Q61 (good care)"
lab var	native_lang "Native language (Q62)"
lab var	income "Income group (Q63)"

**************************** Save data *****************************

save "$data_mc/02 recoded data/pvs_ke_et_lac_02.dta", replace



