# Contributing to sdg_data_updates #

I am going to assume that the only people who will be contributing will be members of the UK SDG data team. However, if anyone else should happen upon this repo and wish to comment or contribute please do get in touch with us at SustainableDevelopment@ons.gov.uk - your thoughts will be very welcome!

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
Every new indicator automation requires it's own branch. **Do not work on code in a branch that already exists.
1) In Git GUI fetch the most recent version of the repo from Github
  > Remote > Fetch from > origin
2) Create a new branch for the indicator you want to work on
  > Branch > Create  
  > Name the branch with the indicator number  
  > Starting Revision should be set to Tracking Branch > main  
  > Create
3) You are now ready to start writing your indicator update automation

## Working on an existing code ##
If you want to make changes to an existing automation, unless it is a cosmetic change e.g. to the readme, please create a new branch for your changes. 
1) Follow the steps for setting up a new indicator automation, but change the Starting Revision to the relevant branch. This may either be 'main' or a branch that has not yet been merged with 'main'. If you are not sure, check with whoever is currently working on that branch. Name your new branch something informative (e.g. 3-2-2-add_sex_data).  
**Remember to fetch from origin and create from the Tracking Branch**
2) Once you have made your changes, merge your branch with the branch it was created from using a pull request. 
3) If the branch was created by someone else on the team If this is the main branch 
