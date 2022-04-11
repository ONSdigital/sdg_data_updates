### Debug_code training
  
This task is designed to help with getting used to quality assuring other people's code, specifically debugging (finding errors in the code)
  
The practice code is taken from the automation of 15-1-1. It has been consolidated into a single script and does not include the
QA element (in Rmarkown). Bugs have been introduced for debugging.  
  
#### Instructions
1. Fetch the main branch from Github
2. Create a new branch e.g. 'debugging_code_your_initials'
3. Set this as your working branch  
4. Open RStudio
5. Open the sdg_data_updates project (File > Open Project > navigate to your cloned sdg_data_updates folder - it is in there)
6. Open the code_to_debug.R file
7. Debug away! The original code_to_debug file will remain, unchanged, on the main branch
8. Make regular commits - this way if you make an error and want to step back to an earlier version, you can.
  
#### Tips  
- Run individual chunks of code step by step and check the outputs at each stage (you can view data frames by selecting them from the environment window, usually located on the top right and listing all avaiable variables in your current session)
- Use `?function_name` to check the documentation of functions you're not sure about. It's useful to see what kind of arguments they require and if they have been specified correctly in the code.
- Some more obvious errors will be picked up by the RStudio editor and indicated with a red cross by the line number
- To check where a function starts or ends, you can place the cursor behind an opening or closing parenthesis, and the corresponding start/end parenthesis of the statement will get highlighted
- Some bugs may be carried over for a while before they generate an error message in the code, so it's useful to step back and analyse the logic and outcomes of previous lines of code.
- For long statements that are passed through multiple pipe operators (`%>%`), it may be useful to break them down into separate statements so you can see what is happening at each stage. Each set of statements between two pipe operators can be seen as a separate action where a bug may be present. If you break those down, you can check, for example, the state of the of a data frame before it's passed to the next stage.