# -*- coding: utf-8 -*-
"""
Created on Wed Jul 14 14:31:21 2021

@author: jakkiv
"""

import pandas as pd
import numpy as np
import glob # for finding strings of a given pattern
import os
import webbrowser # used to open the ONS site to download csv files
from os import path, rename # to interact with files 
from time import sleep # use to allow time for the file to download before continuing
import getpass # to get username




# Change indictor to folder name e.g.

# indicator = "3-9-1_python"

indicator = "3-c-1_python" # Change this


################################ DO NOT EDIT CODE BELOW THIS LINE #################

os.chdir(indicator)

import update_code

update_code.run_update()


os.chdir("..")


