# Purpose: ANSWERS to exercises for learning to run snippets
# Author: Emma Wood
# Date: 08/04/2019

library(dplyr)

# Unless we explicitly ask to see the contents of an object we do not see the 
#  results of what has happened in the CPU
# Fortunately, the Environment window does this for us to some extent - 
#  as you run the code below you will see the variables and their values appear

X <- 10
Y <- 20
Z <- X + Y

# this is a valid expression (Y will be overwritten)
Y <- X + Y

# you can also view what a variable is, or the results (or what will be the results) of a line of code in the console by 
# a) just running the part to the right of the arrow
# b) just running the part to the left of the arrow (once you have already run that line)

#------------------
#--- RUNNING SNIPPETS

# exercise 1
# check what each bit of code is doing, by running round brackets from the inside out
# a) what does rep() do?
# ANS: it repeats the vector given in the first argument (the first thing in the brackets)

# b) what is the difference between the arguments 'each' and 'times' in rep()?
# ANS: `each` takes each element of the vector and repeats it the stated number of times
#      'times` takes the whole vector and repeats it the stated number of times
dummy_data <- data.frame(Year = rep(c("2018", "2019", "2020"), each = 3),
                         Age = rep(c("20-29", "30-39", "40-49"), times = 3),
                         Value = c(32, 50, 41,
                                   34, 56, 39,
                                   36, 60, 36))

#----
# Exercise 2
# Look at a slightly more complex line of nested functions 
# create some dummy data
values <- as.factor(c("0.109", "0.359", "0.63"))

# a) what are the functions?
# ANS: as.factor() and c()

# b) What do each of the functions in the line of code below do?
# ANS: 'values' is currently a factor (where each element is given a number code that doesn't relate to the actual number shown).
#      as.character() turns values into strings (each element is a string and doesn't have a number code associated with it).
#      as.numeric() takes the 'values' character string and turns it into a number (no quote marks), on which math can be performed
#      round() rounds the 'values' numbers to the stated number of dp (1)
rounded_sum1 <- round(sum(as.numeric(as.character(values))), 1)

# this could broken down to:
character_values <- as.character(values)
numeric_values <- as.numeric(character_values)
summed_values <- sum(numeric_values)
rounded_sum2 <- round(summed_values)

# but that is a lot of new objects to name!
# The pipe operator (%>%) makes it possible to break it down without
#  creating loads of objects:

rounded_sum3 <- values %>% 
  as.character() %>%
  as.numeric() %>%
  sum() %>%
  round(1)
#------------------
# Running snippets of code in a pipe
# Exercise 3

# a) split the following piped code into three separate datasets 
#    (row_added, year_shortened, and age_renamed) 
#    to see what each line produces when isolated from the rest of the pipe
#    The answers have been started just below the following block.
new_data <- dummy_data %>% 
  add_row(Year = "2021", 
          Age = "20-29",
          Value = 86) %>% 
  mutate(Year = ifelse(Year == "2018", "2017", Year)) %>% 
  rename(Agegroup = Age)

# ANS:
row_added <- add_row(dummy_data, Year = "2021", Age = "20-29", Value = 86)
year_corrected <- mutate(row_added, Year = ifelse(Year == "2018", "2017", Year))
age_renamed <- rename(year_corrected, Agegroup = Age)
# OR:
row_added <- dummy_data %>% add_row(Year = "2021", Age = "20-29", Value = 86)
year_corrected <- row_added %>% mutate(Year = ifelse(Year == "2018", "2017", Year))
age_renamed <- year_corrected %>% rename(Agegroup = Age)

  
# b) run the ifelse statement from the pipe outside the pipe 
#      (i.e. from  `mutate(Year = ifelse(Year == "2018", "2017", Year)) %>%`) 
# ANS:
ifelse(dummy_data$Year == "2018", "2017", dummy_data$Year)
  
  
  #------------------
# Finding bugs in if() statements
# Exercise 4
# a) why is the code below not giving us a value for z?
# ANS: because x is equal to y, so it hasn't even been created (we also haven't asked it to show us z by running z on it's own)

# b) how could you fix it if you always wanted it to result in a value for z? 
# ANS: e.g. - change the statement in if() e.g. if(sqrt(x) >= y*2)
#           - change the value of x or y
#           - make an else statement at the end:
if(sqrt(x) > y*2){
  z <- x - y
} else if(sqrt(x) < y*2) {
  z <- y - x
} else {
  z <- 0
}


# c) how many answers can you come up with for b?
# ANS: see above for examples

x <- 196
y <- 7

if(sqrt(x) > y*2){
  z <- x - y
} else if(sqrt(x) < y*2) {
  z <- y - x
}

#------------------
# Running a for loop one iteration at a time 
# Exercise 5 (the first bit is just setting up the necessary variables -
#              scroll to a) for the actual excercises/questions)

# Run the following code then do the questions:

# this code creates a vector filled with random normal values
random_values <- rnorm(30)

# this code initialises 'random_values_sq' (i.e. makes it an object)
random_values_sq <- 0

# populate the new sequence 'random_values_sq' 
for(i in 1:length(random_values)){
  random_values_sq <- random_values[i] * random_values[i]
}

print(random_values_sq)

# a) What is printed in the console when you run the code above, and why?
# ANS: the length of the random_values vector because that is the number of the last iteration

# b) Set i to find the 4th value (type in the console, and then run the inside of the loop by running a snippet from the script)
# ANS:
i <- 4
random_values[i] * random_values[i]

# c) edit the code below (copied from above) so that *all* values (from every iteration) are printed in 
#    the console
# ANS:
for(i in 1:length(random_values)){
  random_values_sq <- random_values[i] * random_values[i]
  print(random_values_sq) # print moved inside the loop
}

# bonus bits:
# d) edit the code so that it produces a named vector of squared values
# ANS:
random_values_sq <- c() # create an empty vector to store the values

for(i in 1:length(random_values)){
  
  # add a value to the vector in each iteration - done using the [i] just before the <-
  # when i is 1 this code says:
  # make the first element of random_values_sq <- the 1st random_values * the 1st random_values
  random_values_sq[i] <- random_values[i] * random_values[i] 
}
# see the named vector of squared values:
random_values_sq

# e) create the vector of squared values without using a loop
# ANS:
rand_values_sq <- random_values * random_values
# the loop does it one element at a time, but R can do it all in one go.
# Loops can be useful e.g. for looping through input files, or creating lots of charts,
# but there is usually a way to do things without using a loop

# or you could create a dataframe:
rand_values_df <- data.frame("original_value" = random_values) %>% 
  mutate("squared_value" = random_values * random_values)
