
/*create 2018 dataset for regression: mobile money women empowerment child health*/
/*Author: Masanori Matsuura*/
clear all
set more off
*set the pathes

global BIHS18Community = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Community"
global BIHS18Female = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Female"
global BIHS18Male = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Male"
global BIHS15 = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2015"

*BIHS2018 data cleaning 
**keep geographical code
use $BIHS18Male\r3_male_mod_a_001, clear //
merge 1:1 a01 using $BIHS18Male\009_bihs_r3_male_mod_a.dta, nogen force
drop if community_id==.
//rename (district upazila union village) (dcode Upazila Union Village)
keep a01 div dvcode dcode Upazila Union Village community_id
destring Union, gen(uncode)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
save 2018, replace

** HH composition, HH with husband and wife
use $BIHS18Male\010_bihs_r3_male_mod_b1.dta, clear
bysort a01: egen size=count(a01) if b1_03==3
bysort a01: egen ch_size=max(size)
replace ch_size=0 if ch_size==.
label var ch_size "Number of children"
keep if mid==1 | mid==2
keep if b1_03==1 | b1_03==2
keep if b1_04==2 
keep if b1_03==2 & b1_01==2
gen couple=1
rename (b1_02 b1_08) (age_w edu_w)
recode edu_w(99=0 "Non-schooling") (22=5)(33=9)(66=0 "Non-schooling")(67=0 "Non-schooling")(74=16)(76=.)(99=0 "Non-schooling"), gen(schll_w) // convert  education into schoolling year 
label var age_w "Age of women"
label var schll_w "Schooling year of women"
recode b1_07 (4=1 "yes") (nonm=0 "No" ), gen(lit_w)
label var lit_w "Literacy of women"

keep a01 couple ch_size edu_w schll_w lit_w age_w 
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
save hh18.dta, replace

** female labor force participation
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep if mid==2
recode c05 (81/999=0 "No") (nonm=1 "Yes"), gen(wrk_wf)
label var wrk_wf "Current working status of wife"

*** extensive margin: probability of working
recode c05 (1 6=1 "Yes") (nonm=0 "No"), gen(csw_awrk) //extensive margin
label var csw_awrk "Casual wage employment (agriculture)"
recode c05 (2/5 7/11=1 "Yes")(nonm=0 "No"), gen(csw_nawrk)
label var csw_nawrk "Casual wage employment (non-agriculture)"
recode c05 (12/21=1 "Yes")(nonm=0 "No"), gen(slr_emp)
label var slr_emp "Salaried employment"
recode c05 (22/47=1 "Yes")(nonm=0 "No"), gen(slf_emp)
label var slf_emp "Self-employment"
recode c05 (50/57=1 "Yes")(nonm=0 "No"), gen(trdprd_emp)
label var slf_emp "Trader/production business"
recode c05 (2/5  7/57=1 "Yes")(nonm=0 "No"), gen(off_emp)
label var off_emp "Off-farm employment"

