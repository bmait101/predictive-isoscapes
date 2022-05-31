### Modeling foraging behaivor of a predator ###
# Code adapted from Flaherty and Ben-David (2010)

library(tidyverse)

#prey <- read.csv("data_prey_values_FBD.csv", header = TRUE)
#prey <- read.csv("data_summarized.csv", header = TRUE)

#===================================================
# --- Simulating foraging behaivor  ---- 
#===================================================
# 1. Predator eating 5 prey items
# 2. Model will choose the percentage of diet made up of the prey items for 100 predators
# 3. Model will choose stable isotope values from observed prey isotopic distributions
# and report final C and N isotopic values for each of 100 Bass

set.seed(02201954)  # lock simulated data
N <- 25  # number of virtual predator
outdf <- data.frame()  # create df to store results
# Loop through each virtual predator, calculate diet propotions, assaign C & N values
for (i in 1:N) {
  prey1 <- (1 * runif(1, 0, 1))  # random number between 0 and 1 (prop. prey 1 in diet)
  prey2 <- ((1 - prey1) * runif(1, 0, 1))  
  prey3 <- (((1 - (prey1+prey2)) * runif(1, 0, 1)))  
  prey4 <- (((1 - (prey1+prey2+prey3)) * runif(1, 0, 1)))  
  prey5 <- (((1 - (prey1+prey2+prey3+prey4)) * runif(1, 0, 1)))  
  # Store diet proportion results in a df; also calcualte C and N values for each prey and 
  # store directly into the df, and C and N values for each virtual predator
  outdf <- rbind(outdf, data.frame(bass = i, 
                                   prey1 = prey1, prey2 = prey2, prey3 = prey3, 
                                   prey4 = prey4, prey5 = prey5, 
                                   # Calucate random C values given mean and sd's
                                   SI.prey.1.C <- rnorm(1, mean = prey[1,2], sd = prey[1,3]),
                                   SI.prey.2.C <- rnorm(1, mean = prey[2,2], sd = prey[2,3]),
                                   SI.prey.3.C <- rnorm(1, mean = prey[3,2], sd = prey[3,3]),
                                   SI.prey.4.C <- rnorm(1, mean = prey[4,2], sd = prey[4,3]),
                                   SI.prey.5.C <- rnorm(1, mean = prey[5,2], sd = prey[5,3]),
                                   # Calucate random N values given mean and sd's
                                   SI.prey.1.N <- rnorm(1, mean = prey[1,4], sd = prey[1,5]),
                                   SI.prey.2.N <- rnorm(1, mean = prey[2,4], sd = prey[2,5]),
                                   SI.prey.3.N <- rnorm(1, mean = prey[3,4], sd = prey[3,5]),
                                   SI.prey.4.N <- rnorm(1, mean = prey[4,4], sd = prey[4,5]),
                                   SI.prey.5.N <- rnorm(1, mean = prey[5,4], sd = prey[5,5]), 
                                   # Then calculate final C and N SI values for each virtual predator
                                   C = ((prey1 * SI.prey.1.C) + 
                                           (prey2 * SI.prey.2.C) + 
                                           (prey3 * SI.prey.3.C) +
                                           (prey4 * SI.prey.4.C) + 
                                           (prey5 * SI.prey.5.C)),
                                   N = ((prey1 * SI.prey.1.N) + 
                                           (prey2 * SI.prey.2.N) + 
                                           (prey3 * SI.prey.3.N) +
                                           (prey4 * SI.prey.4.N) + 
                                           (prey5 * SI.prey.5.N))
                                   ) 
                 )

  }

# Summarize; get mean and sd for virtual predators, bind to prey df 
(newdf <- rbind(prey, data.frame(Taxa = "Sim_BNT", 
                       m.d13C = mean(outdf$C), sd.d13C = sd(outdf$C), 
                       m.d15N = mean(outdf$N), sd.d15N = sd(outdf$N)) ) )

