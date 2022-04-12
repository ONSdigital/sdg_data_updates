## Template R code
  
### Intro
The code in this folder has been pulled together to make the process of writing automations in R faster and more consistent across indicators. 
It also contains code that aid in future-proofing against changes in the initial files.
  
There are four main files that should be relatively consistent in what they do across all indicators (where it is just a standard update):
1. `update_indicator_main.R` This file is the control script for ALL standard R updates. 
You should not need to change anything on it, other than the indicator number when you are testing your automation
2. `compile_tables.R` Every standard R update needs a script with this exact name. It is the script called by `update_indicator_main.R`, 
and which calls the scripts that do the donkey-work. The csv may be saved from here. The Rmarkdown html file is run and saved from here.
3. `config.R` This could be written as a yaml, but usually the configs are straightforward enough that an R config file is fine. This is where
user configurations are set - these are aspects of the code that may need to be changed depending on when it is run, but that we can't or don't want to automate.
It should have this name to save any confusion, and because this is a standard name for this kind of file. It is called by `compile_tables.R`
4. A .R script or scripts that do the bulk of the work called by `compile_tables.R` (I refer to this as the 'workhorse' file). 
It/they can be called anything, but try to keep it informative.
5. A .Rmd script that creates an html for QA purposes (not yet in templates) called by `compile_tables.R`.
  
There are a number of different input layouts that impact the way an automation is written. There are, therefore, separate template scripts for each of these types. Each file layout type has it's own input, config, compile_tables, and workhorse files.  
  
Currently, only the templates for type_1, type_2 and type_4 are ready to use, though they do not yet include markdown templates.  
  
### Input types
#### Type 1: Simple excel or csv file 
- Headers (column names) may or may not be on the first row
- Only **one** row of headers  
  
#### Type 2: Excel file with complex headers
- Headers (column names) may or may not be on the first row
- Any number of rows and/or columns can contain headers. 
- May contain merged cells
![complex_header](https://user-images.githubusercontent.com/52452377/130663339-d953d7ee-13d1-4422-aa48-e8d6091285d0.jpg)
  
#### Type 3: Excel file with headers hidden in a data column
- Complex headers where what would usually be a header is in a normal column and only identified as a header by formatting (e.g. text in bold)
  
#### Type 4: Nomis
- Data that are on Nomis do not need to be manually downloaded as they have stable weblinks
- Headers are simple and stable (I think the latter is true)
   
#### Type 5: ONS CDID 

### Instructions
1. Identify which type is closest to the data you want to write an automation for.
2. Open RStudio
3. Open the sdg_data+updates R.proj project
4. Open the relevant config, compile_tables and workhorse files. E.g. If you have type 1 data, open type_1_config.R, type_1_compile_tables.R, and update_type_1.R
5. Run the template code bit by bit on the example data (in template > Example_input) so you can see what it does
6. Create a folder for your indicator in the main folder (**not in the template folder**)
7. Save the relevant template scripts in your new folder
8. Rename them. E.g. type_1_config.R will just be example_config.R or config.R. 
9. Create your automation from the templates! (I would start with config.R, then the workhorse, and finally compile_tables.
10. If something doesn't work or causes an unexpected error, please raise it as an issue so we can improve the template scripts.

Happy coding!