foreach labor in csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp {
	 bysort a01: egen mx_`labor' = max(`labor')
	 bysort a01: replace `labor' = mx_`labor'
	 bysort a01: replace `labor' = 0 if `labor'==.
	 drop mx_`labor'
}

*** intensive margin: working hour
gen csw_ah=c08 if csw_awrk==1 //intensive margin
replace csw_ah=0 if csw_awrk==0 
label var csw_ah "Casual wage employment (agriculture)"

gen csw_nah=c08 if csw_nawrk==1 //intensive margin
replace csw_nah=0 if csw_nawrk==0 
label var csw_nah "Casual wage employment (non-agriculture)"

gen slr_h=c08 if slr_emp==1 
replace slr_h=0 if slr_emp==0 
label var slr_h "Salaried employment"

gen slf_h=c08 if slf_emp==1 
replace slf_h=0 if slf_emp==0 
label var slf_h "Self-employment"

gen trdprd_h=c08 if trdprd_emp==1 
replace trdprd_h=0 if trdprd_emp==0 
label var trdprd_h "Trader/production business"

gen off_h=c08 if off_emp==1 
replace off_h=0 if off_emp==0 
label var off_h "Off-farm employment"

foreach labor in csw_ah csw_nah slr_h slf_h trdprd_h off_h {
	bysort a01: egen mx_`labor' = total(`labor')
	bysort a01: replace `labor' = mx_`labor'
	drop mx_`labor'
}

*** income of working 
gen csw_ai=c14 if csw_awrk==1 
replace csw_ai=0 if csw_awrk==0 
label var csw_ai "Casual wage employment (agriculture)"

gen csw_nai=c14 if csw_nawrk==1 
replace csw_nai=0 if csw_nawrk==0 
label var csw_nai "Casual wage employment (non-agriculture)"

gen slr_i=c14 if slr_emp==1 
replace slr_i=0 if slr_emp==0 
label var slr_i "Salaried employment"

gen slf_i=c14 if slf_emp==1 
replace slf_i=0 if slf_emp==0 
label var slf_i "Self-employment"

gen trdprd_i=c14 if trdprd_emp==1 
replace trdprd_i=0 if trdprd_emp==0 
label var trdprd_i "Trader/production business"

gen off_i=c14 if off_emp==1 
replace off_i=0 if off_emp==0 
label var off_i "Off-farm employment"

foreach labor in csw_ai csw_nai slr_i slf_i trdprd_i off_i {
	bysort a01: egen mx_`labor' = total(`labor')
	bysort a01: replace `labor' = mx_`labor'
	drop mx_`labor'
}

keep a01 csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp csw_ah csw_nah slr_h slf_h trdprd_h off_h csw_ai csw_nai slr_i slf_i trdprd_i off_i

duplicates drop a01 csw_awrk csw_nawrk slr_emp slf_emp off_emp csw_ah csw_nah slr_h slf_h off_h csw_ai csw_nai slr_i slf_i off_i, force

gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
save fl18.dta, replace

** village level mobile agency
use $BIHS18Community\142_r3_com_mod_cb_1, clear
keep if cb01==7 
rename (cb03 cb04) (magency magency_n)
replace magency_n=0 if magency_n==.
replace magency=0 if magency==2
label var magency "Mobile agency in a community"
label var magency_n "Number of mobile agency in a community"
merge 1:1 community_id using $BIHS18Community\140_r3_com_mod_ca_1, nogen 
keep community_id magency magency_n
save com18, replace

** mobile phone ownership
use $BIHS18Male\015_bihs_r3_male_mod_d1, clear //household ownership
keep if d1_02==24
recode d1_03 (1=1 "yes")(nonm=0 "no"), gen(mobile)
rename d1_04 mobile_q
label var mobile_q "Mobile phone ownership (quantity)"
keep a01 mobile mobile_q
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save mobile18, replace

**Women's mobile phone ownership
use $BIHS18Male\015_bihs_r3_male_mod_d1, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
merge 1:1 a01 mid using $BIHS18Male\010_bihs_r3_male_mod_b1, nogen
gen wmobile=1 if b1_01==2 & d1_03==1
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile
tempfile wm1
save `wm1'

