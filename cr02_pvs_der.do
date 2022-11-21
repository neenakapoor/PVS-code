* PVS deriving variables for aanalysis 
* September 2022
* N. Kapoor 

/*

This file loads creates derived variables for analysis from the multi-country 
dataset created in the cr01 file. 

*/

***************************** Deriving variables *****************************

u "$data_mc/02 recoded data/pvs_ke_et_lac_01.dta", clear

*age_calc: exact respondent age or middle of age range 
gen age_calc = Q1 
recode age_calc (.r = 23.5) if Q2 == 0
recode age_calc (.r = 34.5) if Q2 == 1
recode age_calc (.r = 44.5) if Q2 == 2
recode age_calc (.r = 54.5) if Q2 == 3
recode age_calc (.r = 64.5) if Q2 == 4
recode age_calc (.r = 74.5) if Q2 == 5
recode age_calc (.r = 80) if Q2 == 6
lab def ref .r "Refused"
lab val age_calc ref

*age_cat: categorical age 
gen age_cat = Q2
recode age_cat (.a = 0) if Q1 >= 18 & Q1 <= 29
recode age_cat (.a = 1) if Q1 >= 30 & Q1 <= 39
recode age_cat (.a = 2) if Q1 >= 40 & Q1 <= 49
recode age_cat (.a = 3) if Q1 >= 50 & Q1 <= 59
recode age_cat (.a = 4) if Q1 >= 60 & Q1 <= 69
recode age_cat (.a = 5) if Q1 >= 70 & Q1 <= 79
recode age_cat (.a = 6) if Q1 >= 80
lab val age_cat age_cat

*female: gender 	   
gen gender = Q3
lab val gender gender

*NOTE: Confirm if Q3 or Q3a is correct for LAC
*Responde R: Q3 seems to be the same as Q3a with different format, so Q3 works well for merging and doesnt lose any info from Q3a. I imagine they created Q3 from Q3a or something like that. I imagine that in Spanish they filled "man" or "woman" rather than gender.
* NOTE: I renamed this from female to gender because 'another gender' 
*Let me know if you disagree. 
*Agree, particularly with labels.   

*covid_vax
recode Q14 ///
	(0 = 0 "Unvaccinated (0 doses)") (1 = 1 "Partial vaccination (1 dose)") /// 
	(2 3 4 = 2 "Fully vaccinated (2+ doses)") (.r = .r Refused) (.a = .a NA), ///
	gen(covid_vax)
	
*covid_vax_intent 
gen covid_vax_intent = Q15 
lab val covid_vax_intent yes_no_doses

*patient_activiation
*NOTE: See if this code makes sense 
*R: makes sense to me
gen patient_activation = 2 if Q16 == 3 & Q17 == 3	
recode patient_activation (. = 1) if Q16 == 3 & Q17 == 2 | Q16 == 2 & Q17 == 3 | /// 
						  Q16 == 2 & Q17 == 2	
recode patient_activation (. = .r) if Q16 == .r | Q17 == .r
recode patient_activation (. = 0) if Q16 == 0 | Q16 == 1 | Q17 == 0 | Q17 == 1
lab def pa 0 "Not activated (Not too confident and Not at all confident for either category)" ///
			1 "Somewhat activated (Very or somewhat confident on Q16 and Q17)" /// 
			2 "Activated (Very confident on Q16 and Q17)" .r "Refused", replace
lab val patient_activation pa

* usual_reason
recode Q21 (2 = 1 "Convenience (short distance)") /// 
			(1 8 = 2 "Cost (low cost, covered by insurance)") ///
			(4 = 3 "Techincal quality (provider skills)") ///
			(3 5 = 4 "Interpersonal quality (short waiting time, respect)") ///
			(6 = 5 "Service readiness (medicines and equipment available)") ///
			(7 = 6 "Only facility available") ///
			(.r 9 = .r "Other or Refused") ///
			(.a = .a "NA") , gen(usual_reason)

* visits
gen visits = 0 if Q23 == 0 | Q24 == 0
recode visits (. = 1) if Q23 >=1 & Q23 <= 4 | Q24 == 1
recode visits (. = 2) if Q23 > 4 & Q23 < . | Q24 == 2 | Q24 == 3
recode visits (. = .r) if Q23 == .r | Q24 == .r
lab def visits 0 "Non-user (0 visits)" 1 "Occasional usuer (1-4 visits)" ///
			   2 "Frequent user (more than 4)"
lab val visits visits	

* visits_covid
gen visits_covid = Q25_B
recode visits_covid (.a = 1) if Q25_A == 1

*fac_number
* NOTE: what to do with people who say 0 or 1 for Q27? It's 24 people - for now put them in 0 group
gen fac_number = 0 if Q26 == 1 | Q27 == 0 | Q27 == 1
recode fac_number (. = 1) if Q27 == 2 | Q27 == 3
recode fac_number (. = 2) if Q23 > 3
recode fac_number (. = .a) if Q26 == .a | Q27 == .a
recode fac_number (. = .r) if Q26 == .r | Q27 == .r
lab def fn 0 "1 facility (Q26 is yes)" 1 "2-3 facilities (Q27 is 2 or 3)" ///
		   2 "More than 3 facilities (Q27 is 4 or more)" .a "NA" .r "Refused"
lab val fac_number fn

* visits_total
gen visits_total = Q23 + Q28_A + Q28_B
* NOTE: 
* something strange may be happening with Q28_A refuse 
* ^ future NRK does not remember why past NRK wrote that
recode visits_total (. = .r) if Q23 == .d | Q23 == .r | Q28_A == .d | Q28_A == .r ///
								| Q28_B == .d | Q28_B == .r 
* ^just changing them all to refuse for now

