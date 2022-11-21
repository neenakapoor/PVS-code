* PVS cleaning for appending datasets
* September 2022
* N. Kapoor & R. B. Lobato

/*

This file loads country-specific raw data, cleans these data, and appends these
datasets to one clean multi-country datset. 

Cleaning includes:
	- Creating new variables (e.g., time variables) 
	- Recoding skip patterns, refused, and don't know 
	- Correcting any values and value labels and their direction 

Note: * .a means NA, .r means refused, .d is don't know, . is missing 

*/

clear all
set more off 

************************************* KENYA ************************************

* Import raw data 
* use "$data/Kenya/00 interim data/HARVARD_Main KE CATI and F2F_08.11.22.dta", clear
use "$data/Kenya/01 raw data/HARVARD_Main KE CATI and F2F_weighted_171122.dta", clear

*------------------------------------------------------------------------------*

* Fix interview length variable and other time variables 
* Edit this section to include other date and time variables as needed 

* Formatting time 
* format time_new Q46 Q47 %tcHH:MM:SS

* Converting interview length to minutes so it can be summarized

* gen int_length = (hh(IntLength)*3600 + mm(IntLength)*60 + ss(IntLength)) / 604
gen int_length = IntLength / 60

* Converting Q46 and Q47 to minutes so it can be summarized

* gen Q46_min = (hh(Q46)*3600 + mm(Q46)*60 + ss(Q46)) / 60

* gen Q47_min = (hh(Q47)*3600 + mm(Q47)*60 + ss(Q47)) / 60
gen Q46_min = Q46 / 60
gen Q47_min = Q47 / 60

*------------------------------------------------------------------------------*

* Drop any unwanted/empty variables
* Generate any new needed variables

* Make sure no under 18 
* NOTE: TODD is this okay to do? 
drop if Q2 == 1 | Q1 < 18

*------------------------------------------------------------------------------*

* Recode all Refused and Don't know

* NOTE:
* Todd: for future - curious about your thoughts on over-recoding. 
* I could not do these recodes below (67 & 71) and instead do it in the value label corrections. 
* Then, would need to change all the .r in the "NA" section to 996, but that's minor 
* After you review it all, would be great to discuss your thoughts on the order of this recoding 

* Don't know is 997 in these raw data 
recode Q23 Q25_A Q25_B Q27 Q28 Q28_NEW Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q63 ///
	   Q66 Q67 (997 = .d)

* Refused is 996 in these raw data 
recode Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12 Q13 Q14_NEW Q15_NEW Q16 Q17 /// 
	   Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25_A Q25_B Q26 Q27 Q28 Q28_NEW Q29 Q30 /// 
	   Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q39 Q40 Q41 Q42 Q43 Q44 Q45 Q46 Q47 ///
	   Q46_refused Q47_refused Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F Q48_G /// 
	   Q48_H Q48_I Q48_J Q49 Q50_A Q50_B Q50_C Q50_D Q51 Q52 Q53 Q54 Q55 /// 
	   Q56 Q57 Q58 Q59 Q60 Q61 Q62 Q63 Q66 Q67 (996 = .r)	
	
*------------------------------------------------------------------------------*

* Recode missing values to NA for questions respondents would not have been asked due to skip patterns

*Q1/Q2 
recode Q2 (. = .a) if Q1 != .r
recode Q1 Q1_codes (. = .r) if Q2 != .a

* Q7 
recode Q7 (. = .a) if Q6 == 2 | Q6 == .r 

* Q13 
recode Q13 (. = .a) if Q12 == 2 | Q12 == .r | Q12 == .d 

* Q15
recode Q15_NEW (. = .a) if Q14_NEW == 3 | Q14_NEW == 4 | Q14_NEW == 5 | Q14_NEW == .r


*Q19-22
recode Q19 Q20 Q21 Q22 (. = .a) if Q18 == 2 | Q18 == .r 
recode Q20 (. = .a) if Q19 == 4 | Q19 == .r

* NA's for Q23-27 
recode Q24 (. = .a) if Q23 != .d | Q23 != .r
recode Q25_A (. = .a) if Q23 != 1
recode Q25_B (. = .a) if Q23 == 0 | Q23 == 1 | Q24 == 1 | Q24 == .r 
recode Q26 (. = .a) if Q23 == 0 | Q23 == 1 | Q24 == 1 | Q24 == .r 
recode Q27 (. = .a) if Q26 != 2

* Q31 & Q32
recode Q31 (. = .a) if Q3 == 1 | Q1 < 50 | Q2 == 1 | Q2 == 2 | Q2 == 3 | Q2 == 4 | Q1 == .r | Q2 == .r 
recode Q32 (. = .a) if Q3 == 1 | Q1 == .r | Q2 == .r

* Q42
recode Q42 (. = .a) if Q41 == 2 | Q41 == .r


* Q43-49 NA's
recode Q43 Q44 Q45 Q46 Q46_min Q46_refused Q47 Q47_min Q47_refused Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F /// 
	   Q48_G Q48_H Q48_I Q48_J Q49 (. = .a) if Q23 == 0 | Q24 == 1 | Q24 == .r
	   
recode Q44 (. = .a) if Q43 == 4 | Q43 == .r

*Q46/Q47 refused
recode Q46 Q46_min (. = .r) if Q46_refused == 1
recode Q47 Q47_min (. = .r) if Q47_refused == 1


*Q66/67
recode Q67 (. = .a) if Q66 == 2 | Q66 == .d | Q66 == .r 
recode Q66 Q67 (. = .a) if mode == 2

****** Renaming variables, recoding value labels, and labeling variables ******

*------------------------------------------------------------------------------*

* Recode value labels:
* Recode values and value labels so that their values and direction make sense

* All Yes/No questions

recode Q6 Q11 Q12 Q13 Q18 Q25_A Q26 Q29 Q41 /// 
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no)

recode Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q66 /// 
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.d = .d "Don't know") /// 
	   (.a = .a NA), ///
	   pre(rec) label(yes_no_dk)

lab val Q46_refused Q47_refused yes_no

* For future data, may need to add Q37_B 

recode Q39 Q40 /// 
	   (1 = 1 Yes) (2 = 0 No) ///
	   (3 = .a "I did not get healthcare in past 12 months") ///
	   (.r = .r Refused), ///
	   pre(rec) label(yes_no_na)
	   
* All Excellent to Poor scales

recode Q9 Q10 Q48_A Q48_B Q48_C Q48_D Q48_F Q48_G Q48_H Q48_I Q54 Q55 Q56 Q59 Q60 Q61 ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(exc_poor)
	   
recode Q22  ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) (5 = 0 Poor) /// 
	   (6 = .a "I did not receive healthcare form this provider in the past 12 months") /// 
	   (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_hlthcare)
	   
recode Q48_E ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "I have not had prior visits or tests") (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_visits)
	 
recode Q48_J ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "The clinic had no other staff") (.r = .r Refused), /// 
	   pre(rec) label(exc_poor_staff)
	   
recode Q50_A Q50_B Q50_C Q50_D ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .d "I am unable to judge") (.r = .r Refused) ///
	   (.a = .a NA), /// 
	   pre(rec) label(exc_poor_judge)

* All Very Confident to Not at all Confident scales 
	   