use $BIHS18Male\015_bihs_r3_male_mod_d1, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_b mid
merge 1:1 a01 mid using $BIHS18Male\010_bihs_r3_male_mod_b1, nogen
gen wmobile=1 if b1_01==2 & d1_03==1
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile
append using `wm1'

save wm218.dta, replace

use $BIHS18Male\015_bihs_r3_male_mod_d1, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_c mid
merge 1:1 a01 mid using $BIHS18Male\010_bihs_r3_male_mod_b1, nogen
gen wmobile=1 if b1_01==2 & d1_03==1
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile

append using wm218

bysort a01: egen wmob=total(wmobile)
recode wmob (0=0 "No")(nonm=1 "Yes" ), gen(wm)
label var wm "Women's mobile ownership"

duplicates drop a01, force

save wm18.dta, replace

** Intimate partner violence
use $BIHS18Female\124_bihs_r3_female_mod_z4, clear
drop if z4_consent==.
keep if z4_mid==2
recode z4_02 (.=0 "No")(nonm=1 "Yes"), gen(vlnc)
label var vlnc "Any violence"
recode z4_01a (1 2=1 "Yes")(nonm=0 "No"), gen(em_vlnc)
replace em_vlnc=1 if z4_01b==1 | z4_01b==2 | z4_01c1==1 | z4_01c2==1 | z4_01c3==1 | z4_01c1==2 | z4_01c2==2 | z4_01c3==2
label var em_vlnc "Emotional violence"
recode z4_01d1 (1 2=1 "Yes")(nonm=0 "No"), gen(py_vlnc)
replace py_vlnc=1 if z4_01d2==1 | z4_01d3==1 | z4_01d1==2 | z4_01d2==2 | z4_01d3==2
label var py_vlnc "Physical violence"
keep a01 vlnc em_vlnc py_vlnc
save vlnc18.dta, replace


** Contraceptive use
use $BIHS18Female\123_bihs_r3_female_mod_z3, clear
keep if z3_mid==2
recode z3_01 (1=1 "Yes")(2=0 "No"), gen(brth_cntrl)
label var brth_cntrl "Use contraceptive"
keep a01 brth_cntrl
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save cntr18.dta, replace

** income for women


** asset brought to marriage
use $BIHS18Female\125_bihs_r3_female_mod_z5, clear
rename z5_01 masst
label var masst "Asset brought to marriage"
replace masst=0 if masst==2
keep a01 masst
duplicates drop a01 masst, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save masst18.dta, replace

** credit access
use $BIHS18Female\132_bihs_r3_female_weai_ind_mod_we4, clear
recode we4_08d (1=1 "Yes")(2=0 "No"), gen(w_crdt)
label var w_crdt "Women's access to credit"
replace w_crdt=0 if w_crdt==.
keep a01 w_crdt
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save wcrdt18.dta, replace

** migrant status
use $BIHS18Male\072_bihs_r3_male_mod_v1, clear //if any members are migrants
recode v1_01 (1=1 "Yes")(2=0 "No"), gen(migrant)
keep a01 migrant
label var migrant "Member migration (1/0)"
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save migrant18, replace

**mobile money
use $BIHS18Male\063_bihs_r3_male_mod_q.dta, clear
recode q_20d_1 (1/5=1)(nonm=0), gen(mm_1)
recode q_20d_2 (1/5=1)(nonm=0), gen(mm_2)
recode q_20d_3 (1/5=1)(nonm=0), gen(mm_3)
keep if mm_1==1 | mm_2==1 | mm_3==1
gen mm_o=1
label var mm_o "Mobile money user"
keep a01 mm_o
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save mm_o18.dta, replace

*mobile money
use $BIHS18Female\138_bihs_r3_female_weai_ind_mod_we7b, clear
keep if we7b_13_1==2 | we7b_13_1==3 | we7b_13_1==4 | we7b_13_2==2 | we7b_13_2==3 | we7b_13_2==4 | we7b_13_3==2 | we7b_13_3==3 | we7b_13_3==4
gen mm_p=1
label var mm_p "Mobile momey user"
keep a01 mm_p
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save mm18.dta, replace

** energy poverty
use $BIHS18Male\061_bihs_r3_male_mod_p1, clear
keep if p1_01==1 | p1_01==2 | p1_01==3 | p1_01==4 | p1_01==5 | p1_01==6 |p1_01==7 | p1_01==8 | p1_01==9 | p1_01==36 | p1_01==37 | p1_01==38 | p1_01==46 | p1_01==47 
egen enex_i=rowtotal(p1_02 p1_04)
bysort a01: egen enex=sum(enex_i)
egen elcex_i=rowtotal(p1_02 p1_04) if p1_01==7 | p1_01==47 | p1_01==46
bysort a01:egen elcex=sum(elcex_i)
egen gasex_i=rowtotal(p1_02 p1_04) if p1_01==6
bysort a01: egen gasex=sum(gasex_i)
egen nonex_i=rowtotal(p1_02 p1_04) if p1_01==1 | p1_01==2 | p1_01==3 | p1_01==4 | p1_01==8 | p1_01==9
bysort a01: egen nonex=sum(nonex_i)
recode elcex (0=0) (nonm=1), gen(dum_el)
recode gasex (0=0) (nonm=1), gen(dum_gas)
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
keep a01 elcex enex gasex nonex dum_el dum_gas
save ene18, replace

**cooking fuel
use $BIHS18Male\063_bihs_r3_male_mod_q, clear
recode q_16 (1/3=1)(nonm=0),gen(clean)
label var clean "Clean fuels"
keep a01 clean
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save ckng18, replace

**poverty indicators
use $BIHS18Male\hhexpenditure_R3, clear // poverty status and depth (gap)
merge 1:1 a01 using $BIHS18Male\mpi_R3, nogen //multidimentional poverty index
keep a01 pcexp_da p190hcgcpi p190hcfcpi p320hcgcpi p320hcfcpi pov190gapgcpi deppov190gcpi pov190gapfcpi deppov190fcpi pov320gapgcpi pov320gapfcpi deppov320fcpi deppov320gcpi hc_mpi mpiscore
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
save poverty18.dta, replace

** keep age gender education occupation of HH
use $BIHS18Male\010_bihs_r3_male_mod_b1.dta, clear
bysort a01: egen hh_size=count(a01)
label var hh_size "Household size"
bysort a01: egen ch_size_i=count(a01) if b1_02 < 19
bysort a01: egen ch_size=max(ch_size_i)
label var ch_size "Number of children"
bysort a01: egen ad_size=count(a01) if b1_02 > 18
label var ad_size "Number of adult"
keep if b1_03==1 
keep a01 mid b1_01 b1_02 b1_04 b1_04a b1_08 b1_10 b1_13a b1_13b hh_size ad_size
rename (b1_01 b1_02 b1_04 b1_04a b1_08  b1_13a b1_13b)(gender_hh age_hh marital_hh age_marital_hh edu_hh main_earning_1 main_earning_2)
recode edu_hh(99=0 "Non-schooling") (22=5)(33=9)(66=0 "Non-schooling")(67=0 "Non-schooling")(74=16)(76=.)(99=0 "Non-schooling"), gen(schll_hh) // convert  education into schoolling year 
label var age_hh "Age of HH"
label var schll_hh "Schooling year of HH"
recode gender_hh (1=1 "Man")(2=0 "Woman"), gen(Male)
label var Male "Male(=1)"
recode b1_10 (1/72=1 "Yes")(nonm=0 "No"), gen(wrk_hs)
label var wrk_hs "Current working status of husband"
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
save sciec18.dta, replace

**Asset index
use $BIHS18Male\015_bihs_r3_male_mod_d1, clear  
keep a01 d1_02 d1_03
drop if d1_02==24
reshape wide d1_03,i(a01) j(d1_02)
local varlist "d1_031 d1_032 d1_033 d1_034 d1_035 d1_036 d1_037 d1_038 d1_039 d1_0310 d1_0311 d1_0312 d1_0313 d1_0314 d1_0315 d1_0316 d1_0317 d1_0318 d1_0319 d1_0320 d1_0321 d1_0322 d1_0323 d1_0325 d1_0326 d1_0327 d1_0328 d1_0329 d1_0330 d1_0331 d1_0332 d1_0333 d1_0334 d1_0335 d1_0336 d1_0337 d1_0338 d1_0339 d1_0340 d1_0341 d1_0342 d1_0343 d1_0344 d1_0345 d1_0346 d1_0347 d1_0348 d1_0349 d1_0350 d1_03131 d1_03161 d1_03401 d1_03402 d1_03402 d1_03511 d1_03512 d1_03513" //d1_0324 mobile phone
foreach x in `varlist'{
	replace `x'=0 if `x'==2
	replace `x'=0 if `x'==.
}
pca `varlist'
predict asset
keep a01 asset
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save asset18.dta, replace

**keep agronomic variables
use $BIHS18Male\020_bihs_r3_male_mod_g, clear
keep if g01==2
bysort a01: egen farmsize=total(g02) 
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
duplicates drop a01 farmsize, force
keep a01 farmsize ln_farm
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save agrnmic18.dta, replace

**saving
use $BIHS18Male\017_bihs_r3_male_mod_e.dta, clear
replace e06=0 if e06==.
bysort a01: egen saving=sum(e06)
keep a01 saving 
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save save18.dta, replace

**non-earned income
use $BIHS18Male\076_bihs_r3_male_mod_v4, clear
drop hh_type
bysort a01: gen nnearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12
label var nnearn "Non-earned income"
keep a01 nnearn
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save nnrn18.dta, replace //non-earned  income

**Social safety net program
use $BIHS18Male\070_bihs_r3_male_mod_u.dta, replace
bysort a01: gen trsfr=sum(u02)
label var trsfr "Social safety net program transfer"
keep a01 trsfr
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save ssnp18.dta, replace

**remittance
use $BIHS18Male\073_bihs_r3_male_mod_v2, clear
replace v2_06=0 if v2_06==.
bysort a01: egen remi=sum(v2_06) //if v2_07==10 //total
bysort a01: egen remi_dom=sum(v2_06) if v2_03!=. //v2_07==10 & Domestic
bysort a01: egen remi_for=sum(v2_06) if v2_04!=. //v2_07==10 &Foereign remittance

bysort a01: egen remi_n=sum(v2_05) //if v2_07==10
label var remi_n "Frequency of remittance"
duplicates drop a01, force
label var remi "Value of remittance"
label var remi_dom "Value of domestic remittance"
label var remi_for "Value of foreign remittance"

gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
keep a01 remi remi_n remi_dom remi_for
duplicates drop a01, force
save rem18.dta, replace

**social network
use  $BIHS18Female\120_bihs_r3_female_mod_y8, clear
recode y8_06 (1=1 "Yes")(2=0 "No")(.=0 "No"),gen(network)
keep a01 network
label var network "Social network (discussion)"
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
save network18.dta, replace

**market access 
use $BIHS18Male\058_bihs_r3_male_mod_m1, clear //Marketing of Paddy, Rice, Banana, Mango, and Potato
keep a01 m1_16 m1_18
recode m1_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp1)
keep a01 marketp1
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save marketstaple18.dta, replace

use $BIHS18Male\059_bihs_r3_male_mod_m2, clear //Marketing of Livestock, Jute, Wheat, Pulses, Fish, Fruits, Vegetable
keep a01 m2_16 m2_18
recode m2_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(0 .=0 "No"), gen(marketp2)
keep a01 marketp2
duplicates drop a01, force 
merge 1:1 a01 using marketstaple18, nogen
gen mrkt=marketp1+marketp2
recode mrkt (1/max=1 "yes")(0=0 "no")(.= 0 "no"), gen(marketp)
keep a01 marketp
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force 
save mrkt18, replace

**agricultural production cost

use $BIHS18Male\021_bihs_r3_male_mod_h1, clear //seed cost
egen sc_i=rowtotal(h1_07 h1_08), missing
bysort a01: egen sc=sum(sc_i)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
keep a01 sc
duplicates drop a01, force
tempfile sc18
save `sc18'
use $BIHS18Male\022_bihs_r3_male_mod_h2, clear //irrigation cost
bysort a01: egen ic=sum(h2_05)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
keep a01 ic
tempfile ic18
duplicates drop a01, force
save `ic18'

use $BIHS18Male\024_bihs_r3_male_mod_h4, clear //machinery cost
gen ac=h4_01*h4_02
egen mc_i=rowtotal(h4_04_1 h4_04_2 h4_04_3 h4_05_1 h4_05_2 h4_06 h4_07 h4_08 h4_09 h4_10 ac), missing
bysort a01: egen mc=sum(mc_i)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
keep a01 mc
duplicates drop a01, force
tempfile mc18
save `mc18'

