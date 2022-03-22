# Purpose: Simple exercises for learning to run snippets
# Author: Emma Wood
# Date: 08/04/2019


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
# b) what is the difference between the arguments 'each' and 'times' in rep()?
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
# b) What do each of the functions in the line of code below do?
rounded_sum1 <- round(sum(as.numeric(as.character(values))), 1)





# white space so you don't accidentally see the answers in the next bit!







# this could broken down to:
character_values <- as.character(values)
numeric_values <- as.numeric(character_values)
summed_values <- sum(numeric_values)
rounded_sum2 <- round(summed_values)

# but that is a lot of new objects to name!
# The pipe operator (%>%) makes it possible to break it down without
#  creating loads of objects:
library(dplyr)

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

row_added <-

year_corrected <- 

age_renamed <- 

# b) run the ifelse statement from the pipe outside the pipe 
#      (i.e. from  `mutate(Year = ifelse(Year == "2018", "2017", Year)) %>%`) 



#------------------
# Finding bugs in if() statements
# Exercise 4
# a) why is the code below not giving us a value for z?
# b) how could you fix it if you always wanted it to result in a value for z? 
# c) how many answers can you come up with for b?
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

# a) What is printed in the console and why?
# b) Set i to find the 4th value (type in the console)
# c) edit the code below (copied from above) so that *all* values are printed in 
#    the console

for(i in 1:length(random_values)){
  random_values_sq <- random_values[i] * random_values[i]
}

print(random_values_sq)

# bonus bits:
# d) edit the code so that it produces a vector of squared values
# e) create the vector of squared values without using a loop







