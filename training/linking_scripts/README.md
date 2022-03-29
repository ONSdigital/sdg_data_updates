## Linking scripts exercise
  
### Intro
We have a set template for writing automations in R. This is so that all indicators can be run using the same script (`update_inidcator_main.R`).
It also means that automations will be faster to write, review, and debug, as you will become familiar with the structure.  
  
See [CONTRIBUTING.md](https://github.com/ONSdigital/sdg_data_updates/blob/main/CONTRIBUTING.md#file-structure-of-automations) to see an
overview of the file structure.  
  
This exercise is designed to help you become familiar with the file structure, and to learn what we expect to see in each script.  Hopefully,
this will help you to understand what the code is doing so that you can run these codes in order when you are, for example, doing a code review.  
  
When/if you start writing your own automations, I find it is easiest to follow the template from the beginning rather than writing everything in one big code then 
splitting it up at the end. However, you may find you prefer to do the latter.
  
We will use the same script we have been working on in the clean_code and debug_code exercises. A clean and debugged file ("code_to_split.R") can be found in this 
training folder.  
  
### Instructions
1. Create your own branch from main for the linking_scripts_exercise
2. Open the "sdg_data_updates.Rproj" project in Rstudio
3. Go to the templates folder and open "type_1_config.R" and "type_1_compile_tables.R"
4. Save these in the training/linking_scripts folder as "config.R" and "compile_tables.R"
5. Save "code_to_split.R" as "update_indicator.R" or something similar - 
  most of the code in here will remain untouched, and the code that needs to move to the other scripts will largely be cut and pasted from here 
6. If you want to have a go at linking the update_indicator_main, config, compile_tables and update_indicator files yourself, then go for it.
   Use the information already in the template config and compile_tables scripts to prompt you on what needs to go where.
   However, if you would prefer a walk-through, follow the next block of instructions.

### Walk-through of linking scripts
1. Go to config.R - it suggests that you put the filenames in here. How many files do you need to put in? Hint - put them in as separate objects, with meaningful names.
   You will find the filenames in the read_xlsx arguments in the update_indicator.R file (originally split_code.R).
2. Still in config.R - put the tabnames in, again with meaningful names.
3. Set the input_folder name to whatever you want it to be (usually "Input" or "Example_Input")
4. Set the output_folder name to whatever you want it to be (usually "Output" or "Example_Output")
---
5. Go to update_indicator.R and replace the hard-coded filename with a filepath (Hint: use paste0() to create a filepath from input_folder and the filename.
6. Replace the tabnames with the object you created for the tabname in config.R
---
7. Go to compile_tables.R. You will see that from line 19, the code is very similar to the code at the bottom of update_indicator.R.
   Move this information from update_indicator.R to the compile_tables.R file. A lot of it can just be deleted as it is already in the compile_tables template.
8. Make sure the arguments in write.csv() and message() have the correct names.
---
9. Check if the scripts all work - you can test this by running them from 'update_indicator_main.R', or you may first want to run them bit by bit in order
   from compile_tables.R: Compile_tables is the script that is run by update_indicator_main.R. so start there and run it line by line.

Happy coding!
   