use $BIHS18Male\025_bihs_r3_male_mod_h5, clear //labor cost
egen lc_i=rowtotal(h5_04 h5_06 h5_10 h5_12 h5_22 h5_24 h5_28 h5_30 h5_34 h5_36 h5_40 h5_42 h5_46 h5_48), missing
bysort a01: egen lc=sum(lc_i)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
keep a01 lc
duplicates drop a01, force
tempfile lc18
save `lc18'

use $BIHS18Male\026_bihs_r3_male_mod_h6, clear //post-labor cost
egen plc_i=rowtotal(h6_04 h6_06 h6_08 h6_13 h6_15 h6_19 h6_21 h6_25 h6_27 h6_31 h6_33), missing
bysort a01: egen plc=sum(plc_i)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
keep a01 plc
tempfile plc18
save `plc18'

use $BIHS18Male\050_bihs_r3_male_mod_k3, clear //livestock cost
egen lvc_i=rowtotal(k3_03 k3_07 k3_09), missing
bysort a01: egen lvc=sum(lvc_i)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
keep a01 lvc
duplicates drop a01, force
tempfile lvc18
save `lvc18'

use $BIHS18Male\051_bihs_r3_male_mod_l1, clear //fishery cost
bysort a01: egen fc=sum(l1_09)
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
keep a01 fc
duplicates drop a01, force
tempfile fc18
save `fc18'