recode Q16 Q17 Q51 Q52 Q53 ///
	   (1 = 3 "Very confident") (2 = 2 "Somewhat confident") /// 
	   (3 = 1 "Not too confident") (4 = 0 "Not at all confident") /// 
	   (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(vc_nc)
	   
* Miscellaneous questions with unique answer options

recode Interviewer_Gender ///
	(1 = 0 Male) (2 = 1 Female), ///
	pre(rec) label(int_gender)

* Without relabeling (removing the appostrophe) next command will not run 
lab var Q2 
recode Q2 (2 = 0 "18 to 29") (3 = 1 "30-39") (4 = 2 "40-49") (5 = 3 "50-59") ///
		  (6 = 4 "60-69") (7 = 5 "70-79") (8 = 6 "80+") (.r = .r "Refused") ///
		  (.a = .a "NA"), pre(rec) label(age_cat)

recode Q3 ///
	(1 = 0 Male) (2 = 1 Female) (3 = 2 "Another gender") (.r = .r Refused), ///
	pre(rec) label(gender)

recode Q14_NEW ///
	(1 = 0 "0- no doses received") (2 = 1 "1 dose") (3 = 2 "2 doses") ///
	(4 = 3 "3 doses") (5 = 4 "More than 3 doses") (.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(covid_vacc)
	
recode Q15 /// 
	   (1 = 1 "Yes, I plan to receive all required doses") ///
	   (2 = 0 "No, don't plan to receive all required doses") ///
	   (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no_doses)
	   
recode Q24 ///
	(1 = 0 "0") (2 = 1 "1-4") (3 = 2 "5-9") (4 = 3 "10 or more") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(number_visits)
	
recode Q49 ///
	(1 = 0 "0") (2 = 1 "1") (3 = 2 "2") (4 = 3 "3") (5 = 4 "4") (6 = 5 "5") ///
	(7 = 6 "6") (8 = 7 "7") (9 = 8 "8") (10 = 9 "9") (11 = 10 "10") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(prom_score)

recode Q57 ///
	(3 = 0 "Getting worse") (2 = 1 "Staying the same") (1 = 2 "Getting better") ///
	(.r = .r "Refused") , pre(rec) label(system_outlook)

*------------------------------------------------------------------------------*

* Renaming variables 
* Rename variables to match question numbers in current survey 

***Drop all the ones that were recoded, then drop the recode, and rename then according to the documents
drop Interviewer_Gender Q2 Q3 Q6 Q11 Q12 Q13 Q18 Q25_A Q26 Q29 Q41 Q30 Q31 /// 
	 Q32 Q33 Q34 Q35 Q36 Q38 Q66 Q39 Q40 Q9 Q10 Q22 Q48_A Q48_B Q48_C Q48_D ///
	 Q48_F Q48_G Q48_H Q48_I Q54 Q55 Q56 Q59 Q60 Q61 Q48_E Q48_J Q50_A Q50_B ///
	 Q50_C Q50_D Q16 Q17 Q51 Q52 Q53 Q3 Q14_NEW Q15 Q24 Q49 Q57

ren rec* *
  
ren Q14_NEW Q14
ren Q15_NEW Q15
ren Q19_4 Q19_other
ren Q21_9 Q21_other
ren Q28 Q28_A
ren Q28_NEW Q28_B
*ren Q37_B Q37
ren Q42_10 Q42_other
ren Q43_4 Q43_other
ren Q66 Q64
ren Q67 Q65
ren time_new Time
ren ECS_ID Respondent_ID 
* Check ID variable in future data 
* Q37_B not currently in these data 

*Reorder variables

order Q*, sequential
order Q*, after(Interviewer_Gender)

* Numeric questions needing NA and Refused value labels 
lab def na_rf .a "NA" .r "Refused"
lab val Q1 Q23 Q25_B Q27 Q28_A Q28_B Q46 Q46_min Q47 Q47_min Q65 na_rf

* NOTE:
* I am aware that some of the country-specific questions or questions with 8+ 
* options have value labels, but not labels for .a or .r.  I don't think it's 
* worth the effort right now (e.g. Q20), but will have R help me with ths in future.
* Hopefully Ipsos can send us a detailed codebook for country-specific value labels
* and then it would be easy.   

*------------------------------------------------------------------------------*

* Labeling variables 
 
lab var int_length "Interview length (in minutes)"
lab var Q1 "Q1. Respondent еxact age"
lab var Q2 "Q2. Respondent's age group"
lab var Q3 "Q3. Q3. Respondent gender"
lab var Q4 "Q4. Type of area where respondent lives"
lab var Q5 "Q5. County, state, region where respondent lives"
lab var Q6 "Q6. Do you have health insurance?"
lab var Q7 "Q7. What type of health insurance do you have?"
lab var Q7_other "Q7_other. Other type of health insurance"
lab var Q8 "Q8. Highest level of education completed by the respondent"
lab var Q9 "Q9. In general, would you say your health is:"
lab var Q10 "Q10. In general, would you say your mental health is?"
lab var Q11 "Q11. Do you have any longstanding illness or health problem?"
lab var Q12 "Q12. Have you ever had COVID-19 or coronavirus?"
lab var Q13 "Q13. Was it confirmed by a test?"
lab var Q14 "Q14. How many doses of a COVID-19 vaccine have you received?"
lab var Q15 "Q15. Do you plan to receive all recommended doses if they are available to you?"
lab var Q16 "Q16. How confident are you that you are responsible for managing your health?"
lab var Q17 "Q17. Can tell a healthcare provider your concerns even when not asked?"
lab var Q18 "Q18. Is there one healthcare facility or provider's group you usually go to?"
lab var Q19 "Q19. Is this a public, private, or NGO/faith-based healthcare facility?"
lab var Q19_other "Q19. Other"
lab var Q20 "Q20. What type of healthcare facility is this?"
lab var Q20_other "Q20. Other"
lab var Q21 "Q21. Why did you choose this healthcare facility?"
lab var Q21_other "Q21. Other"
lab var Q22 "Q22. Overall respondent's rating of the quality received in this facility"
lab var Q23 "Q23. How many healthcare visits in total have you made in the past 12 months?"
lab var Q24 "Q24. Total number of healthcare visits in the past 12 months (range)"
lab var Q25_A "Q25_A. Was this visit for COVID-19?"
lab var Q25_B "Q25_B. How many of these visits were for COVID-19? "
lab var Q26 "Q26. Were all of the visits you made to the same healthcare facility?"
lab var Q27 "Q27. How many different healthcare facilities did you go to?"
lab var Q28_A "Q28_A. How many visits did you have with a healthcare provider at your home?"
lab var Q28_B "Q28_B. How many virtual or telemedicine visits did you have?"
lab var Q29 "Q29. Did you stay overnight at a healthcare facility as a patient?"
lab var Q30 "Q30. Blood pressure tested in the past 12 months"
lab var Q31 "Q31. Received a mammogram in the past 12 months"
lab var Q32 "Q32. Received cervical cancer screening, like a pap test or visual inspection"
lab var Q33 "Q33. Had your eyes or vision checked in the past 12 months"
lab var Q34 "Q34. Had your teeth checked in the past 12 months"
lab var Q35 "Q35. Had a blood sugar test in the past 12 months"
lab var Q36 "Q36. Had a blood cholesterol test in the past 12 months"
*lab var Q37 "Q37_B. Had a test for HIV in the past 12 months"
lab var Q38 "Q38. Received care for depression, anxiety, or another mental health condition"
lab var Q39 "Q39. A medical mistake was made in your treatment or care in the past 12 months"
lab var Q40 "Q40. You were treated unfairly or discriminated against in the past 12 months"
lab var Q41 "Q41. Have you needed medical attention but you did not get it in past 12 months?"
lab var Q42 "Q42. The last time this happened, what was the main reason?"
lab var Q42_other "Q42. Other"
lab var Q43 "Q43. Last healthcare visit in a public, private, or NGO/faith-based facility?"
lab var Q43_other "Q43. Other"
lab var Q44 "Q44. What type of healthcare facility is this?"
lab var Q44_other "Q44. Other"
lab var Q45 "Q45. What was the main reason you went?"
lab var Q45_other "Q45. Other"
lab var Q46_refused "Q46. Refused"
lab var Q46 "Q46. Approximately how long did you wait before seeing the provider?"
lab var Q46_min "Q46. In minutes: Approximately how long did you wait before seeing the provider?"
lab var Q47_refused "Q47. Refused"
lab var Q47 "Q47. Approximately how much time did the provider spend with you?"
lab var Q47_min "Q47. In minutes: Approximately how much time did the provider spend with you?"
lab var Q48_A "Q48_A. How would you rate the overall quality of care you received?"
lab var Q48_B "Q48_B. How would you rate the knowledge and skills of your provider?"
lab var Q48_C "Q48_C. How would you rate the equipment and supplies that the provider had?"
lab var Q48_D "Q48_D. How would you rate the level of respect your provider showed you?"
lab var Q48_E "Q48_E. How would you rate your provider knowledge about your prior visits?"
lab var Q48_F "Q48_F. How would you rate whether your provider explained things clearly?"
lab var Q48_G "Q48_G. How would you rate whether you were involved in your care decisions?"
lab var Q48_H "Q48_H. How would you rate the amount of time your provider spent with you?"
lab var Q48_I "Q48_I. How would you rate the amount of time you waited before being seen?"
lab var Q48_J "Q48_J. How would you rate the courtesy and helpfulness at the facility?"
lab var Q49 "Q49. How likely would recommend this facility to a friend or family member?"
lab var Q50_A "Q50_A. How would you rate the quality of care provided for care for pregnancy?"
lab var Q50_B "Q50_B. How would you rate the quality of care provided for children?"
lab var Q50_C "Q50_C. How would you rate the quality of care provided for chronic conditions?"
lab var Q50_D "Q50_D. How would you rate the quality of care provided for the mental health?"
lab var Q51 "Q51. How confident are you that you'd get good healthcare if you were very sick?"
lab var Q52 "Q52. How confident are you that you'd be able to afford the care you requiered?"
lab var Q53 "Q53. How confident are you that the government considers the public's opinion?"
lab var Q54 "Q54. How would you rate the quality of public healthcare system in your country?"
lab var Q55 "Q55. How would you rate the quality of private for-profit healthcare?"
lab var Q56 "Q56. How would you rate the quality of the NGO or faith-based healthcare?"
lab var Q57 "Q57. Is your country's health system is getting better, same or worse?"
lab var Q58 "Q58. Which of these statements do you agree with the most?"
lab var Q59 "Q59. How would you rate the government's management of the COVID-19 pandemic?"
lab var Q60 "Q60. How would you rate the quality of care provided? (Vignette, option 1)"
lab var Q61 "Q61. How would you rate the quality of care provided? (Vignette, option 2)"
lab var Q62 "Q62. Respondent's mother tongue or native language"
lab var Q62_other "Q62. Other"
lab var Q63 "Q63. Total monthly household income"
lab var Q64 "Q64. Do you have another mobile phone number besides the one I am calling you on?"
lab var Q65 "Q65. How many other mobile phone numbers do you have?"

*------------------------------------------------------------------------------*

* Save data

* save "$data_mc/02 recoded data/pvs_ke_01.dta", replace
* Just saving as a different version for now
 save "$data_mc/02 recoded data/pvs_ke_02.dta", replace


*------------------------------------------------------------------------------*

********************************** Ethiopia ***********************************

* NOTE: In future, may receive Kenya/Ethiopia data together and will not need to
* recode separately. For now, this is necessary. Fortunately, very few (or none)
* changes between Kenya and Ethiopia data/code. 

* Import raw data 
u "$data_mc/00 interim data/HARVARD(ET_Main,Ke_Main,Ke_F2F)_21.09.222.dta", clear
* These are interim data with Ethiopia and Kenya combined
keep if Country == 3

*------------------------------------------------------------------------------*

* Fix interview length variable and other time variables 
* Edit this section to include other date and time variables as needed 

* Formatting time 
* format time_new Q46 Q47 %tcHH:MM:SS

* Converting interview length to minutes so it can be summarized

gen int_length = (hh(IntLength)*3600 + mm(IntLength)*60 + ss(IntLength)) / 60

* Converting Q46 and Q47 to minutes so it can be summarized

gen Q46_min = (hh(Q46)*3600 + mm(Q46)*60 + ss(Q46)) / 60

gen Q47_min = (hh(Q47)*3600 + mm(Q47)*60 + ss(Q47)) / 60

*------------------------------------------------------------------------------*

* Drop any unwanted/empty variables
* Generate any new needed variables

* Make sure no under 18 
drop if Q2 == 1 | Q1 < 18

*------------------------------------------------------------------------------*

* Recode all Refused and Don't know

* Don't know is 997 in these raw data 
recode Q23 Q25_A Q25_B Q27 Q28 Q28_NEW Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q63 ///
	   Q66 Q67 (997 = .d)

* Refused is 996 in these raw data 
recode Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12 Q13 Q14_NEW Q15_NEW Q16 Q17 /// 
	   Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25_A Q25_B Q26 Q27 Q28 Q28_NEW Q29 Q30 /// 
	   Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q39 Q40 Q41 Q42 Q43 Q44 Q45 Q46 Q47 ///
	   Q46_refused Q47_refused Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F Q48_G /// 
	   Q48_H Q48_I Q48_J Q49 Q50_A Q50_B Q50_C Q50_D Q51 Q52 Q53 Q54 Q55 /// 
	   Q56 Q57 Q58 Q59 Q60 Q61 Q62 Q63 Q66 Q67 (996 = .r)	
	
*------------------------------------------------------------------------------*

* Recode missing values to NA for questions respondents would not have been asked due to skip patterns

*Q1/Q2 
recode Q2 (. = .a) if Q1 != .r
recode Q1 (. = .r) if Q2 != .a

* Q7 
recode Q7 (. = .a) if Q6 == 2 | Q6 == .r 

* Q13 
recode Q13 (. = .a) if Q12 == 2 | Q12 == .r | Q12 == .d 

* Q15
recode Q15_NEW (. = .a) if Q14_NEW == 3 | Q14_NEW == 4 | Q14_NEW == 5 | Q14_NEW == .r

*Q19-22
recode Q19 Q20 Q21 Q22 (. = .a) if Q18 == 2 | Q18 == .r 
recode Q20 (. = .a) if Q19 == 4 | Q19 == .r

* NA's for Q23-27 
recode Q24 (. = .a) if Q23 != .d | Q23 != .r
recode Q25_A (. = .a) if Q23 != 1
recode Q25_B (. = .a) if Q23 == 0 | Q23 == 1 | Q24 == 1 | Q24 == .r 
recode Q26 (. = .a) if Q23 == 0 | Q23 == 1 | Q24 == 1 | Q24 == .r 
recode Q27 (. = .a) if Q26 != 2

* Q31 & Q32
recode Q31 (. = .a) if Q3 == 1 | Q1 < 50 | Q2 == 1 | Q2 == 2 | Q2 == 3 | Q2 == 4 | Q1 == .r | Q2 == .r 
recode Q32 (. = .a) if Q3 == 1 | Q1 == .r | Q2 == .r

* Q42
recode Q42 (. = .a) if Q41 == 2 | Q41 == .r


* Q43-49 NA's
recode Q43 Q44 Q45 Q46 Q46_min Q46_refused Q47 Q47_min Q47_refused Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F /// 
	   Q48_G Q48_H Q48_I Q48_J Q49 (. = .a) if Q23 == 0 | Q24 == 1 | Q24 == .r
	   
recode Q44 (. = .a) if Q43 == 4 | Q43 == .r

*Q46/Q47 refused
recode Q46 Q46_min (. = .r) if Q46_refused == 1
recode Q47 Q47_min (. = .r) if Q47_refused == 1

*Q66/67
recode Q67 (. = .a) if Q66 == 2 | Q66 == .d | Q66 == .r 
recode Q66 Q67 (. = .a) if mode == 2

****** Renaming variables, recoding value labels, and labeling variables ******

*------------------------------------------------------------------------------*

* Recode value labels:
* Recode values and value labels so that their values and direction make sense

* All Yes/No questions

recode Q6 Q11 Q12 Q13 Q18 Q25_A Q26 Q29 Q41 /// 
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no)

recode Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q66 /// 
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.d = .d "Don't know") /// 
	   (.a = .a NA), ///
	   pre(rec) label(yes_no_dk)

