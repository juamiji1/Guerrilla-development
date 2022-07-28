# Project: Rebel Governance and Development - The Long-Term Effects of Guerrillas in El Salvador

**Name**:  Juan Miguel Jimenez R. 

**Contact information**: juamiji@gmail.com

## What is the project?
How does territorial control by armed non-state actors affect long-term development? We investigate the economic, social, and political consequences of territorial control by guerrillas during the Salvadoran Civil War.  During their territorial control, guerrillas displaced state authorities and large landowners, and promoted the creation of self-governing institutions. Using a regression discontinuity design, we show that areas exposed to guerrilla control have experienced worse economic outcomes over the last 20 years relative to areas outside these locations that were under the control of the formal state.  Our results reveal that  informal participatory institutions in guerrilla controlled areas led to a fragmentation of the economy and high distrust towards the state and agriculture elites that persists today.

## Set-up
To replicate this project, you will need to have Stata-16, R-studio, GitHub, and access to Dropbox. 

### Dropbox
The main folders that I used are

| Path | Description |
| ---- | ----------- |
| `/Guerillas_Development/2-Data/Salvador` | Has all the data used in this project | 
| `/Guerillas_Development/5-Maps/Salvador` | Has all the original scans of the historical maps used | 
| `/Github/Guerrilla-development/code` | Has all code used in this project |

### Overleaf
The project is in https://www.overleaf.com/project/5f8763745e763500015502bf . The `3.Revised Draft_SR_2.tex` file has the latest version of the paper. The `all_elev.tex` has all unproccessed figures and tables. 

| Path | Description |
| ---- | ----------- |
| `/plots` | Has all plots used in the draft | 
| `/tables` | Has all tables used in the draft | 

## What are the steps taken to conduct this work?
The steps to replicate all my work can be viewed in the master do-file of the project (`C:/Github/Guerrilla-development/code/FV_0_master.do`) which lists all do-files and R scripts, but also allows you to follow the pipeline. However, I ***do not*** recommend to run it entirely since this project is data intensive.

Note: Before start working please ***do not forget*** to pull from the origin to your local machine.

### Code folder explanation
All final codes that were used to the latest version of the draft has the `FV_` prefix (Final Version). Results whose codes do not start with `FV_` weren't included in the latest draft. The structure of the pipeline inside `FV_0_master.do` is as follows 

| Prefix | Description |
| ---- | ----------- |
| `FV_0_` |  `FV_0_master.do` allows you to replicate the project | 
| `FV_1_` | Files with this prefix clean and prepare the raw data |
| `FV_2_` | Files with this prefix make the estimations | 
| `FV_3_` | Files with this prefix make maps or other tasks related with the survey | 

