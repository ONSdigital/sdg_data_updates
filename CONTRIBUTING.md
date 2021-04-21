# Contributing to sdg_data_updates #

I am going to assume that the only people who will be contributing will be members of the UK SDG data team. However, if anyone else should happen upon this repo and wish to comment or contribute please do get in touch with us at SustainableDevelopment@ons.gov.uk - your thoughts will be very welcome!

[Useful resources](#useful-resources)  
[General guidelines](#general-guidelines)  
[Coding conventions](#coding-conventions)  
[Setting up your computer to work on indicator automations](#setting-up-your-computer-to-work-on-indicator-automations)  
[Setting up a new indicator automation](#setting-up-a-new-indicator-automation)  
[Working on an existing code](#working-on-an-existing-code)  

## Useful resources ##

[packrat](https://rstudio.github.io/packrat)  
[making a package](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) - if you are unfamiliar with packages, I suggest following this walkthrough (or similar, this is just the one I used) before adding functions to SDGupdater.  
[Tidyverse style guide](https://style.tidyverse.org/package-files.html#names-1)  

## General guidelines ##

- Only edit code for one indicator on any branch
- Commit at least once a day when you are writing code
- Make commit messages, and pull request comments informative
- Get code reviewed when merging into a branch that has other collaborators
- Review is required to merge to main
- When you complete a pull request to main, update sdg_data_updates on the shared drive
- Functions should do only *one* thing. If you think there is a chance it would be useful for other indicators updates, include it in SDGupdater.

## Coding conventions ##

 - Please follow the [Tidyverse style guide](https://style.tidyverse.org/package-files.html#names-1)
 - Some key points:
    - Use informative names. Make it easy on future users (including yourself), by using names that tell you what is going on. This is not easy, but worth mastering. Well named objects and functions can negate the need for comments that tell you what the code does.
    - Use spaces the way they would be used in a sentence (e.g. the space comes *after* the comma `[, 1]`)
    - In R, assign using `<-` not `=`
    - Comment on *why* you are doing something not *what* the code is doing. If you need to state what the code does, consider improving names and using well-named functions.

## Setting up your computer to work on indicator automations ##

1) You should have 2-factor authentication on you Github account. This means that you may need to use a Personal access token to get your Git to sync with Github. To get a Personal access token, in Github go to Settings (your settings, not the repository settings) > Developer Settings > Personal Access Tokens. Copy the token and save it. When you are prompted for your password from Git, use this rather than your Github password.
2) Copy the repo to your local drive (do not use a networked drive, as this will only cause you issues!). You can do this using the command line (e.g. Anaconda prompt), however here I just give instructions for Git GUI (though the logic will be the same):
    1) If you don't already have one, create a folder on your local drive in which to store this and any other coding repos (I suggest using the  D: drive). 
    2) Open Git GUI
    3) Click on 'clone existing repository'
    4) In the [sdg_data_updates repo](https://github.com/ONSdigital/sdg_data_updates/) on Github go to the main branch, then click on the Code dropdown and copy the https link (see image below).
    5) Paste this link into the 'Source Location' field in Git GUI
    6) In the 'Target Directory' field navigate (using Browse) to the folder you created in step i. Add '/sdg_data_updates'
    7) Clone
    8) You may be prompted for a password. Use the token you created in step 1.
    9) You are now ready to get started!
    
![image](https://user-images.githubusercontent.com/52452377/115564316-46297d00-a2b0-11eb-958b-c578235d14a5.png)

## Setting up a new indicator automation ##
Every new indicator automation requires it's own branch. **Do not work on code in a branch that already exists.**
1) In Git GUI fetch the most recent version of the repo from Github
  > Remote > Fetch from > origin
2) Create a new branch for the indicator you want to work on
  > Branch > Create  
  > Name the branch with the indicator number  
  > Starting Revision should be set to Tracking Branch > main  
  > Create
3) Create a new folder for the indicator, using the indicator name (x-x-x) as the folder name (use dashes to separate numbers)
3) Start writing your indicator update automation
4) Make regular commits to Github, so that others can pick up your changes, and so you can roll back to an earlier version if it all starts to go pear-shaped. In Git GUI:
  > Make sure you are in the right branch by looking at Current branch (in the top left of the window just below the menu bar). If current branch is not correct, go to Branch > Checkout
  > Click Rescan to pickup any changes  
  > Changed files are displayed in the Unstaged changes panel. You can click on these to see details.   
  > To move them down into the Staged changes panel click on the file icon to the left of the filename inthe Unstaged changes panel  
  > Write a meaningful commit message. The first line is the title - keep this quite short. Hit enter twice then enter further details e.g. was it a bug fix/ progress on a certain aspect of the code?  
  > Commit  
  > Push (make sure you are pushing to the right branch)  


## Working on an existing code ##
If you want to make changes to an existing automation, unless it is a cosmetic change e.g. to the readme, please create a new branch for your changes. 
1) Follow steps 1 and 2 for setting up a new indicator automation, but change the Starting Revision to the relevant branch. This may either be 'main' or a branch that has not yet been merged with 'main'. If you are not sure, check with whoever is currently working on that branch. Name your new branch something informative (e.g. 3-2-2-add_sex_data).  
**Remember to fetch from origin and create from the Tracking Branch**
2) Once you have made your changes, merge your branch with the branch it was created from using a pull request. 
    > Pull requests > New pull request
    > Set base and compare branches  
    > Create pull request  
    > Request review using panel on the right. If you are merging into main this is required before the merge can be completed. If you are merging into your own branch you may want to skip this step, however if you are merging into a colleagues code, please request review/sign-off before merging.