**access to facility
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_04 s_06
keep if s_01==3 
drop s_01
rename s_06 road
rename s_04 road_d
label var road "Road access (minute)"
tempfile cal
save `cal'
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_04 s_06
keep if s_01==6
drop s_01
rename s_06 market
rename s_04 market_d
label var market "Market access (minute)"
merge 1:1 a01 using `cal', nogen
save facility18, replace
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_04 s_06
keep if s_01==7 
drop s_01
rename s_06 town
rename s_04 town_d
label var town "Distance to near town (minute)"
tempfile town
save `town'
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_04 s_06
keep if s_01==9 
drop s_01
rename s_06 agri
rename s_04 agri_d
label var agri "Agricultural office (minute)"
merge 1:1 a01 using facility18, nogen
merge 1:1 a01 using `town', nogen
save facility18, replace
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_04 s_06
keep if s_01==6
drop s_01
rename s_06 bazaar
rename s_04 bazaar_d
label var bazaar "Periodic bazaar access (minute)"
merge 1:1 a01 using facility18, nogen
save facility18, replace
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_04 s_06
keep if s_01==5
drop s_01
rename s_06 shop
rename s_04 shop_d
label var shop "Local shop access (minute)"
merge 1:1 a01 using facility18, nogen
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save facility18, replace