lab val Q46_refused Q47_refused yes_no

* For future data, may need to add Q37_B 

recode Q39 Q40 /// 
	   (1 = 1 Yes) (2 = 0 No) ///
	   (3 = .a "I did not get healthcare in past 12 months") ///
	   (.r = .r Refused), ///
	   pre(rec) label(yes_no_na)
	   
* All Excellent to Poor scales

recode Q9 Q10 Q48_A Q48_B Q48_C Q48_D Q48_F Q48_G Q48_H Q48_I Q54 Q55 Q56 Q59 Q60 Q61 ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(exc_poor)
	   
recode Q22  ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) (5 = 0 Poor) /// 
	   (6 = .a "I did not receive healthcare form this provider in the past 12 months") /// 
	   (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_hlthcare)
	   
recode Q48_E ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "I have not had prior visits or tests") (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_visits)
	 
recode Q48_J ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "The clinic had no other staff") (.r = .r Refused), /// 
	   pre(rec) label(exc_poor_staff)
	   
recode Q50_A Q50_B Q50_C Q50_D ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .d "I am unable to judge") (.r = .r Refused) ///
	   (.a = .a NA), /// 
	   pre(rec) label(exc_poor_judge)

* All Very Confident to Not at all Confident scales 
	   
recode Q16 Q17 Q51 Q52 Q53 ///
	   (1 = 3 "Very confident") (2 = 2 "Somewhat confident") /// 
	   (3 = 1 "Not too confident") (4 = 0 "Not at all confident") /// 
	   (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(vc_nc)
	   
* Miscellaneous questions with unique answer options

recode Interviewer_Gender ///
	(1 = 0 Male) (2 = 1 Female), ///
	pre(rec) label(int_gender)

* Without relabeling (removing the appostrophe) next command will not run 
lab var Q2 
recode Q2 (2 = 0 "18 to 29") (3 = 1 "30-39") (4 = 2 "40-49") (5 = 3 "50-59") ///
		  (6 = 4 "60-69") (7 = 5 "70-79") (8 = 6 "80+") (.r = .r "Refused") ///
		  (.a = .a "NA"), pre(rec) label(age_cat)

recode Q3 ///
	(1 = 0 Male) (2 = 1 Female) (3 = 2 "Another gender") (.r = .r Refused), ///
	pre(rec) label(gender)

recode Q14_NEW ///
	(1 = 0 "0- no doses received") (2 = 1 "1 dose") (3 = 2 "2 doses") ///
	(4 = 3 "3 doses") (5 = 4 "More than 3 doses") (.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(covid_vacc)
	
recode Q15 /// 
	   (1 = 1 "Yes, I plan to receive all required doses") ///
	   (2 = 0 "No, don't plan to receive all required doses") ///
	   (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no_doses)
	   
recode Q24 ///
	(1 = 0 "0") (2 = 1 "1-4") (3 = 2 "5-9") (4 = 3 "10 or more") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(number_visits)
	
recode Q49 ///
	(1 = 0 "0") (2 = 1 "1") (3 = 2 "2") (4 = 3 "3") (5 = 4 "4") (6 = 5 "5") ///
	(7 = 6 "6") (8 = 7 "7") (9 = 8 "8") (10 = 9 "9") (11 = 10 "10") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(prom_score)

recode Q57 ///
	(3 = 0 "Getting worse") (2 = 1 "Staying the same") (1 = 2 "Getting better") ///
	(.r = .r "Refused") , pre(rec) label(system_outlook)

*------------------------------------------------------------------------------*

* Renaming variables 
* Rename variables to match question numbers in current survey 

***Drop all the ones that were recoded, then drop the recode, and rename then according to the documents
drop Interviewer_Gender Q2 Q3 Q6 Q11 Q12 Q13 Q18 Q25_A Q26 Q29 Q41 Q30 Q31 /// 
	 Q32 Q33 Q34 Q35 Q36 Q38 Q66 Q39 Q40 Q9 Q10 Q22 Q48_A Q48_B Q48_C Q48_D ///
	 Q48_F Q48_G Q48_H Q48_I Q54 Q55 Q56 Q59 Q60 Q61 Q48_E Q48_J Q50_A Q50_B ///
	 Q50_C Q50_D Q16 Q17 Q51 Q52 Q53 Q3 Q14_NEW Q15 Q24 Q49 Q57

ren rec* *
  
ren Q14_NEW Q14
ren Q15_NEW Q15
ren Q19_4 Q19_other
ren Q21_9 Q21_other
ren Q28 Q28_A
ren Q28_NEW Q28_B
*ren Q37_B Q37
ren Q42_10 Q42_other
ren Q43_4 Q43_other
ren Q66 Q64
ren Q67 Q65
ren time_new Time
drop Respondent_ID 
* NOTE: This is currently empty - check in future data 
ren ECS_ID Respondent_ID


* Q37_B not currently in these data 

*Reorder variables

order Q*, sequential
order Q*, after(Interviewer_Gender)

	
* Numeric questions needing NA and Refused value labels 
lab def na_rf .a "NA" .r "Refused"
lab val Q23 Q25_B Q27 Q28_A Q28_B Q46 Q46_min Q47 Q47_min Q65 na_rf

*------------------------------------------------------------------------------*

* Labeling variables 
 
lab var int_length "Interview length (in minutes)"
lab var Q1 "Q1. Respondent еxact age"
lab var Q2 "Q2. Respondent's age group"
lab var Q3 "Q3. Q3. Respondent gender"
lab var Q4 "Q4. Type of area where respondent lives"
lab var Q5 "Q5. County, state, region where respondent lives"
lab var Q6 "Q6. Do you have health insurance?"
lab var Q7 "Q7. What type of health insurance do you have?"
lab var Q7_other "Q7_other. Other type of health insurance"
lab var Q8 "Q8. Highest level of education completed by the respondent"
lab var Q9 "Q9. In general, would you say your health is:"
lab var Q10 "Q10. In general, would you say your mental health is?"
lab var Q11 "Q11. Do you have any longstanding illness or health problem?"
lab var Q12 "Q12. Have you ever had COVID-19 or coronavirus?"
lab var Q13 "Q13. Was it confirmed by a test?"
lab var Q14 "Q14. How many doses of a COVID-19 vaccine have you received?"
lab var Q15 "Q15. Do you plan to receive all recommended doses if they are available to you?"
lab var Q16 "Q16. How confident are you that you are responsible for managing your health?"
lab var Q17 "Q17. Can tell a healthcare provider your concerns even when not asked?"
lab var Q18 "Q18. Is there one healthcare facility or provider's group you usually go to?"
lab var Q19 "Q19. Is this a public, private, or NGO/faith-based healthcare facility?"
lab var Q19_other "Q19. Other"
lab var Q20 "Q20. What type of healthcare facility is this?"
lab var Q20_other "Q20. Other"
lab var Q21 "Q21. Why did you choose this healthcare facility?"
lab var Q21_other "Q21. Other"
lab var Q22 "Q22. Overall respondent's rating of the quality received in this facility"
lab var Q23 "Q23. How many healthcare visits in total have you made in the past 12 months?"
lab var Q24 "Q24. Total number of healthcare visits in the past 12 months (range)"
lab var Q25_A "Q25_A. Was this visit for COVID-19?"
lab var Q25_B "Q25_B. How many of these visits were for COVID-19? "
lab var Q26 "Q26. Were all of the visits you made to the same healthcare facility?"
lab var Q27 "Q27. How many different healthcare facilities did you go to?"
lab var Q28_A "Q28_A. How many visits did you have with a healthcare provider at your home?"
lab var Q28_B "Q28_B. How many virtual or telemedicine visits did you have?"
lab var Q29 "Q29. Did you stay overnight at a healthcare facility as a patient?"
lab var Q30 "Q30. Blood pressure tested in the past 12 months"
lab var Q31 "Q31. Received a mammogram in the past 12 months"
lab var Q32 "Q32. Received cervical cancer screening, like a pap test or visual inspection"
lab var Q33 "Q33. Had your eyes or vision checked in the past 12 months"
lab var Q34 "Q34. Had your teeth checked in the past 12 months"
lab var Q35 "Q35. Had a blood sugar test in the past 12 months"
lab var Q36 "Q36. Had a blood cholesterol test in the past 12 months"
*lab var Q37 "Q37_B. Had a test for HIV in the past 12 months"
lab var Q38 "Q38. Received care for depression, anxiety, or another mental health condition"
lab var Q39 "Q39. A medical mistake was made in your treatment or care in the past 12 months"
lab var Q40 "Q40. You were treated unfairly or discriminated against in the past 12 months"
lab var Q41 "Q41. Have you needed medical attention but you did not get it in past 12 months?"
lab var Q42 "Q42. The last time this happened, what was the main reason?"
lab var Q42_other "Q42. Other"
lab var Q43 "Q43. Last healthcare visit in a public, private, or NGO/faith-based facility?"
lab var Q43_other "Q43. Other"
lab var Q44 "Q44. What type of healthcare facility is this?"
lab var Q44_other "Q44. Other"
lab var Q45 "Q45. What was the main reason you went?"
lab var Q45_other "Q45. Other"
lab var Q46_refused "Q46. Refused"
lab var Q46 "Q46. Approximately how long did you wait before seeing the provider?"
lab var Q46_min "Q46. In minutes: Approximately how long did you wait before seeing the provider?"
lab var Q47_refused "Q47. Refused"
lab var Q47 "Q47. Approximately how much time did the provider spend with you?"
lab var Q47_min "Q47. In minutes: Approximately how much time did the provider spend with you?"
lab var Q48_A "Q48_A. How would you rate the overall quality of care you received?"
lab var Q48_B "Q48_B. How would you rate the knowledge and skills of your provider?"
lab var Q48_C "Q48_C. How would you rate the equipment and supplies that the provider had?"
lab var Q48_D "Q48_D. How would you rate the level of respect your provider showed you?"
lab var Q48_E "Q48_E. How would you rate your provider knowledge about your prior visits?"
lab var Q48_F "Q48_F. How would you rate whether your provider explained things clearly?"
lab var Q48_G "Q48_G. How would you rate whether you were involved in your care decisions?"
lab var Q48_H "Q48_H. How would you rate the amount of time your provider spent with you?"
lab var Q48_I "Q48_I. How would you rate the amount of time you waited before being seen?"
lab var Q48_J "Q48_J. How would you rate the courtesy and helpfulness at the facility?"
lab var Q49 "Q49. How likely would recommend this facility to a friend or family member?"
lab var Q50_A "Q50_A. How would you rate the quality of care provided for care for pregnancy?"
lab var Q50_B "Q50_B. How would you rate the quality of care provided for children?"
lab var Q50_C "Q50_C. How would you rate the quality of care provided for chronic conditions?"
lab var Q50_D "Q50_D. How would you rate the quality of care provided for the mental health?"
lab var Q51 "Q51. How confident are you that you'd get good healthcare if you were very sick?"
lab var Q52 "Q52. How confident are you that you'd be able to afford the care you requiered?"
lab var Q53 "Q53. How confident are you that the government considers the public's opinion?"
lab var Q54 "Q54. How would you rate the quality of public healthcare system in your country?"
lab var Q55 "Q55. How would you rate the quality of private for-profit healthcare?"
lab var Q56 "Q56. How would you rate the quality of the NGO or faith-based healthcare?"
lab var Q57 "Q57. Is your country's health system is getting better, same or worse?"
lab var Q58 "Q58. Which of these statements do you agree with the most?"
lab var Q59 "Q59. How would you rate the government's management of the COVID-19 pandemic?"
lab var Q60 "Q60. How would you rate the quality of care provided? (Vignette, option 1)"
lab var Q61 "Q61. How would you rate the quality of care provided? (Vignette, option 2)"
lab var Q62 "Q62. Respondent's mother tongue or native language"
lab var Q62_other "Q62. Other"
lab var Q63 "Q63. Total monthly household income"
lab var Q64 "Q64. Do you have another mobile phone number besides the one I am calling you on?"
lab var Q65 "Q65. How many other mobile phone numbers do you have?"

*------------------------------------------------------------------------------*

* Save data

save "$data_mc/02 recoded data/pvs_et_01.dta", replace

*------------------------------------------------------------------------------*

************************************* LAC **************************************

clear all

* Import raw data 
use "$data_mc/00 interim data/LAC interim data 10252022.dta", clear

*------------------------------------------------------------------------------*

* Fix interview length variable and other time variables 
* Edit this section to include other date and time variables as needed 

* Formatting time 
* format time_new Q46 Q47 %tcHH:MM:SS

* Converting interview length to minutes so it can be summarized

gen int_length = (hh(IntLength)*3600 + mm(IntLength)*60 + ss(IntLength)) / 60

* Converting Q46 and Q47 to minutes so it can be summarized

gen Q46_min = (hh(Q46)*3600 + mm(Q46)*60 + ss(Q46)) / 60

gen Q47_min = (hh(Q47)*3600 + mm(Q47)*60 + ss(Q47)) / 60

*------------------------------------------------------------------------------*

* Drop any unwanted/empty variables
* Generate any new needed variables

drop if Q2 == 1 | Q1 < 18

gen mode = 1

*------------------------------------------------------------------------------*

* Recode all Refused and Don't know

* Don't know is 997 in these raw data 
recode Q13B Q13E Q23 Q25_A Q25_B Q27 Q28 Q28_NEW Q30 Q31 Q32 Q33 Q34 Q35 Q36 ///
	   Q38 Q63 Q66 Q67 (997 = .d)

* Refused is 996 in these raw data 
recode Q1 Q2 Q3 Q3a Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12 Q13 Q13B Q13E Q14_NEW /// 
	   Q15_NEW Q16 Q17 Q18 Q19_PE Q19_UY Q19_CO Q20 Q21 Q22 Q23 Q24 Q25_A /// 
	   Q25_B Q26 Q27 Q28 Q28_NEW Q29 Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q39 Q40 /// 
	   Q41 Q42 Q43_PE Q43_UY Q43_CO Q44 Q45 Q46 Q47 Q48_A Q48_B Q48_C Q48_D /// 
	   Q48_E Q48_F Q48_G Q48_H Q48_I Q48_J Q49 Q50_A Q50_B Q50_C Q50_D Q51 /// 
	   Q52 Q53 Q54 Q55 Q56_UY Q56_PE Q57 Q58 Q59 Q60 Q61 Q62 Q63 Q66 Q67 /// 
	   (996 = .r)	
	
*------------------------------------------------------------------------------*

* Recode missing values to NA for questions respondents would not have been asked due to skip patterns

*Q1/Q2 
recode Q2 (. = .a) if Q1 != .r
recode Q1 (. = .r) if Q2 != .a

* NOTE:
* Q6 why completely missing?

* Q7 
* recode Q7 (. = .a) if Q6 == 2 | Q6 == .r 
* NOTE: Changing none to NA (reflects other countries Q6/Q7)
recode Q7 (14 = .a)
*Note to Neena: Should we make Q7 response 14 a NO in Q6 and else a YES (excluding .r)?

* Q13 
recode Q13 (. = .a) if Q12 == 2 | Q12 == .r | Q12 == .d 
recode Q13B (. = .a) if Q12 == 2 | Q12 == .r | Q12 == .d 
recode Q13E (. = .a) if Q13B == .a | Q13B == 1 | Q13B == .d | Q13B == .r

* drop Q13B Q13E Q13E_10
* NOTE: I think it's okay to keep these in the final data, just will change to .a for other countries after merge

* Q15
recode Q15_NEW (. = .a) if Q14_NEW == 3 | Q14_NEW == 4 | Q14_NEW == 5 | Q14_NEW == .r

*Q19-22
recode Q19_PE Q19_UY Q19_CO Q20 Q21 Q22 (. = .a) if Q18 == 2 | Q18 == .r 
recode Q19_PE (. = .a) if Country != 7
recode Q19_UY (. = .a) if Country != 10
recode Q19_CO (. = .a) if Country != 2
* recode Q20 (. = .a) if Q19_PE == 4 | Q19_UY == 4 | Q19_CO  == 4
* NOTE: Todd, I realized that for Kenya/Ethiopia when other was selected in 
* Q19, the programming directed to just Other, specify - but this appears to not 
* be the case in LAC countries. Hopefully we get their final tools soon and this 
* will be clearer. 
recode Q20 (. = .a) if Q19_PE == .r | Q19_UY == .r | Q19_CO  == .r

* NA's for Q23-27 
recode Q24 (. = .a) if Q23 != .d | Q23 != .r
recode Q25_A (. = .a) if Q23 != 1

recode Q25_B (. = .a) if Q23 == 0 | Q23 == 1 | Q24 == 1 | Q24 == .r 
recode Q26 (. = .a) if Q23 == 0 | Q23 == 1 | Q24 == 1 | Q24 == .r 
recode Q27 (. = .a) if Q26 != 2

* Q31 & Q32
recode Q31 (. = .a) if Q3 == 1 | Q1 < 50 | Q2 == 1 | Q2 == 2 | Q2 == 3 | Q2 == 4 | Q1 == .r | Q2 == .r 
recode Q32 (. = .a) if Q3 == 1 | Q1 == .r | Q2 == .r

* NOTE: This may change depending on which gender question is correct, Q3 or Q3a
* Based on missing for Q31/Q32, I think Q3a was used for skip pattern. 
* TODD - okay to change Q3 to Q3a here for Monday? 

* Q42
recode Q42 (. = .a) if Q41 == 2 | Q41 == .r


* Q43-49 NA's
recode Q43_CO Q43_PE Q43_UY Q44 Q45 Q46 Q46_min Q47 Q47_min Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F /// 
	   Q48_G Q48_H Q48_I Q48_J Q49 (. = .a) if Q23 == 0 | Q24 == 1 | Q24 == .r
	   
recode Q43_PE (. = .a) if Country != 7
recode Q43_UY (. = .a) if Country != 10
recode Q43_CO (. = .a) if Country != 2
recode Q44 (. = .a) if Q43_PE == .r | Q43_UY == .r | Q43_CO  == .r
* recode Q44 (. = .a) if Q43 == 4 


*Q46/Q47 refused
* recode Q46 Q46_min (. = .r) if Q46_refused == 1
* recode Q47 Q47_min (. = .r) if Q47_refused == 1

* NOTE: we should ask for these variables for LAC countries 
* TODD - okay to recode missing to .r for Q46 and Q47 for Monday? 
* (So we don't see missing in megatable)

* Q56_PE, Q56_UY
recode Q56_PE (. = .a) if Country != 7
recode Q56_UY (. = .a) if Country != 10

*Q62
recode Q62 (. = .a) if Country == 10

* NOTE: It looks like Q62 wasn't asked in UY? Adding this for now, but should check this

*Q66/67
recode Q67 (. = .a) if Q66 == 2 | Q66 == .d | Q66 == .r 
* recode Q66 Q67 (. = .a) if mode == 2

****** Renaming variables, recoding value labels, and labeling variables ******

*------------------------------------------------------------------------------*

* Relabeling - some labels that prevent commands from running
* Generally due to the appostrophes in the label
* Add any other variables if needed

lab var Q2
lab var Q13E 
lab var Q48_F 
lab var Q53 

* Recode value labels 
* Recode values and value labels so that their values and direction make sense

* All Yes/No questions

recode Q6 Q11 Q12 Q13 Q13B Q18 Q25_A Q26 Q29 Q41 /// 
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no)

recode Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q66 /// 
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.d = .d "Don't know") /// 
	   (.a = .a NA), ///
	   pre(rec) label(yes_no_dk)

* For future data, may need to add Q37_B 

recode Q39 Q40 /// 
	   (1 = 1 Yes) (2 = 0 No) ///
	   (3 = .a "I did not get healthcare in past 12 months") ///
	   (.r = .r Refused), ///
	   pre(rec) label(yes_no_na)
	   
* All Excellent to Poor scales

recode Q9 Q10 Q48_A Q48_B Q48_C Q48_D Q48_F Q48_G Q48_H Q48_I Q54 Q55 Q56_PE Q56_UY Q59 Q60 Q61 ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(exc_poor)
	   
recode Q22  ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) (5 = 0 Poor) /// 
	   (6 = .a "I did not receive healthcare form this provider in the past 12 months") /// 
	   (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_hlthcare)
	   