* systems_fail 
* NOTE: see if systems_fail code makes sense
gen system_fail = 1 if Q39 == 1 | Q40 == 1	   
recode system_fail (. = 0) if Q39 == 0 & Q40 == 0	
recode system_fail (. = .r) if Q39 == .r | Q40 == .r	      
recode system_fail (. = .a) (0 = .a) (1 = .a) if Q39 == .a | Q40 == .a	   
lab val system_fail yes_no_na

* unmet_reason 
recode Q42 (1 = 1 "Cost (High cost)") ///
			(2 = 2 "Convenience (Far distance)") ///
			(3 5 = 3 "Interpersonal quality (Long waiting time, Respect)") ///
			(4 = 4 "Technical quality (Poor provider skills)") ///
			(6 = 5 "Service readiness (Medicines and equipment not available)") ///
			(8 9 = 6 "COVID (COVID restritions or COVID fear)") ///
			(10 = 7 "Other") ///
			(.a 7 = .a "NA or Illness not serious") ///
			(.r = .r "Refused"), gen(unmet_reason)

		

* last_reason
gen last_reason = Q45
lab def lr 1 "Urgent or new problem" 2 "Follow-up for chronic disease" ///
		   3 "Preventative or health check" 995 "Other" .a "NA" .r "Refused"
lab val last_reason lr

*last_wait_time
gen last_wait_time = 0 if Q46_min <= 15
recode last_wait_time (. = 1) if Q46_min >= 15 & Q46_min < 60
recode last_wait_time (. = 2) if Q46_min >= 60 & Q46_min < .
recode last_wait_time (. = .a) if Q46_min == .a
recode last_wait_time (. = .r) if Q46_min == .r
lab def lwt 0 "Short (15 minutes)" 1 "Moderate (< 1 hour)" 2 "Long (> 1 hour)" ///
			.r "Refused" .a "NA"
lab val last_wait_time lwt

*last_visit_time
gen last_visit_time = 0 if Q47_min <= 15
recode last_visit_time (. = 1) if Q47_min > 15 & Q47_min < .
recode last_visit_time (. = .a) if Q47_min == .a
recode last_visit_time (. = .r) if Q47_min == .r
lab def lvt 0 "<= 15 minutes" 1 "> 15 minutes " ///
			.r "Refused" .a "NA"
lab val last_visit_time lvt

* last_promote
gen last_promote = 0 if Q49 < 8
recode last_promote (. = 1) if Q49 == 8 | Q49 == 9 | Q49 == 10
recode last_promote (. = .a) if Q49 == .a
recode last_promote (. = .r) if Q49 == .r
lab def lp 0 "Detractor" 1 "Promoter" .r "Refused" .a "NA"
lab val last_promote lp

* system_outlook 
gen system_outlook = Q57
lab val system_outlook system_outlook

* system_reform 
gen system_reform = Q58
lab def sr 1 "Health system needs to be rebuilt" 2 "Health system needs major changes" /// 
		3 "Health system only needs minor chanes" .r "Refused", replace
lab val system_reform sr

**** Yes/No Questions ****

* insured, health_chronic, ever_covid, covid_confirmed, usual_source inpatient
* unmet_need 
* Yes/No/Refused -Q6 Q11 Q12 Q13 Q18 Q29 Q41 
gen insured = Q6 
gen health_chronic = Q11
gen ever_covid = Q12
gen covid_confirmed = Q13 
gen usual_source = Q18
gen inpatient = Q29 
gen unmet_need = Q41 
lab val insured health_chronic ever_covid covid_confirmed usual_source ///
		inpatient unmet_need yes_no

* blood_pressure mammogram cervical_cancer eyes_exam teeth_exam blood_sugar  
* blood_chol care_mental 
* Yes/No/Don't Know/Refused - Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q66 
gen blood_pressure = Q30 
gen mammogram = Q31
gen cervical_cancer = Q32
gen eyes_exam = Q33
gen teeth_exam = Q34
gen blood_sugar = Q35 
gen blood_chol = Q36
gen care_mental = Q38 
lab val blood_pressure mammogram cervical_cancer eyes_exam teeth_exam /// 
	blood_sugar blood_chol care_mental yes_no_dk
	
**** Excellent to Poor scales *****	   

* health, health_mental, last_qual, last_skills, last_supplies, last_respect, 
* last_explain, last_decision, last_visit_rate, last_wait_rate, vignette_poor,
* vignette_good