**keep livestock variables
use $BIHS18Male\043_bihs_r3_male_mod_k1, clear //animal
bysort a01: gen livstck=sum(k1_04)
recode livstck (1/max=1 "yes")(0=0 "no")(.=0 "no"),gen(lvstck)
label var lvstck "Livestock ownership(=1)"
keep a01 livestock k1_18 lvstck
save lvstck18.dta, replace
keep a01 lvstck
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save lvstckown18.dta, replace //ownership

/*Livestock product*/
use $BIHS18Male\049_bihs_r3_male_mod_k2, clear //milk and egg
keep a01 k2_12 bprod
rename bprod livestock
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save lvstckpr18.dta, replace //livestock product

/*create livestock income*/
use lvstck18, clear 
rename k1_18 k2_12 //rename livestock income
keep a01 k2_12 livestock
append using lvstckpr18.dta

save eli18, replace //save a file for farm diversification index

bysort a01: egen ttllvstck=sum(k2_12) // livestock product income
label var ttllvstck "Livestock income"
drop k2_12
duplicates drop a01, force
save lvinc18.dta, replace
use lvstckown18.dta, clear //merge currently ownership and livestock income
merge 1:1 a01 using lvinc18, nogen

save lvstckinc18.dta, replace

**livestock diversification
use $BIHS18Male\043_bihs_r3_male_mod_k1, clear 
drop if k1_04==0
bysort a01: egen livdiv=count(livestock)
keep a01 livdiv
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
save livdiv18.dta, replace

*fishery income
use $BIHS18Male\052_bihs_r3_male_mod_l2.dta, clear
bysort a01:egen fshinc=sum(l2_12)
bysort a01:egen fshdiv=count(l2_01)
keep a01 fshdiv fshinc
label var fshdiv "fish diversification"
label var fshinc "fishery income"
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save fsh18.dta, replace

**keep Non-farm self employment
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep a01 c05 c09 c14
keep if c09 == 3 //keep self employed
bysort a01: egen offsel=sum(c14)
gen offself=12*offsel
keep a01 offself
label var offself "Non-farm self employment"
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save nnfrminc18.dta, replace

**Non-farm employment 
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep a01 c05 c09 c14
keep if c09 != 3 //keep salary and wage
drop if c05== 1 //drop farm wage
gen yc14=12*c14
bysort a01: egen offrminc=sum(yc14)
label var offrminc "Non-farm wage and salary"
keep a01 offrminc
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save offfrm18.dta, replace

**farm wage
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep if c05== 1
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen frmwag=sum(c14) 
gen frmwage =12*frmwag
keep a01 frmwage
label var frmwage "Farm wage"
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save frmwage18.dta, replace

*Non-agricultural enterprise
use $BIHS18Male\060_bihs_r3_male_mod_n, clear
bysort a01: egen nnagent=sum(n05)
label var nnagent "non-agricultural enterprise"
keep a01 nnagent
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save nnagent18.dta, replace

*food consumption
use $BIHS18Female\096_bihs_r3_female_mod_o1.dta, clear
recode o1_01 (1/16 277/290 297 901 296 302 =1 "Cereals")(61 62 621 622 295 301 3231 3232=2 "White tubers and roots")(41/60 63/82 86/115 904 905 291 292 298 441=3 "Vegetables")(141/170 317 319 907=4 "Fruits")(121/129 906 322 =5 "Meat")(130/135 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 902 299=8 "Legumes, nuts and seeds")(132/135 1321/1323 2941/2943 294=9 "Milk and milk products")(31/36 903 312 =10 "Oils and fats")(266/271 293 303/311=11 "Sweets")(246/251 253/264 272/276 318 323 910 300 314/321 2521 2522 252 313= 12 "Spices, condiments and beverages"), gen(hdds_i)
drop if o1_01==2524
duplicates drop a01 hdds_i, force
bysort a01: egen hdds=count(a01)
drop hdds_i
label var hdds "Household Dietary Diversity"
duplicates drop a01, force
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
save fd18.dta, replace

**Consumption expenditure
use BIHS_hh_variables_r123, clear
keep if round==3
keep a01 pc_expm_d pc_foodxm_d pc_nonfxm_d
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
save expend18.dta, replace

