Author: Atanaska Nikolova

Create csv data for 9-a-1 with disaggregation of country income group. 

Input data are stored in a folder named 'Example_input'. Output is saved to a folder named 'Example_output'. Currently the function needs to be run twice (once for each csv in the inputs folder), the example run code at the end of the script does that, and then binds the two results into a single output file.

The code works, but it needs to be polished to fit with the contributing standards.

### Outstanding actions:

- Make sure the code is working as is, and there are no bugs
- Transform the function so it outputs a single csv, rather than having to run the function twice. This could be done using lists, and reading the two datasets as two separate arguments in the function. See 1.a.1 (currently a feature branch) for an example of how this could be done.
- Make compatible with the contributing.md standard (e.g. have config file for the user inputs, separate code for the main function and tables compilation. See examples of finalised indicators in the main repository)
- Currently the code is using base R, but perhaps it can be made clearer with tidyverse packages
- Possibly integrate an automated QA