recode Q9 Q10 Q48_A Q48_B Q48_C Q48_D Q48_F Q48_G Q48_H Q48_I Q60 Q61 /// 
	   (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") /// 
	   (.r = .r "Refused") (.a = .a NA), pre(der)label(exc_poor_der2)
	   	   
ren (derQ9 derQ10 derQ48_A derQ48_B derQ48_C derQ48_D derQ48_F derQ48_G derQ48_H /// 
	 derQ48_I derQ60 derQ61) (health health_mental last_qual last_skills /// 
	 last_supplies last_respect last_explain last_decisions ///
	 last_visit_rate last_wait_rate vignette_poor vignette_good)

* usual_quality,last_know, last_courtesy 

recode Q22 (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.a = .a "I did not receive healthcare form this provider in the past 12 months"), /// 
	   pre(der)label(exc_pr_hlthcare_der)

recode Q48_E (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.a = .a "I have not had prior visits or tests"), /// 
	   pre(der)label(exc_pr_visits_der)

recode Q48_J (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.a = .a "The clinic had no other staff"), /// 
	   pre(der)label(exc_pr_staff_der)
	   
ren (derQ22 derQ48_E derQ48_J) (usual_quality last_know last_courtesy)

* qual_public qual_private qual_ngo covid_manage

recode Q54 Q55 Q56_KE_ET Q56_PE Q56_UY Q59 /// 
	   (0 1 = 0 "Fair/Poor") (2 = 1 "Good") ( 3 4 = 2 "Excellent/Very Good") /// 
	   (.r = .r "Refused") (.a = .a NA), pre(der) label(exc_poor_der3)

ren (derQ54 derQ55 derQ56_KE_ET derQ56_PE derQ56_UY derQ59) ///
    (qual_public qual_private qual_ngo_ke qual_ss_PE qual_mut_UY covid_manage)

* phc_women phc_child phc_chronic phc_mental

recode Q50_A Q50_B Q50_C Q50_D ///
	   (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.d = .d "The clinic had no other staff"), /// 
	   pre(der) label(exc_pr_judge_der)

ren (derQ50_A derQ50_B derQ50_C derQ50_D) ///
	(phc_women phc_child phc_chronic phc_mental)

**** All Very Confident to Not at all Confident scales ****

* conf_sick conf_afford conf_opinion

recode Q51 Q52 Q53 ///
	   (3 = 1 "Very confident") ///
	   (0 1 2 = 0 "Somewhat confident/Not too confident/Not at all confident") /// 
	   (.r = .r Refused) (.a = .a NA), /// 
	   pre(der) label(vc_nc_der)

ren (derQ51 derQ52 derQ53) (conf_sick conf_afford conf_opinion)

**** COUNTRY SPECIFIC ****

* urban: type of region respondent lives in 
recode Q4 (6 7 9 10 12 13 = 1 "Urban") (8 11 14 = 0 "Rural") ///
		  (.r = .r "Refused"), gen(urban)
*Ro question: what about options 1,2,3,4,15,16,17?

* insur_type 
* NOTE: I'm just putting Other as refused for now 
recode Q7 (1 3 15 16 17 18 10 11 12 19 20 22 = 0 public) (2 4 5 6 7 28 13 21 = 1 private) /// 
		  (995 = .r "Refused") (.a = .a NA), gen(insur_type)
*Ro question: theres other options not included? We will ask country teams, right? What about 14=dont have insurance?

* education 
recode Q8 (1 7 12 25 26 18 19 32 33 = 0 "None") /// 
		  (2 3 8 13 14 27 20 34 = 1 "Primary") (4 9 15 16 28 21 35 = 2 "Secondary") /// 
	      (5 6 10 11 17 29 30 31 22 23 24 36 37 38 = 3 "Post-secondary") ///
		  (.r = .r "Refused"), gen(education)
*Ro question: What about 39 to 44?
*Made some changes based on labels9, not for 39 to 44.
		   
* usual_type
recode Q20 (1 2 12 14 15 16 23 80 82 83 40 43 92 94 = 0 "Public primary") /// 
		   (3 4 5 13 81 84 41 42 44 93 = 1 "Public Secondary") ///
		   (6 7 11 17 18 20 85 87 88 45 46 47 48 96 97 98 100 101 102 = 2 "Private primary") /// 
		   (8 9 19 21 86 89 49 99 103 = 3 "Private secondary") ///
		   (90 104 51 105 995 = 4 "Other") ///
		   (.a = .a "NA") ( .r = .r "Refused"), gen(usual_type)
*Ro question: how did you know if 8 and 9 were private, for example? Are the missing ones going to be confirmed by countries?

		   
* last_type 
recode Q44 (1 2 12 14 15 16 23 80 82 83 40 43 92 94 = 0 "Public primary") /// 
		   (3 4 5 13 81 84 41 42 44 93 = 1 "Public Secondary") ///
		   (6 7 11 17 18 20 85 87 88 45 46 47 48 96 97 98 100 101 102 = 2 "Private primary") /// 
		   (8 9 19 21 86 89 49 99 103 = 3 "Private secondary") ///
		   (90 104 51 50 91 105 995 = 4 "Other") ///
		   (.a = .a "NA") (.r = .r "Refused"), gen(last_type)

* income
recode Q63 (1 2 9 10 39 40 48 31 32 38 49 50 61 = 0 "Lowest income") /// 
		   (3 4 5 11 12 41 42 43 33 34 35 51 52 53 = 1 "Middle income") /// 
		   (6 7 13 14 44 45 36 37 54 55 = 2 "Highest income") ///
		   (.r = .r "Refused") (.d = .d "Don't know"), gen(income)
*Ro question: are the missing options because we don't have those countries' data? Is options one and two: low, threto five middle, and 6 and 7th options highest in all cases?

* NOTE: Ignored country-specific questions Q13B and Q13E
		   
**** Order Variables ****
		   
order Respondent_Serial Respondent_ID Unique_ID PSU_ID InterviewerID_recoded /// 
	  Interviewer_Language Interviewer_Gender mode Country Language Date ///
	  Time IntLength int_length Q1_codes Q1 Q2 Q3 Q3a Q4 Q5 Q6 Q7 ///
	  Q7_other  Q8 Q9 Q10 Q11 Q12 Q13 Q13B Q13E Q13E_10 Q14 Q15 Q16 Q17 Q18 ///
	  Q19_KE_ET Q19_CO Q19_PE Q19_UY Q19_other Q20 Q20_other Q21 Q21_other Q22 ///
	  Q23 Q24 Q25_A Q25_B Q26 Q27 Q28_A Q28_B Q29 Q30 Q31 Q32 Q33 Q34 Q35 Q36 ///
	  Q38 Q39 Q40 Q41 Q42 Q42_other Q43_KE_ET Q43_CO Q43_PE Q43_UY Q43_other Q44 ///
	  Q44_other Q45 Q45_other Q46 Q46_min Q46_refused Q47 Q47_min Q47_refused ///
	  Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F Q48_G Q48_H Q48_I Q48_J Q49 Q50_A ///
	  Q50_B Q50_C Q50_D Q51 Q52 Q53 Q54 Q55 Q56_KE_ET Q56_PE Q56_UY Q57 Q58 Q59 ///
	  Q60 Q61 Q62 Q62_other Q63 Q64 Q65 QC_short _v1 age_calc age_cat gender ///
	  urban insured insur_type education health health_mental health_chronic ///
	  ever_covid covid_confirmed covid_vax covid_vax_intent patient_activation ///
	  usual_source usual_type usual_reason usual_quality visits visits_covid ///
	  fac_number visits_total inpatient blood_pressure mammogram ///
	  cervical_cancer eyes_exam teeth_exam blood_sugar blood_chol care_mental /// 
	  system_fail unmet_need unmet_reason last_type last_reason last_wait_time ///
	  last_visit_time last_qual last_skills last_supplies last_respect last_know ///
	  last_explain last_decisions last_visit_rate last_wait_rate last_courtesy ///
	  last_promote phc_women phc_child phc_chronic phc_mental conf_sick ///
	  conf_afford conf_opinion qual_public qual_private qual_ngo_ke qual_ss_PE ///
	  qual_mut_UY system_outlook system_reform covid_manage vignette_poor /// 
	  vignette_good income

***************************** Labeling variables ***************************** 
 
lab var age_calc "Exact respondent age or middle number of age range"
lab var age_cat "Categorical age"
lab var gender "Gender" 
lab var urban "Type of region respondent lives in"
lab var insured "Insurance status "
lab var insur_type "Type of insurance (for those who have insurance)" 
lab var education "Highest level of education completed "
lab var	health "Self-rated health"
lab var	health_mental "Self-rated mental health"
lab var	health_chronic "Longstanding illness or health problem (chronic illness)"
lab var	ever_covid "Ever had COVID-19 or coronavirus"
lab var	covid_confirmed	"COVID-19 or coronavirus confirmed by a COVID-19 test"
lab var	covid_vax "COVID-19 vaccination status"
lab var	covid_vax_intent "Intent to receive all recommended COVID-19 vaccine doses if available (if received < 2 doses)"
lab var	patient_activation "Patient activation - can manage overall health and tell a provider concerns even when they do not ask"
lab var	usual_source "Usual source of care"
lab var	usual_type "Facility type for usual source of care"
lab var	usual_reason "Main reason for choosing usual source of care facility"
lab var	usual_quality "Overall quality rating of usual source of care"
lab var	visits "Visits made in-person to a facility in past 12 months"
lab var	visits_covid "Number of reported visits made for COVID in-person to a facility in past 12 months"
lab var	fac_number "Number of facilities visited if had more than one visit during the past 12 months"
lab var	visits_total "Total number of healthcare contacts, including those made to a facility, home visits and telemedicine visits"
lab var	inpatient "Stayed overnight as a facility in past 12 months (inpatient care)"
lab var	blood_pressure "Blood pressure checked by healthcare provider in past 12 months"
lab var	mammogram "Mammogram done by healtchare provider in past 12 months"
lab var	cervical_cancer "Cervical cancer screening done by healthcare provider in past 12 months"
lab var	eyes_exam "Eyes checked by healthcare provider in past 12 months"
lab var	teeth_exam "Teeth checked by healthcare provider in past 12 months"
lab var	blood_sugar "Blood sugar tested by healthcare provider in past 12 months"
lab var	blood_chol "Blood cholesterol tested by healthcare provider in past 12 months"		
*lab var	hiv_test "HIV test done by healthcare provider in past 12 months"
lab var	care_mental	"Received care for depression, anxiety or another mental health condition"
lab var	system_fail	"Failed by the health system- medical mistake made or discriminated against by provider"	
lab var	unmet_need "Needed medical attention but did not get healthcare"
lab var	unmet_reason "Reason for not getting healthcare when needed medical attention"
lab var	last_type "Facility type for last visit to a healthcare provider"
lab var	last_reason	"Reason for last healthcare visit" 
lab var	last_wait_time "Length of time waited for last visit to a healthcare provider"
lab var	last_visit_time "Length of time spent with the provider during last healthcare visit"
lab var	last_qual "Last visit rating: overall quality"
lab var	last_skills "Last visit rating: knowledge and skills of provider (Care competence)"
lab var	last_supplies "Last visit rating: equipment and supplies provider had available"
lab var	last_respect "Last visit rating: provider respect"
lab var	last_know "Last visit rating: knowledge of prior tests and visits"
lab var	last_explain "Last visit rating: explained things in an understrandable way"
lab var	last_decisions "Last visit rating: involved you in decisions about your care"
lab var	last_visit_rate "Last visit rating: amount of time provider spent with you"
lab var	last_wait_rate "Last visit rating: amount of time you waited before being seen"
lab var	last_courtesy "Last visit rating: courtesy and helpfulness of the staff"
*lab var	last_comp_index "System competence composite index (average of X items)"
*lab var	last_user_index "User experience composite index (average of X items)"
lab var	last_promote "Net promoter score for facility visited for last visit to a healthcare provider"
lab var	phc_women "Public primary care system rating for: pregnant women"
lab var	phc_child "Public primary care system rating for: children"
lab var	phc_chronic "Public primary care system rating for: chronic conditions"
lab var	phc_mental "Public primary care system rating for: mental health"
*lab var	phc_index "Public primary care system composite index"
lab var	conf_sick "Confidence in receiving good quality healthcare if became very sick"
lab var	conf_afford	"Confidence in ability to afford care healthcare if became very sick"
lab var	conf_opinion "Confidence that the government considers public's opinion when making decisions about the healthcare system"
lab var	qual_public	"Overall quality ratiing of government or public healthcare system in country"
lab var	qual_private "Overall quality rating of private healthcare system in country"
lab var qual_ss_PE "Peru: Overall quality rating of social security system in country "
lab var qual_mut_UY "Uruguay: Overall quality rating of mutual healthcare system in country "
lab var qual_ngo_ke "Kenya: Overall quality rating of NGO/faith-based healthcare system in country"  
lab var	system_outlook "Opinion on whether heatlh system is getting better, staying the same, or getting worse"
lab var	system_reform "Opinion on whether health system needs major changes, major changes, or must be completely rebuilt" 
lab var	covid_manage "Respondent's rating the government's management of the COVID-19 pandemic" 
lab var	vignette_poor "Rating of vignette in Q60 (poor care)"
lab var	vignette_good "Rating of vignette in Q61 (good care)"
*lab var	language "Native language"
lab var	income "Income group"

**************************** Save data *****************************


save "$data_mc/02 recoded data/pvs_ke_et_lac_02.dta", replace


* TEMP - doing Kenya separately for now 
***************************** Deriving variables *****************************
u "$data_mc/02 recoded data/pvs_ke_02.dta", clear

* age_calc: exact respondent age or middle of age range 
gen age_calc = Q1 
recode age_calc (.r = 23.5) if Q2 == 0
recode age_calc (.r = 34.5) if Q2 == 1
recode age_calc (.r = 44.5) if Q2 == 2
recode age_calc (.r = 54.5) if Q2 == 3
recode age_calc (.r = 64.5) if Q2 == 4
recode age_calc (.r = 74.5) if Q2 == 5
recode age_calc (.r = 80) if Q2 == 6
lab def ref .r "Refused"
lab val age_calc ref

* age_cat: categorical age 
gen age_cat = Q2
recode age_cat (.a = 0) if Q1 >= 18 & Q1 <= 29
recode age_cat (.a = 1) if Q1 >= 30 & Q1 <= 39
recode age_cat (.a = 2) if Q1 >= 40 & Q1 <= 49
recode age_cat (.a = 3) if Q1 >= 50 & Q1 <= 59
recode age_cat (.a = 4) if Q1 >= 60 & Q1 <= 69
recode age_cat (.a = 5) if Q1 >= 70 & Q1 <= 79
recode age_cat (.a = 6) if Q1 >= 80
lab val age_cat age_cat

* female: gender 	   
gen gender = Q3
lab val gender gender

* NOTE: Confirm if Q3 or Q3a is correct for LAC 
* NOTE: I renamed this from female to gender because 'another gender' 
* 		Let me know if you disagree  

* covid_vax
recode Q14 ///
	(0 = 0 "Unvaccinated (0 doses)") (1 = 1 "Partial vaccination (1 dose)") /// 
	(2 3 4 = 2 "Fully vaccinated (2+ doses)") (.r = .r Refused) (.a = .a NA), ///
	gen(covid_vax)
	
* covid_vax_intent 
gen covid_vax_intent = Q15 
lab val covid_vax_intent yes_no_doses

* patient_activiation
* NOTE: See if this code makes sense 
gen patient_activation = 2 if Q16 == 3 & Q17 == 3	
recode patient_activation (. = 1) if Q16 == 3 & Q17 == 2 | Q16 == 2 & Q17 == 3 | /// 
						  Q16 == 2 & Q17 == 2	
recode patient_activation (. = .r) if Q16 == .r | Q17 == .r
recode patient_activation (. = 0) if Q16 == 0 | Q16 == 1 | Q17 == 0 | Q17 == 1
lab def pa 0 "Not activated (Not too confident and Not at all confident for either category)" ///
			1 "Somewhat activated (Very or somewhat confident on Q16 and Q17)" /// 
			2 "Activated (Very confident on Q16 and Q17)" .r "Refused", replace
lab val patient_activation pa

* usual_reason
recode Q21 (2 = 1 "Convenience (short distance)") /// 
			(1 8 = 2 "Cost (low cost, covered by insurance)") ///
			(4 = 3 "Techincal quality (provider skills)") ///
			(3 5 = 4 "Interpersonal quality (short waiting time, respect)") ///
			(6 = 5 "Service readiness (medicines and equipment available)") ///
			(7 = 6 "Only facility available") ///
			(.r 9 = .r "Other or Refused") ///
			(.a = .a "NA") , gen(usual_reason)

* visits
gen visits = 0 if Q23 == 0 | Q24 == 0
recode visits (. = 1) if Q23 >=1 & Q23 <= 4 | Q24 == 1
recode visits (. = 2) if Q23 > 4 & Q23 < . | Q24 == 2 | Q24 == 3
recode visits (. = .r) if Q23 == .r | Q24 == .r
lab def visits 0 "Non-user (0 visits)" 1 "Occasional usuer (1-4 visits)" ///
			   2 "Frequent user (more than 4)"
lab val visits visits	

* visits_covid
gen visits_covid = Q25_B
recode visits_covid (.a = 1) if Q25_A == 1

*fac_number
* NOTE: what to do with people who say 0 or 1 for Q27? It's 24 people - for now put them in 0 group
gen fac_number = 0 if Q26 == 1 | Q27 == 0 | Q27 == 1
recode fac_number (. = 1) if Q27 == 2 | Q27 == 3
recode fac_number (. = 2) if Q23 > 3
recode fac_number (. = .a) if Q26 == .a | Q27 == .a
recode fac_number (. = .r) if Q26 == .r | Q27 == .r
lab def fn 0 "1 facility (Q26 is yes)" 1 "2-3 facilities (Q27 is 2 or 3)" ///
		   2 "More than 3 facilities (Q27 is 4 or more)" .a "NA" .r "Refused"
lab val fac_number fn

* visits_total
gen visits_total = Q23 + Q28_A + Q28_B
* NOTE: 
* something strange may be happening with Q28_A refuse 
* ^ future NRK does not remember why past NRK wrote that
recode visits_total (. = .r) if Q23 == .d | Q23 == .r | Q28_A == .d | Q28_A == .r ///
								| Q28_B == .d | Q28_B == .r 
* ^just changing them all to refuse for now

* systems_fail 
* NOTE: see if systems_fail code makes sense
gen system_fail = 1 if Q39 == 1 | Q40 == 1	   
recode system_fail (. = 0) if Q39 == 0 & Q40 == 0	
recode system_fail (. = .r) if Q39 == .r | Q40 == .r	      
recode system_fail (. = .a) (0 = .a) (1 = .a) if Q39 == .a | Q40 == .a	   
lab val system_fail yes_no_na

* unmet_reason 
recode Q42 (1 = 1 "Cost (High cost)") ///
			(2 = 2 "Convenience (Far distance)") ///
			(3 5 = 3 "Interpersonal quality (Long waiting time, Respect)") ///
			(4 = 4 "Technical quality (Poor provider skills)") ///
			(6 = 5 "Service readiness (Medicines and equipment not available)") ///
			(8 9 = 6 "COVID (COVID restritions or COVID fear)") ///
			(10 = 7 "Other") ///
			(.a 7 = .a "NA or Illness not serious") ///
			(.r = .r "Refused"), gen(unmet_reason)

		

* last_reason
gen last_reason = Q45
lab def lr 1 "Urgent or new problem" 2 "Follow-up for chronic disease" ///
		   3 "Preventative or health check" 995 "Other" .a "NA" .r "Refused"
lab val last_reason lr

*last_wait_time
gen last_wait_time = 0 if Q46_min <= 15
recode last_wait_time (. = 1) if Q46_min >= 15 & Q46_min < 60
recode last_wait_time (. = 2) if Q46_min >= 60 & Q46_min < .
recode last_wait_time (. = .a) if Q46_min == .a
recode last_wait_time (. = .r) if Q46_min == .r
lab def lwt 0 "Short (15 minutes)" 1 "Moderate (< 1 hour)" 2 "Long (> 1 hour)" ///
			.r "Refused" .a "NA"
lab val last_wait_time lwt

*last_visit_time
gen last_visit_time = 0 if Q47_min <= 15
recode last_visit_time (. = 1) if Q47_min > 15 & Q47_min < .
recode last_visit_time (. = .a) if Q47_min == .a
recode last_visit_time (. = .r) if Q47_min == .r
lab def lvt 0 "<= 15 minutes" 1 "> 15 minutes " ///
			.r "Refused" .a "NA"
lab val last_visit_time lvt

* last_promote
gen last_promote = 0 if Q49 < 8
recode last_promote (. = 1) if Q49 == 8 | Q49 == 9 | Q49 == 10
recode last_promote (. = .a) if Q49 == .a
recode last_promote (. = .r) if Q49 == .r
lab def lp 0 "Detractor" 1 "Promoter" .r "Refused" .a "NA"
lab val last_promote lp

* system_outlook 
gen system_outlook = Q57
lab val system_outlook system_outlook

* system_reform 
gen system_reform = Q58
lab def sr 1 "Health system needs to be rebuilt" 2 "Health system needs major changes" /// 
		3 "Health system only needs minor chanes" .r "Refused", replace
lab val system_reform sr

**** Yes/No Questions ****

* insured, health_chronic, ever_covid, covid_confirmed, usual_source inpatient
* unmet_need 
* Yes/No/Refused -Q6 Q11 Q12 Q13 Q18 Q29 Q41 
gen insured = Q6 
gen health_chronic = Q11
gen ever_covid = Q12
gen covid_confirmed = Q13 
gen usual_source = Q18
gen inpatient = Q29 
gen unmet_need = Q41 
lab val insured health_chronic ever_covid covid_confirmed usual_source ///
		inpatient unmet_need yes_no

* blood_pressure mammogram cervical_cancer eyes_exam teeth_exam blood_sugar  
* blood_chol care_mental 
* Yes/No/Don't Know/Refused - Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q66 
gen blood_pressure = Q30 
gen mammogram = Q31
gen cervical_cancer = Q32
gen eyes_exam = Q33
gen teeth_exam = Q34
gen blood_sugar = Q35 
gen blood_chol = Q36
gen care_mental = Q38 
lab val blood_pressure mammogram cervical_cancer eyes_exam teeth_exam /// 
	blood_sugar blood_chol care_mental yes_no_dk
	
**** Excellent to Poor scales *****	   

* health, health_mental, last_qual, last_skills, last_supplies, last_respect, 
* last_explain, last_decision, last_visit_rate, last_wait_rate, vignette_poor,
* vignette_good

recode Q9 Q10 Q48_A Q48_B Q48_C Q48_D Q48_F Q48_G Q48_H Q48_I Q60 Q61 /// 
	   (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") /// 
	   (.r = .r "Refused") (.a = .a NA), pre(der)label(exc_poor_der2)
	   	   
ren (derQ9 derQ10 derQ48_A derQ48_B derQ48_C derQ48_D derQ48_F derQ48_G derQ48_H /// 
	 derQ48_I derQ60 derQ61) (health health_mental last_qual last_skills /// 
	 last_supplies last_respect last_explain last_decisions ///
	 last_visit_rate last_wait_rate vignette_poor vignette_good)

* usual_quality,last_know, last_courtesy 

recode Q22 (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.a = .a "I did not receive healthcare form this provider in the past 12 months"), /// 
	   pre(der)label(exc_pr_hlthcare_der)

recode Q48_E (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.a = .a "I have not had prior visits or tests"), /// 
	   pre(der)label(exc_pr_visits_der)

recode Q48_J (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.a = .a "The clinic had no other staff"), /// 
	   pre(der)label(exc_pr_staff_der)
	   
ren (derQ22 derQ48_E derQ48_J) (usual_quality last_know last_courtesy)

* qual_public qual_private qual_ngo covid_manage

recode Q54 Q55 Q56 Q59 /// 
	   (0 1 = 0 "Fair/Poor") (2 = 1 "Good") ( 3 4 = 2 "Excellent/Very Good") /// 
	   (.r = .r "Refused") (.a = .a NA), pre(der) label(exc_poor_der3)

ren (derQ54 derQ55 derQ56 derQ59) ///
    (qual_public qual_private qual_ngo covid_manage)

* phc_women phc_child phc_chronic phc_mental

recode Q50_A Q50_B Q50_C Q50_D ///
	   (0 1 = 0 "Fair/Poor") (2 3 4 = 1 "Excellent/Very Good/Good") (.r = .r "Refused") /// 
	   (.d = .d "The clinic had no other staff"), /// 
	   pre(der) label(exc_pr_judge_der)

ren (derQ50_A derQ50_B derQ50_C derQ50_D) ///
	(phc_women phc_child phc_chronic phc_mental)

**** All Very Confident to Not at all Confident scales ****

* conf_sick conf_afford conf_opinion

recode Q51 Q52 Q53 ///
	   (3 = 1 "Very confident") ///
	   (0 1 2 = 0 "Somewhat confident/Not too confident/Not at all confident") /// 
	   (.r = .r Refused) (.a = .a NA), /// 
	   pre(der) label(vc_nc_der)

ren (derQ51 derQ52 derQ53) (conf_sick conf_afford conf_opinion)

**** COUNTRY SPECIFIC ****

* urban: type of region respondent lives in 
recode Q4 (6 7 9 10 12 13 = 1 "Urban") (8 11 14 = 0 "Rural") ///
		  (.r = .r "Refused"), gen(urban)

* insur_type 
* NOTE: I'm just putting Other as refused for now 
recode Q7 (1 3 15 16 17 18 10 11 12 19 20 22 = 0 public) (2 4 5 6 7 28 13 21 = 1 private) /// 
		  (995 = .r "Refused") (.a = .a NA), gen(insur_type)

* education 
recode Q8 (1 7 25 26 18 19 32 33 = 0 "None") /// 
		  (2 3 8 27 20 34 = 1 "Primary") (4 9 10 28 21 35 = 2 "Secondary") /// 
	      (5 11 29 30 31 22 23 24 36 37 38 = 3 "Post-secondary") ///
		  (.r = .r "Refused"), gen(education)
		   
* usual_type
recode Q20 (1 2 12 14 15 16 23 80 82 83 40 43 92 94 = 0 "Public primary") /// 
		   (3 4 5 13 81 84 41 42 44 93 = 1 "Public Secondary") ///
		   (6 7 11 17 18 20 85 87 88 45 46 47 48 96 97 98 100 101 102 = 2 "Private primary") /// 
		   (8 9 19 21 86 89 49 99 103 = 3 "Private secondary") ///
		   (90 104 51 105 995 = 4 "Other") ///
		   (.a = .a "NA") ( .r = .r "Refused"), gen(usual_type)
		   
* last_type 
recode Q44 (1 2 12 14 15 16 23 80 82 83 40 43 92 94 = 0 "Public primary") /// 
		   (3 4 5 13 81 84 41 42 44 93 = 1 "Public Secondary") ///
		   (6 7 11 17 18 20 85 87 88 45 46 47 48 96 97 98 100 101 102 = 2 "Private primary") /// 
		   (8 9 19 21 86 89 49 99 103 = 3 "Private secondary") ///
		   (90 104 51 50 91 105 995 = 4 "Other") ///
		   (.a = .a "NA") (.r = .r "Refused"), gen(last_type)

* income
recode Q63 (1 2 9 10 39 40 48 31 32 38 49 50 61 = 0 "Lowest income") /// 
		   (3 4 5 11 12 41 42 43 33 34 35 51 52 53 = 1 "Middle income") /// 
		   (6 7 13 14 44 45 36 37 54 55 = 2 "Highest income") ///
		   (.r = .r "Refused") (.d = .d "Don't know"), gen(income)

* NOTE: Ignored country-specific questions Q13B and Q13E
		   
**** Order Variables ****
		   
order Respondent_Serial Respondent_ID PSU_ID InterviewerID_recoded /// 
	  Interviewer_Language Interviewer_Gender mode Country Language Date ///
	  Time IntLength int_length Q1_codes Q1 Q2 Q3 Q4 Q5 Q6 Q7 ///
	  Q7_other  Q8 Q9 Q10 Q11 Q12 Q13 Q14 Q15 Q16 Q17 Q18 ///
	  Q19 Q19_other Q20 Q20_other Q21 Q21_other Q22 ///
	  Q23 Q24 Q25_A Q25_B Q26 Q27 Q28_A Q28_B Q29 Q30 Q31 Q32 Q33 Q34 Q35 Q36 ///
	  Q38 Q39 Q40 Q41 Q42 Q42_other Q43 Q43_other Q44 ///
	  Q44_other Q45 Q45_other Q46 Q46_min Q46_refused Q47 Q47_min Q47_refused ///
	  Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F Q48_G Q48_H Q48_I Q48_J Q49 Q50_A ///
	  Q50_B Q50_C Q50_D Q51 Q52 Q53 Q54 Q55 Q56 Q57 Q58 Q59 ///
	  Q60 Q61 Q62 Q62_other Q63 Q64 Q65 QC_short age_calc age_cat gender ///
	  urban insured insur_type education health health_mental health_chronic ///
	  ever_covid covid_confirmed covid_vax covid_vax_intent patient_activation ///
	  usual_source usual_type usual_reason usual_quality visits visits_covid ///
	  fac_number visits_total inpatient blood_pressure mammogram ///
	  cervical_cancer eyes_exam teeth_exam blood_sugar blood_chol care_mental /// 
	  system_fail unmet_need unmet_reason last_type last_reason last_wait_time ///
	  last_visit_time last_qual last_skills last_supplies last_respect last_know ///
	  last_explain last_decisions last_visit_rate last_wait_rate last_courtesy ///
	  last_promote phc_women phc_child phc_chronic phc_mental conf_sick ///
	  conf_afford conf_opinion qual_public qual_private qual_ng ///
	  system_outlook system_reform covid_manage vignette_poor /// 
	  vignette_good income

***************************** Labeling variables ***************************** 
 
lab var age_calc "Exact respondent age or middle number of age range"
lab var age_cat "Categorical age"
lab var gender "Gender" 
lab var urban "Type of region respondent lives in"
lab var insured "Insurance status "
lab var insur_type "Type of insurance (for those who have insurance)" 
lab var education "Highest level of education completed "
lab var	health "Self-rated health"
lab var	health_mental "Self-rated mental health"
lab var	health_chronic "Longstanding illness or health problem (chronic illness)"
lab var	ever_covid "Ever had COVID-19 or coronavirus"
lab var	covid_confirmed	"COVID-19 or coronavirus confirmed by a COVID-19 test"
lab var	covid_vax "COVID-19 vaccination status"
lab var	covid_vax_intent "Intent to receive all recommended COVID-19 vaccine doses if available (if received < 2 doses)"
lab var	patient_activation "Patient activation - can manage overall health and tell a provider concerns even when they do not ask"
lab var	usual_source "Usual source of care"
lab var	usual_type "Facility type for usual source of care"
lab var	usual_reason "Main reason for choosing usual source of care facility"
lab var	usual_quality "Overall quality rating of usual source of care"
lab var	visits "Visits made in-person to a facility in past 12 months"
lab var	visits_covid "Number of reported visits made for COVID in-person to a facility in past 12 months"
lab var	fac_number "Number of facilities visited if had more than one visit during the past 12 months"
lab var	visits_total "Total number of healthcare contacts, including those made to a facility, home visits and telemedicine visits"
lab var	inpatient "Stayed overnight as a facility in past 12 months (inpatient care)"
lab var	blood_pressure "Blood pressure checked by healthcare provider in past 12 months"
lab var	mammogram "Mammogram done by healtchare provider in past 12 months"
lab var	cervical_cancer "Cervical cancer screening done by healthcare provider in past 12 months"
lab var	eyes_exam "Eyes checked by healthcare provider in past 12 months"
lab var	teeth_exam "Teeth checked by healthcare provider in past 12 months"
lab var	blood_sugar "Blood sugar tested by healthcare provider in past 12 months"
lab var	blood_chol "Blood cholesterol tested by healthcare provider in past 12 months"		
*lab var	hiv_test "HIV test done by healthcare provider in past 12 months"
lab var	care_mental	"Received care for depression, anxiety or another mental health condition"
lab var	system_fail	"Failed by the health system- medical mistake made or discriminated against by provider"	
lab var	unmet_need "Needed medical attention but did not get healthcare"
lab var	unmet_reason "Reason for not getting healthcare when needed medical attention"
lab var	last_type "Facility type for last visit to a healthcare provider"
lab var	last_reason	"Reason for last healthcare visit" 
lab var	last_wait_time "Length of time waited for last visit to a healthcare provider"
lab var	last_visit_time "Length of time spent with the provider during last healthcare visit"
lab var	last_qual "Last visit rating: overall quality"
lab var	last_skills "Last visit rating: knowledge and skills of provider (Care competence)"
lab var	last_supplies "Last visit rating: equipment and supplies provider had available"
lab var	last_respect "Last visit rating: provider respect"
lab var	last_know "Last visit rating: knowledge of prior tests and visits"
lab var	last_explain "Last visit rating: explained things in an understrandable way"
lab var	last_decisions "Last visit rating: involved you in decisions about your care"
lab var	last_visit_rate "Last visit rating: amount of time provider spent with you"
lab var	last_wait_rate "Last visit rating: amount of time you waited before being seen"
lab var	last_courtesy "Last visit rating: courtesy and helpfulness of the staff"
*lab var	last_comp_index "System competence composite index (average of X items)"
*lab var	last_user_index "User experience composite index (average of X items)"
lab var	last_promote "Net promoter score for facility visited for last visit to a healthcare provider"
lab var	phc_women "Public primary care system rating for: pregnant women"
lab var	phc_child "Public primary care system rating for: children"
lab var	phc_chronic "Public primary care system rating for: chronic conditions"
lab var	phc_mental "Public primary care system rating for: mental health"
*lab var	phc_index "Public primary care system composite index"
lab var	conf_sick "Confidence in receiving good quality healthcare if became very sick"
lab var	conf_afford	"Confidence in ability to afford care healthcare if became very sick"
lab var	conf_opinion "Confidence that the government considers public's opinion when making decisions about the healthcare system"
lab var	qual_public	"Overall quality ratiing of government or public healthcare system in country"
lab var	qual_private "Overall quality rating of private healthcare system in country"
lab var qual_ngo "Kenya: Overall quality rating of NGO/faith-based healthcare system in country"  
lab var	system_outlook "Opinion on whether heatlh system is getting better, staying the same, or getting worse"
lab var	system_reform "Opinion on whether health system needs major changes, major changes, or must be completely rebuilt" 
lab var	covid_manage "Respondent's rating the government's management of the COVID-19 pandemic" 
lab var	vignette_poor "Rating of vignette in Q60 (poor care)"
lab var	vignette_good "Rating of vignette in Q61 (good care)"
*lab var	language "Native language"
lab var	income "Income group"

save "$data_mc/02 recoded data/pvs_ke_03.dta", replace