**human capital
use $BIHS18Male\062_bihs_r3_male_mod_p2, clear
keep if p2_01>139
keep if p2_01<156
bysort a01: gen med=sum(p2_03) if p2_01<148
bysort a01: gen fed=sum(p2_03) if p2_01>147
bysort a01: gen ed=sum(p2_03)
bysort a01: egen medu=max(med)
bysort a01: egen fedu=max(fed)
bysort a01: egen edu=max(ed)
label var medu "Male educational expenses"
label var fedu "Female educational expenses"
label variable edu "Educational expenses"
keep a01 fedu medu edu
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save edu18, replace

**health expenditure
use $BIHS18Male\062_bihs_r3_male_mod_p2, clear
keep if p2_01>116
keep if p2_01<140
bysort a01: gen mhl=sum(p2_03) if p2_01<128
bysort a01: gen fhl=sum(p2_03) if p2_01>127
bysort a01: gen hl=sum(p2_03)
bysort a01: egen mhlth=max(mhl)
bysort a01: egen fhlth=max(fhl)
bysort a01: egen hlth=max(hl)
label var mhlth "Male educational expenses"
label var fhlth "Female educational expenses"
label variable hlth "Educational expenses"
keep a01 mhlth fhlth hlth
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save hlth18, replace

**leisure expenditure
use $BIHS18Male\062_bihs_r3_male_mod_p2, clear
keep if p2_01>167
keep if p2_01<178
bysort a01: gen leisur=sum(p2_03)
bysort a01: egen leisure=max(leisur)
label variable leisure "Leisure expenditure"
keep a01 leisure
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save leisure18, replace

**Idiosyncratic shocks
use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
keep if t1b_03==1
keep if t1b_01==9 
rename t1b_02 cropflood
duplicates drop a01, force
tempfile crpfld
save `crpfld'
use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
keep if t1b_03==1
keep if t1b_01==11 
rename t1b_02 lvstckflood
merge 1:1 a01 using `crpfld', nogen
tempfile lvsfld
save `lvsfld'
use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
keep if t1b_03==1
keep if t1b_01==14
rename t1b_02 prdflood
duplicates drop a01, force
merge 1:1 a01 using `lvsfld', nogen
tempfile prdfld
save `prdfld'
use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
keep if t1b_03==1
keep if t1b_01==16 
rename t1b_02 cnsmpflood
duplicates drop a01, force
merge 1:1 a01 using `prdfld', nogen
tempfile cnsfld
save `cnsfld'

use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
keep if t1b_03==1
keep if t1b_01==101 
rename t1b_02 crpcyc
duplicates drop a01, force
merge 1:1 a01 using `cnsfld', nogen
tempfile crpcyc
save `crpcyc'

use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
keep if t1b_03==1
keep if t1b_01==111
rename t1b_02 lvcyc
merge 1:1 a01 using `crpcyc', nogen
gen shock=1
tempfile shock
save `shock'
use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
keep if t1b_03==1
rename t1b_02 e_shock
label var e_shock "Negative economic shock"
duplicates drop a01, force
merge 1:1 a01 using `shock', nogen
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
keep a01 shock e_shock
label var shock "Shock"
save shock18.dta, replace


