####This automation needs to be checked:  
- Does the link download the most recent data? 
- If we download fewer years, can we add country and region to the update? At the moment I think the number of rows that download on the csv is restricted.
- Are the population figures for the same period as the worker numbers (
- Find out why we don’t go back to 2004. If there is no good reason for this, then go back further.
  
####Decisions to be made:  
- Are we using the right SOC2010 codes? The UN reqests a small subset of what we report - should we just be reporting those? Are there SDMX implications to including more?
  
####Code edits that may be needed:  
- to be SDMX compatible maybe use subset of SOC2010 codes
- If the above is done, we can calculate headlines for each series?
- Add in region and country?
  
####To add to instructions
Not sure how to automate getting the 'last updated' date.  
On Nomis you have to go to the selection and it tells you at the bottom of the [review selections section](https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=168)
