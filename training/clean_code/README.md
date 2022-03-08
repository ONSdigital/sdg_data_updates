### Clean_code training
  
This task is designed to help contributors understand why clean code is important and to get some practice in naming objects
and identifying which comments are useful.
  
The practice code is taken from the automation of 15-1-1. It has been consolidated into a single script and does not include the
QA element (in Rmarkown). Names of objects, formatting, and comments have been edited to make the script less 'clean', however the 
code itself is the same as the original (there are no bugs).  
  
#### Instructions
1. Fetch the main branch from Github
2. Create a new branch e.g. 'code_cleaning_your initials'
3. Set this as your working branch  
4. Open RStudio
5. Open the sdg_data_updates project (File > Open Project > navigate to your cloned sdg_data_updates folder - it is in there)
6. Open the code_cleaning_practice.R file
7. Clean away! The original code_cleaning_practice.R will remain, unchanged on the main branch
8. Make regular commits - this way if you make an error and want to step bac to an earlier version, you can.
  
#### Tips  
- Start with formatting the whole script so the code is easier to read
	- break down long lines of code onto separate rows (an easy and logical place to add a new line is after a comma)
	- put spaces between word and symbols (except for dollar symbols- `dataframe$variable` should have no spaces). See clean code guidance.
- Run bits of code to see what they do, and make names for the resulting objects that make sense. Try to make it so you
don't need the 'what' comments - what the code is doing should be clear from the names you use.  
- As you go along, check that the script still works and that you haven't inadvertently broken something.
- When renaming anything use `find > replace all` (with `whole word` selected). 
If you forget to rename all in this way, you are likel to break the code and get confused.  
- Take care not to rename something with a name you have already used.    
- Avoid using (or keeping) the same name for different objects – 
the original will be overwritten and you will have to rerun everything to see what the old object looked like.   
- Remove unnecessary comments (the ones that just tell you what the code itself should tell you).  