recode Q48_E ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "I have not had prior visits or tests") (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_visits)
	 
recode Q48_J ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "The clinic had no other staff") (.r = .r Refused), /// 
	   pre(rec) label(exc_poor_staff)
	   
recode Q50_A Q50_B Q50_C Q50_D ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .d "I am unable to judge") (.r = .r Refused) ///
	   (.a = .a NA), /// 
	   pre(rec) label(exc_poor_judge)

* All Very Confident to Not at all Confident scales 
	   
recode Q16 Q17 Q51 Q52 Q53  ///
	   (1 = 3 "Very confident") (2 = 2 "Somewhat confident") /// 
	   (3 = 1 "Not too confident") (4 = 0 "Not at all confident") /// 
	   (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(vc_nc)
	   
* Miscellaneous questions with unique answer options

recode Interviewer_Gender ///
	(1 = 0 Male) (2 = 1 Female), ///
	pre(rec) label(int_gender)

recode Q2 (2 = 0 "18 to 29") (3 = 1 "30-39") (4 = 2 "40-49") (5 = 3 "50-59") ///
		  (6 = 4 "60-69") (7 = 5 "70-79") (8 = 6 "80+") (.r = .r "Refused") ///
		  (.a = .a "NA"), pre(rec) label(age_cat)

recode Q3 ///
	(1 = 0 Male) (2 = 1 Female) (3 = 2 "Another gender") (.r = .r Refused), ///
	pre(rec) label(gender)

recode Q3a ///
	(1 = 0 Man) (2 = 1 Woman) (.r = .r Refused) (.a = .a "NA"), ///
	pre(rec) label(gender2)

recode Q14_NEW ///
	(1 = 0 "0- no doses received") (2 = 1 "1 dose") (3 = 2 "2 doses") ///
	(4 = 3 "3 doses") (5 = 4 "More than 3 doses") (.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(covid_vacc)
	
recode Q15 /// 
	   (1 = 1 "Yes, I plan to receive all required doses") ///
	   (2 = 0 "No, don't plan to receive all required doses") ///
	   (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no_doses)
	   
recode Q24 ///
	(1 = 0 "0") (2 = 1 "1-4") (3 = 2 "5-9") (4 = 3 "10 or more") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(number_visits)

recode Q45 ///
	(13 = 1 "Care for an urgent or acute health problem (accident or injury, fever, diarrhea, or a new pain or symptom)" ) ///
	(14 = 2 "Care for an illness or chronic health problem (hypertension, diabetes or a mental health problem-anxiety or depression") ///
	(15 = 3 "Preventive care or for a general checkup (for example, prenatal care, vaccinations, eye exam)")///
	(.a = .a "NA") (995 = 995 "Other, specify") (.r = .r "Refused"), ///
	pre(rec) label(main_reason)

* NOTE: Rodrigo, double check this. Q45 words seem to be slightly different for Kenya/Eth
*Rodrigo response: updated to the options of the LAC raw data.
	
recode Q49 ///
	(1 = 0 "0") (2 = 1 "1") (3 = 2 "2") (4 = 3 "3") (5 = 4 "4") (6 = 5 "5") ///
	(7 = 6 "6") (8 = 7 "7") (9 = 8 "8") (10 = 9 "9") (11 = 10 "10") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(prom_score)

recode Q57 ///
	(3 = 0 "Getting worse") (2 = 1 "Staying the same") (1 = 2 "Getting better") ///
	(.r = .r "Refused") , pre(rec) label(system_outlook)

	

*------------------------------------------------------------------------------*

* Renaming variables 
* Rename variables to match question numbers in current survey 

* Drop all the ones that were recoded, then drop the recode, and rename then according to the documents
drop Interviewer_Gender Q2 Q3 Q3a Q6 Q11 Q12 Q13 Q13B Q18 Q25_A Q26 Q29 Q41 /// 
	 Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q66 Q39 Q40 Q9 Q10 Q22 Q45 Q48_A Q48_B Q48_C ///
	 Q48_D Q48_F Q48_G Q48_H Q48_I Q54 Q55 Q56_PE Q56_UY Q59 Q60 Q61 Q48_E /// 
	 Q48_J Q50_A Q50_B Q50_C Q50_D Q16 Q17 Q51 Q52 Q53 Q3 Q14_NEW Q15 Q24 Q49 Q57

ren rec* *
 
ren Q7_995 Q7_other
ren Q14_NEW Q14
ren Q15_NEW Q15
ren Q19_4 Q19_other
ren Q20_Other Q20_other
ren Q21_9 Q21_other
ren Q28 Q28_A
ren Q28_NEW Q28_B
*ren Q37_B Q37
ren Q42_10 Q42_other
ren Q43_4 Q43_other
ren Q44_Other Q44_other
ren Q45_11 Q45_other
ren Q66 Q64
ren Q67 Q65
ren date Date
ren time_new Time

* Q37_B not currently in these data 

* Reorder variables

order Q*, sequential
order Q*, after(Interviewer_Gender)
order int_length, after(IntLength)
order mode, after(int_length)


* Numeric questions needing NA and Refused value labels 
lab def na_rf .a "NA" .r "Refused"
lab val Q23 Q25_B Q27 Q28_A Q28_B Q46 Q46_min Q47 Q47_min Q65 na_rf

*------------------------------------------------------------------------------*

* Labeling variables 
 
lab var int_length "Interview length (in minutes)"
lab var Q1 "Q1. Respondent еxact age"
lab var Q2 "Q2. Respondent's age group"
lab var Q3 "Q3. Respondent gender"
lab var Q3a "Q3A. Are you a man or a woman?"
lab var Q4 "Q4. Type of area where respondent lives"
lab var Q5 "Q5. County, state, region where respondent lives"
lab var Q6 "Q6. Do you have health insurance?"
lab var Q7 "Q7. What type of health insurance do you have?"
lab var Q7_other "Q7_other. Other type of health insurance"
lab var Q8 "Q8. Highest level of education completed by the respondent"
lab var Q9 "Q9. In general, would you say your health is:"
lab var Q10 "Q10. In general, would you say your mental health is?"
lab var Q11 "Q11. Do you have any longstanding illness or health problem?"
lab var Q12 "Q12. Have you ever had COVID-19 or coronavirus?"
lab var Q13 "Q13. Was it confirmed by a test?"
lab var Q13B "Q13B. Did you seek health care for COVID-19? (LAC Countries)"
lab var Q13E "Q13E. Why didnt you receive health care for COVID-19? (LAC Countries)"
lab var Q13E_10 "Q13E. Other"
lab var Q14 "Q14. How many doses of a COVID-19 vaccine have you received?"
lab var Q15 "Q15. Do you plan to receive all recommended doses if they are available to you?"
lab var Q16 "Q16. How confident are you that you are responsible for managing your health?"
lab var Q17 "Q17. Can tell a healthcare provider your concerns even when not asked?"
lab var Q18 "Q18. Is there one healthcare facility or provider's group you usually go to?"
lab var Q19_PE "Q19. Peru: Is this a public or private healthcare facility?"
lab var Q19_UY "Q19. Uruguay: Is this a public, private, or mutual healthcare facility?"
lab var Q19_CO "Q19. Colombia: Is this a public or private healthcare facility?"
lab var Q19_other "Q19. Other"
lab var Q20 "Q20. What type of healthcare facility is this?"
lab var Q20_other "Q20. Other"
lab var Q21 "Q21. Why did you choose this healthcare facility?"
lab var Q21_other "Q21. Other"
lab var Q22 "Q22. Overall respondent's rating of the quality received in this facility"
lab var Q23 "Q23. How many healthcare visits in total have you made in the past 12 months?"
lab var Q24 "Q24. Total number of healthcare visits in the past 12 months (range)"
lab var Q25_A "Q25_A. Was this visit for COVID-19?"
lab var Q25_B "Q25_B. How many of these visits were for COVID-19? "
lab var Q26 "Q26. Were all of the visits you made to the same healthcare facility?"
lab var Q27 "Q27. How many different healthcare facilities did you go to?"
lab var Q28_A "Q28_A. How many visits did you have with a healthcare provider at your home?"
lab var Q28_B "Q28_B. How many virtual or telemedicine visits did you have?"
lab var Q29 "Q29. Did you stay overnight at a healthcare facility as a patient?"
lab var Q30 "Q30. Blood pressure tested in the past 12 months"
lab var Q31 "Q31. Received a mammogram in the past 12 months"
lab var Q32 "Q32. Received cervical cancer screening, like a pap test or visual inspection"
lab var Q33 "Q33. Had your eyes or vision checked in the past 12 months"
lab var Q34 "Q34. Had your teeth checked in the past 12 months"
lab var Q35 "Q35. Had a blood sugar test in the past 12 months"
lab var Q36 "Q36. Had a blood cholesterol test in the past 12 months"
*lab var Q37 "Q37_B. Had a test for HIV in the past 12 months"
lab var Q38 "Q38. Received care for depression, anxiety, or another mental health condition"
lab var Q39 "Q39. A medical mistake was made in your treatment or care in the past 12 months"
lab var Q40 "Q40. You were treated unfairly or discriminated against in the past 12 months"
lab var Q41 "Q41. Have you needed medical attention but you did not get it in past 12 months?"
lab var Q42 "Q42. The last time this happened, what was the main reason?"
lab var Q42_other "Q42. Other"
lab var Q43_PE "Q43. Peru: Is this a public or private healthcare facility?"
lab var Q43_UY "Q43. Uruguay: Is this a public, private, or mutual healthcare facility?"
lab var Q43_CO "Q43. Colombia: Is this a public or private healthcare facility?"
lab var Q43_other "Q43. Other"
lab var Q44 "Q44. What type of healthcare facility is this?"
lab var Q44_other "Q44. Other"
lab var Q45 "Q45. What was the main reason you went?"
lab var Q45_other "Q45. Other"
lab var Q46_min "Q46. In minutes: Approximately how long did you wait before seeing the provider?"
lab var Q47_min "Q47. In minutes: Approximately how much time did the provider spend with you?"
*lab var Q46_refused "Q46. Refused"
lab var Q46 "Q46. Approximately how long did you wait before seeing the provider?"
*lab var Q47_refused "Q47. Refused"
lab var Q47 "Q47. Approximately how much time did the provider spend with you?"
lab var Q48_A "Q48_A. How would you rate the overall quality of care you received?"
lab var Q48_B "Q48_B. How would you rate the knowledge and skills of your provider?"
lab var Q48_C "Q48_C. How would you rate the equipment and supplies that the provider had?"
lab var Q48_D "Q48_D. How would you rate the level of respect your provider showed you?"
lab var Q48_E "Q48_E. How would you rate your provider knowledge about your prior visits?"
lab var Q48_F "Q48_F. How would you rate whether your provider explained things clearly?"
lab var Q48_G "Q48_G. How would you rate whether you were involved in your care decisions?"
lab var Q48_H "Q48_H. How would you rate the amount of time your provider spent with you?"
lab var Q48_I "Q48_I. How would you rate the amount of time you waited before being seen?"
lab var Q48_J "Q48_J. How would you rate the courtesy and helpfulness at the facility?"
lab var Q49 "Q49. How likely would recommend this facility to a friend or family member?"
lab var Q50_A "Q50_A. How would you rate the quality of care provided for care for pregnancy?"
lab var Q50_B "Q50_B. How would you rate the quality of care provided for children?"
lab var Q50_C "Q50_C. How would you rate the quality of care provided for chronic conditions?"
lab var Q50_D "Q50_D. How would you rate the quality of care provided for the mental health?"
lab var Q51 "Q51. How confident are you that you'd get good healthcare if you were very sick?"
lab var Q52 "Q52. How confident are you that you'd be able to afford the care you requiered?"
lab var Q53 "Q53. How confident are you that the government considers the public's opinion?"
lab var Q54 "Q54. How would you rate the quality of public healthcare system in your country?"
lab var Q55 "Q55. How would you rate the quality of private for-profit healthcare?"
lab var Q56_PE "Q56. Peru: How would you rate the quality of the social security system?"
lab var Q56_UY "Q56. Uruguay: How would you rate the quality of the mutual healthcare system?"
lab var Q57 "Q57. Is your country's health system is getting better, same or worse?"
lab var Q58 "Q58. Which of these statements do you agree with the most?"
lab var Q59 "Q59. How would you rate the government's management of the COVID-19 pandemic?"
lab var Q60 "Q60. How would you rate the quality of care provided? (Vignette, option 1)"
lab var Q61 "Q61. How would you rate the quality of care provided? (Vignette, option 2)"
lab var Q62 "Q62. Respondent's mother tongue or native language"
*lab var Q62_other "Q62. Other"
lab var Q63 "Q63. Total monthly household income"
lab var Q64 "Q64. Do you have another mobile phone number?"
lab var Q65 "Q65. How many other mobile phone numbers do you have?"

* NOTE: Variables not in these data: PSU_ID Interviewer_Language Language, and others 

save "$data_mc/02 recoded data/pvs_lac_01.dta", replace

*------------------------------------------------------------------------------*

********************************* Append data *********************************

u "$data_mc/02 recoded data/pvs_lac_01.dta", clear
append using "$data_mc/02 recoded data/pvs_ke_01.dta"
append using "$data_mc/02 recoded data/pvs_et_01.dta"

* NOTE: Is there a good way to confirm this append is working well in terms of values and value labels? 

ren Q19 Q19_KE_ET 
lab var Q19_KE_ET "Q19. Kenya/Ethiopia: Is this a public, private, or NGO/faith-based facility?"
ren Q43 Q43_KE_ET 
lab var Q43_KE_ET "Q43. Kenya/Ethiopia: Is this a public, private, or NGO/faith-based facility?"
ren Q56 Q56_KE_ET 
lab var Q56_KE_ET "Q56. Kenya/Ethiopia: How would you rate the quality of the NGO or faith-based healthcare?"

lab def m 1 "CATI" 2 "F2F"
lab val mode m
lab var mode "Mode of interview"

* Country-specific skip patterns
recode Q6 Q19_KE_ET Q43_KE_ET Q56_KE_ET (. = .a) if Country != 5 | Country != 3
recode Q3a Q13B Q13E (. = .a) if Country == 5 | Country == 3
recode Q19_UY Q43_UY Q56_UY (. = .a) if Country != 10
recode Q19_PE Q43_PE Q56_PE (. = .a) if Country != 7
recode Q19_CO Q43_CO (. = .a) if Country != 2
* NOTE: R, did I miss any? 
* The survey characteristic variables are okay to ignore for now (ID's, etc.)

* ordering below wasn't working well at first 

order Respondent_Serial Respondent_ID Unique_ID PSU_ID InterviewerID_recoded /// 
Interviewer_Language Interviewer_Gender mode Country Language Date Time /// 
IntLength int_length Q1_codes Q1 Q2 Q3 Q3a Q4 Q5 Q6 Q7 Q7_other Q8 Q9 Q10 ///
Q11 Q12 Q13 Q13B Q13E Q13E_10 Q14 Q15 Q16 Q17 Q18 Q19_KE_ET Q19_CO Q19_PE Q19_UY /// 
Q19_other Q20 Q20_other Q21 Q21_other Q22 Q23 Q24 Q25_A Q25_B Q26 Q27 Q28_A ///
Q28_B Q29 Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q39 Q40 Q41 Q42 Q42_other Q43_KE_ET ///
Q43_CO Q43_PE Q43_UY Q43_other Q44 Q44_other Q45 Q45_other Q46 Q46_min ///
Q46_refused Q47 Q47_min Q47_refused Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F /// 
Q48_G Q48_H Q48_I Q48_J Q49 Q50_A Q50_B Q50_C Q50_D Q51 Q52 Q53 Q54 Q55 /// 
Q56_KE_ET Q56_PE Q56_UY Q57 Q58 Q59 Q60 Q61 Q62 Q62_other Q63 Q64 Q65 QC_short _v1

* NOTE: Consider dropping these below. TODD - thoughts on dropping for Monday? 

* drop PSU_ID InterviewerID_recoded Interviewer_Language ///
* Interviewer_Gender IntLength Unique_ID

* Then, Respondent_Serial, Respondent_ID, mode, Country, Language, Date, Time, int_length remain

save "$data_mc/02 recoded data/pvs_ke_et_lac_01.dta", replace

* NOTE: 
* Ethiopia data missing value labels on Q63 and Q62, it's fine for now 


*------------------------------------------------------------------------------*
* NOTE: I think all of these checks are necessary for now. As we move forward
* I will probably comment out this whole section so it does not get run each time, 
* but is useful when we clean a new country's data. 

***************************** Data quality checks *****************************

u "$data_mc/02 recoded data/pvs_ke_et_lac_01.dta", replace

* Macros for these commands
gl inputfile	"$data_mc/03 test output/Input/dq_inputs.xlsm"	
gl dq_output	"$output/dq_output.xlsx"				
gl id 			"Respondent_ID"	
gl key			"Respondent_Serial"	
gl enum			"InterviewerID_recoded"
gl date			"Date"	
gl time			"Time"
gl duration		"int_length"
gl keepvars 	"Country"
global all_dk 	"Q13B Q13E Q23 Q25_A Q25_B Q27 Q28_A Q28_B Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q50_A Q50_B Q50_C Q50_D Q63 Q64 Q65"
global all_num 	"Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12 Q13 Q14 Q15 Q16 Q17 Q18 Q19_KE_ET Q19_CO Q19_PE Q19_UY Q20 Q21 Q22 Q23 Q24 Q25_A Q25_B Q26 Q27 Q28_A Q28_B Q29 Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q39 Q40 Q41 Q42 Q43_KE_ET Q43_CO Q43_PE Q43_UY Q44 Q45 Q46 Q47 Q46_min Q46_refused Q47_min Q47_refused Q48_A Q48_B Q48_C Q48_D Q48_E Q48_F Q48_G Q48_H Q48_I Q48_J Q49 Q50_A Q50_B Q50_C Q50_D Q51 Q52 Q53 Q54 Q55 Q56_KE_ET Q56_PE Q56_UY Q57 Q58 Q59 Q60 Q61 Q62 Q63 Q64 Q65"


*====================== Check start/end date of survey ======================* 


* list $id if $date < date("01-Jul-2020", "DMY") | $date > date("01-Dec-2022", "DMY") 

* list $id if Time > date("18:00:00", "07:00:00") | Time < date("18:00:00", "%tcHH:MM:SS")												
												
* NOTE: The above lines are still not working well for me. It runs - but appears to not be accurate 
* Just leaving in case we decide to add	them back 											
												
*========================== Find Survey Duplicates ==========================* 

 * This command finds and exports duplicates in Survey ID

 
ipacheckids ${id},							///
	enumerator(${enum}) 					///	
	date(${date})	 						///
	key(${key}) 							///
	outfile("${dq_output}") 				///
	outsheet("id duplicates")				///
	keep(${keepvars})	 					///
	sheetreplace							
						

    * Other methods 

	isid $id
	duplicates list $id

*=============================== Outliers ==================================* 
 
* This command checks for outliers among numeric survey variables 
* This code requires an input file that lists variables to check for outliers 

ipacheckoutliers using "${inputfile}",			///
	id(${id})									///
	enumerator(${enum}) 						///	
	date(${date})	 							///
	sheet("outliers")							///
    outfile("${dq_output}") 					///
	outsheet("outliers")						///
	sheetreplace

   
*============================= Other Specify ===============================* 
 
* This command lists all other, specify values
* This command requires an input file that lists all the variables with other, specify text 

 
ipacheckspecify using "${inputfile}",			///
	id(${id})									///
	enumerator(${enum})							///	
	date(${date})	 							///
	sheet("other specify")						///
    outfile("${dq_output}") 					///
	outsheet1("other specify")					///
	outsheet2("other specify (choices)")		///
	sheetreplace
	
*	loc childvars "`r(childvarlist)'"

*========================= Summarizing All Missing ============================* 

* Below I summarize NA (.a), Don't know (.d), Refused (.r) and true Missing (.) 
* across the numeric variables(only questions) in the dataset by country
* This is helpful to check if cleaning commands above are working (esp skip pattern recode)
   
* Count number of NA, Don't know, and refused across the row 
ipaanycount $all_num, gen(na_count) numval(.a)
ipaanycount $all_dk, gen(dk_count) numval(.d)
ipaanycount $all_num, gen(rf_count) numval(.r)

* Count of total true missing 
egen all_missing_count = rowmiss($all_num)
gen missing_count = all_missing_count  - (na_count + dk_count + rf_count)

* Denominator for percent of NA and Refused 
egen nonmissing_count = rownonmiss($all_num)
gen total = all_missing_count + nonmissing_count

* Denominator for percent of Don't know 
egen dk_nonmiss_count = rownonmiss($all_dk) 
egen dk_miss_count = rowmiss($all_dk) 
gen total_dk = dk_nonmiss_count + dk_miss_count 


preserve

collapse (sum) na_count dk_count rf_count missing_count total total_dk, by(Country)
gen na_perc = na_count/total
gen dk_perc = dk_count/total_dk
gen rf_perc = rf_count/total 
gen miss_perc = missing_count/total 
lab var na_perc "NA (%)" 
lab var dk_perc "Don't know (%)"
lab var rf_perc "Refused (%)"
lab var miss_perc "Missing (%)"
export exc Country na_perc dk_perc rf_perc miss_perc using "$dq_output", sh(missing, replace) first(varl)

restore 

* Other options 
* misstable summarize Q28_A
