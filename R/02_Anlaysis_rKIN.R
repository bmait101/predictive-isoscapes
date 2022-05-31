devtools::install_github("salbeke/rKIN@master")
require(rKIN)

library(rKIN)
library(tidyverse)

#===================================================
# --- Load data ---- 
#===================================================
isodat <- as.tibble(read.csv("data/data_raw_rKIN.csv", header = TRUE))
isodat  <- isodat %>% filter(SpecCode.new != "BNT") %>% droplevels()
str(isodat, vec.len=2)

### Create matrix d.f. for analyses; must put into DF not tibble
exo <- as.data.frame(isodat[,c("d13C","d15N","SpecCode.new","SiteID")])
names(exo) <- c("iso1", "iso2", "group", "community")
table(exo$group)  # sample sizes per group

#===================================================
# --- Estimating prey isotopic distributions ---- 
#===================================================
# Generate prey isotopic distributions from observed data (mean and sd from 
# randomly sampling the kernal estimates from rKIN, then feed into model

### 1. Generate rKIN object
tkin <- estKIN(data = exo, x="iso1", y="iso2", group="group", h = "ref",
               levels=95, scaler=1, smallSamp = TRUE)

# Plot to vizualize prey items in isotopic space
plotKIN(tkin)



### 2. For each prey kernal, sample randomly from to create observed distriution
samples1 <- spsample(tkin[[2]][1]$Baetidae@polygons[[1]]@Polygons[[1]], 
                    type = "random", n = 100, iter = 100)
samples2 <- spsample(tkin[[2]][2]$Minnow@polygons[[1]]@Polygons[[1]], 
                    type = "random", n = 100, iter = 100)
samples3 <- spsample(tkin[[2]][3]$Decapoda@polygons[[1]]@Polygons[[1]], 
                    type = "random", n = 100, iter = 100)
samples4 <- spsample(tkin[[2]][4]$Hydropsychidae@polygons[[1]]@Polygons[[1]], 
                    type = "random", n = 100, iter = 100)
samples5 <- spsample(tkin[[2]][5]$Isopoda@polygons[[1]]@Polygons[[1]], 
                    type = "random", n = 100, iter = 100)
## Now, pull coordinates from list into new df
newdf <- 
  data.frame(rbind(
    cbind(mean(samples1@coords[,1]),
          sd(samples1@coords[,1]),
          mean(samples1@coords[,2]),
          sd(samples1@coords[,2])),
    cbind(mean(samples2@coords[,1]),
          sd(samples2@coords[,1]),
          mean(samples2@coords[,2]),
          sd(samples2@coords[,2])),
    cbind(mean(samples3@coords[,1]),
          sd(samples3@coords[,1]),
          mean(samples3@coords[,2]),
          sd(samples3@coords[,2])),
    cbind(mean(samples4@coords[,1]),
          sd(samples4@coords[,1]),
          mean(samples4@coords[,2]),
          sd(samples4@coords[,2])),
    cbind(mean(samples5@coords[,1]),
          sd(samples5@coords[,1]),
          mean(samples5@coords[,2]),
          sd(samples5@coords[,2])) ) )

#### 3. Compile results into a new df to feed into foraging model - pun intended :)
# Annotate the new df; NOTE: rKIN changes group order, must name accordingly
colnames(newdf) <- c("m.d13C","sd.d13C","m.d15N","sd.d15N")
Taxa <- c("Baetidae","Minnow","Decopoda","Hydropsychidae","Isopoda")
newdf$Taxa <- Taxa  # add taxa column to df
newdf <- newdf %>% select(Taxa, m.d13C, sd.d13C, m.d15N, sd.d15N)  # rearrange
prey <- newdf  # rename df to easily plug into foraging model
prey  # Check it