Other files and folders in this location are
- `/Github/Guerrilla-development/2_analysis/version_elev` : Has a version of the final code in which we control by elevation or restrict the sample to census tracts above 200 masl.
- `/Github/Guerrilla-development/code/0_archive` : This folder contains old codes from previous versions of the article (we didn't know what to do at that point).  

### Code source for tables - Guide
Below we can find what do-file has the raw table for each result included in the latest draft.

| File | Table(s) that it makes |
| ---- | ----------- |
| `FV_2_rdd_lc_all.do` | Smooth condition test - Comparison of Baseline Characteristics Between Census Tracts In and Out the RD-Sample |
| `FV_2_rdd_main_all.do` | Effects of Guerrilla Territorial Control on
Night Light Luminosity, Wealth, and Human Capital - Effects of Guerrilla Territorial Control on Other Transformations of Night Light Luminosity|
| `FV_2_rdd_nltime_all.do` | Effects of Guerrilla Control on the Arcsine of Night Light Luminosity Over Time |
| `FV_2_rdd_educ_trimm_all.do` | Accounting for selective in-migration |
| `FV_2_rdd_trust_all.do` |  Effects of Guerrilla Territorial Control on Attitudes towards the Government |
| `FV_2_rdd_trust_rdsample_all.do` |  Effects of Guerrilla Territorial Control on Attitudes towards the Government (Version 2) |
| `FV_2_rdd_public_all.do` | Effects of Guerrilla Control on Public Goods Provision |
| `FV_2_rdd_plotsize_cenagro_all.do` | Effects of Guerrilla Control on the Size of Plots - Simpson’s Index |
| `FV_2_rdd_yield_all.do` | Effects of Guerrilla Control on Agricultural Productivity |
| `FV_2_rdd_migr_all.do` | Effects of Guerrilla Control on Migration Outcomes -  Effects of Guerrilla Control on Migration Outcomes for the Highly Educated Population|
| `FV_2_rdd_conflict_all.do` | Effects of Guerrilla Territorial Control on Main Outcomes, Controlling for Conflict |
| `FV_2_rdd_victimsgeo_all.do` | Effects of Guerrilla Territorial Control on Crimes during the War Period |
| `FV_2_external_validity_plots_all.do` | External Validity for Main Outcomes |
| `FV_2_rdd_educage_all.do` | Effects of Guerrilla Control on Years of Education by Age Cohort - Quality of School Teachers |
| `FV_2_rdd_main_all_conley.do` | Effects of Guerrilla Territorial Control on Main Outcomes Using Conley Standard Errors |
| `FV_2_elev_robustness_test.do` | Placebo Test for All Pairs of Neighbors Whose Difference in Altitude is between the Following
Thresholds - Main Results Restricting the Sample to Tracts without Sudden Altitude Changes with Respect to
Their Neighbors|
| `FV_2_rdd_main_all_always.do` | Effects of Guerrilla Territorial Control on Main Outcomes for Individuals Who Have Always
Lived in the Same Place |
| `FV_2_rdd_isic_all.do` | Workers by Economic Activity - Plot of Share of Workers by Economic Activity and Distance to the Boundary  |
| `FV_2_rdd_ineq_canton_all.do` |  Inequality of Income at the Canton Level |
| `FV_2_rdd_ineq_all.do` |  Inequality of the Wealth Index at the Census Tract Level |
| `FV_2_rdd_coop_cenagro_all.do` | Belonging of Agricultural Producers to Cooperatives |
| `FV_2_rdd_mccrary_all.do` | Density Test of the Distance to the Border as Running Variable |
| `FV_2_rdd_elec_all.do` | Effects of Guerrilla Territorial Control in the Elections of 2014 and 2015 |
| `FV_2_rdd_labor_all.do` | Share of Individuals who Work in the Same Place as their Residence |
| `FV_2_rdd_basehet_all.do` | Heterogeneity by Baseline Distances to Road Network (1980) and Nearest City (1945) |
| `FV_2_rdd_crime_all.do` |  Effects of Guerrilla Control on Homicide and Victimization Rates |
| `FV_2_rdd_main_robust_all.do` | Robustness Analysis for the Main Outcomes |
| `FV_2_rdd_fisdl_all.do` | Effects on Investment Porjects FISDL |
| `FV_2_rdd_pnc_all.do` | Effects on Police Stations |
| `FV_2_rdd_cestablishments_all.do` | Effects on Presence of Commercial Establisments |
| `FV_2_rdd_ehpm_educyrs_all.do` | Effects of Guerrilla Control on Years of Education by Age Cohort (EHPM) |
| `FV_2_siindex_canton_cenagro_all.do` | Simpson's Index at the Canton Level |
| `FV_2_rdd_owner_cenagro_all.do` | Ownership of Agricultural Producers (CENAGRO)|
| `FV_2_rdd_yield_cenagro_all.do` | Crop Yield of Agricultural Producers (CENAGRO) |
| `FV_3_predicted_outcomes_all.do` | Spatial Representation of the Main Outcomes’ Predictions |

## What had been done by others and by whom? 
- The EHPM panel was prepared by one of Lelys RAs at the WB. 
- The lapop census tract identifiers were prepared by Sarita Ore, a previous RA of Mica. 

## What is the current status of the project?  What remains to be done?  

## Anything else we should know? 
- Please do not try to run `FV_0_master.do` file all at once. I reccommend running this file separately (line by line). 