**Income diversification
use crpincm18.dta, clear
merge 1:1 a01 using nnrn18.dta, nogen
merge 1:1 a01 using ssnp18.dta, nogen
merge 1:1 a01 using lvstckinc18.dta, nogen
merge 1:1 a01 using offfrm18.dta, nogen
merge 1:1 a01 using fsh18.dta, nogen
merge 1:1 a01 using nnagent18.dta, nogen
merge 1:1 a01 using rem18.dta, nogen
merge 1:1 a01 using frmwage18.dta, nogen
merge 1:1 a01 using nnfrminc18.dta, nogen
drop dstnc_sll_ trnsctn lvstck fshdiv
replace crp_vl=0 if crp_vl==.
replace offrminc=0 if offrminc==.
replace nnearn=0 if nnearn==.
replace fshinc=0 if fshinc==.
replace ttllvstck=0 if ttllvstck==.
replace remi=0 if remi==.
replace nnagent=0 if nnagent==.
replace frmwage=0 if frmwage==.
replace offself=0 if offself==.
replace trsfr=0 if trsfr==.
gen ttinc= crp_vl+nnearn+trsfr+ttllvstck+offrminc+fshinc+nnagent+remi+frmwage+offself //total income
gen aginc=ttllvstck+crp_vl+fshinc
gen nonself=offself //off-farm self
gen nonwage=offrminc //off-farm wage
gen nonearn=remi+trsfr+nnearn //non-earned 
gen i1=(aginc/ttinc)^2
gen i2=(frmwage/ttinc)^2
gen i3=(nonself/ttinc)^2
gen i4=(nonwage/ttinc)^2
gen i5=(nonearn/ttinc)^2
gen es=i1+i2+i3+i4+i5
gen inc_div=1-es
label var inc_div "Income diversification index" //simpson
gen p1=(aginc/ttinc)
gen p2=(frmwage/ttinc)
gen p3=(nonself/ttinc)
gen p4=(nonwage/ttinc)
gen p5=(nonearn/ttinc)
gen lnp1=log(p1)
gen lnp2=log(p2)
gen lnp3=log(p3)
gen lnp4=log(p4)
gen lnp5=log(p5)
gen shn1=p1*lnp1
gen shn2=p2*lnp2
gen shn3=p3*lnp3
gen shn4=p4*lnp4
gen shn5=p5*lnp5
egen shnni = rowtotal(shn1 shn2 shn3 shn4 shn5)
gen shni=-1*(shnni) //shannon
keep a01 inc_div shni aginc frmwage nonself nonwage nonearn ttinc // crp_vl nnearn trsfr ttllvstck offrminc fshinc nnagent
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<=.11
replace ext=2 if diff>.11
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
drop ext diff
duplicates report a01
duplicates drop a01, force
save incdiv18.dta, replace

**merge all 2018 dataset
use 2018.dta,clear
merge 1:1 a01 using hh18, nogen
merge 1:1 a01 using sciec18, nogen
merge 1:1 a01 using agrnmic18, nogen
merge 1:1 a01 using nnrn18, nogen
merge 1:1 a01 using shock18.dta, nogen
merge 1:1 a01 using lvstckinc18.dta,nogen
merge 1:1 a01 using crpincm18,nogen
merge 1:1 a01 using offfrm18.dta,nogen
merge 1:1 a01 using ssnp18,nogen
merge 1:1 a01 using nnfrminc18,nogen
merge 1:1 a01 using ssnp18,nogen
merge 1:1 a01 using nnfrminc18,nogen
merge 1:1 a01 using crp18,nogen
merge 1:1 a01 using irri18, nogen
merge 1:1 a01 using incdiv18, nogen
merge 1:1 a01 using fd18.dta, nogen
merge 1:1 a01 using expend18, nogen
merge 1:1 a01 using frm_div18, nogen
merge 1:1 a01 using mrkt18, nogen
merge 1:1 a01 using facility18, nogen
merge 1:1 a01 using mobile18, nogen
merge 1:1 a01 using poverty18, nogen
merge 1:1 a01 using migrant18, nogen
merge 1:1 a01 using asset18, nogen
merge 1:1 a01 using rem18, nogen
merge 1:1 a01 using mm18, nogen
merge 1:1 a01 using save18, nogen
merge 1:1 a01 using network18, nogen
merge 1:1 a01 using edu18, nogen
merge 1:1 a01 using hlth18, nogen
merge 1:1 a01 using leisure18, nogen
merge 1:1 a01 using mm_o18, nogen
merge 1:1 a01 using ene18, nogen
merge 1:1 a01 using ckng18, nogen
merge 1:1 a01 using wm18, nogen
merge 1:1 a01 using wei_r3, nogen
merge 1:1 a01 using `sc18', nogen
merge 1:1 a01 using `ic18', nogen
merge 1:1 a01 using `mc18', nogen
merge 1:1 a01 using `lc18', nogen
merge 1:1 a01 using `plc18', nogen
merge 1:1 a01 using `lvc18', nogen
merge 1:1 a01 using `fc18', nogen
merge 1:1 a01 using wcrdt18.dta, nogen
merge 1:1 a01 using vlnc18.dta, nogen
merge 1:1 a01 using cntr18.dta, nogen
merge 1:1 a01 using masst18.dta, nogen
merge 1:1 a01 using fl18.dta, nogen
merge m:m community_id using com18, nogen force

label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)
gen year=2018
foreach m in remi saving mhlth fhlth hlth edu fedu medu leisure ttinc enex elcex gasex nonex sc ic mc lc plc lvc fc remi_dom remi_for {
	gen `m'_d=(74.15*`m')/83.47
}
drop if dvcode==.
egen agcost=rowtotal(sc ic mc lc plc lvc fc), missing
label var agcost "Agricultural cost"
drop if couple==.
save 2018.dta, replace

