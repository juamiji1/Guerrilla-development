# Project: Rebel Governance and Development - The Long-Term Effects of Guerrillas in El Salvador

**Name**:  Juan Miguel Jimenez

**Contact information**: juamiji@gmail.com

## What is the project?
How does territorial control by armed non-state actors affect long-term development? We investigate the economic, social, and political consequences of territorial control by guerrillas during the Salvadoran Civil War.  During their territorial control, guerrillas displaced state authorities and large landowners, and promoted the creation of self-governing institutions. Using a regression discontinuity design, we show that areas exposed to guerrilla control have experienced worse economic outcomes over the last 20 years relative to areas outside these locations that were under the control of the formal state.  Our results reveal that  informal participatory institutions in guerrilla controlled areas led to a fragmentation of the economy and high distrust towards the state and agriculture elites that persists today.

## Set up
To replicate this project, you will need to have Stata-16, R-studio, GitHub, and access to Dropbox. 

### Dropbox folder
The main folders that I used are

| Path | Description |
| ---- | ----------- |
| `/Guerillas_Development/2-Data/Salvador` | Has all the data used in this project | 
| `/Guerillas_Development/5-Maps/Salvador` | Has all the original scans of the historical maps used | 
| `/Github/Guerrilla-development/code` | Has all code used in this project |

### Overleaf folders
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
| `0.` |  `FV_0_master.do` allows you to replicate the project | 
| `1.` | Files with this prefix clean and prepare the raw data |
| `2.` | Files with this prefix make the estimations | 
| `3.` | Files with this prefix make maps or other tasks related with the survey | 

Other files and folders in this location are
- `/Github/Guerrilla-development/2_analysis/version_elev` : Has a version of the final code in which we control by elevation or restrict the sample to census tracts above 200 masl.
- `/Github/Guerrilla-development/code/0_archive` : This folder contains old codes from previous versions of the article (we didn't know what to do at that point).  

## What had been done by others and by whom? 
- The EHPM panel was worked by one of Lelys Ras at the WB. 
- The lapop identifiers were worked by Sarita Ore, a previous RA of Mica. 

## What is the current status of the project?  What remains to be done?  

## Anything else we should know? 
- Please do not try to run `FV_0_master.do` file all at once. I reccommend running this file separately (line by line). 


