# Compile isotope data for analysis

# NOTE: data / analyses are prelimiary and subject to change. 

library(tidyverse)

### Read in data and tidy
isodat <- as.tibble(read.csv("data/data_iso_fish_clean.csv", header = TRUE))
isodat <- isodat %>% 
  select(SiteID, SpecCode, d15N, d13C.norm, CN, TL_mm) %>% 
  rename(d13C = d13C.norm) %>% 
  filter(SiteID == "LR05") %>% 
  mutate(trophic = "Fish", SpecCode.new = SpecCode)

dugan <- read_csv("data/data_iso_dugan2013.csv", col_names = TRUE)
dugan <- dugan %>%
  select(site, taxa, deltaC, deltaN, CNratio, TL_mm, trophic, SpecCode.new) %>% 
  rename(SiteID = site, SpecCode = taxa, d13C = deltaC, d15N = deltaN, CN = CNratio) %>% 
  filter(SiteID == "Greenbelt")

### Bind my LR05 data to dugan data
df1 <- bind_rows(dugan, isodat) %>% 
  mutate(SiteID = factor(SiteID),
         SpecCode = factor(SpecCode),
         SpecCode.new = factor(SpecCode.new),
         trophic = factor(trophic))

### Filter for large adult Brown Trout and most common prey
df2 <- df1 %>% 
  filter(SpecCode.new %in% c("BNT", "Minnow", "Isopoda", "Decapoda", "Baetidae",
                             "Hydropsychidae")) %>% 
  filter(!(SpecCode.new == "BNT" & TL_mm <200))

# Summarize data, N, mean, and SD's for prey and BNT
( summ1 <- df2 %>% 
    group_by(SpecCode.new) %>% 
    summarise(N = length(SpecCode.new), 
              m.d13C = mean(d13C), 
              sd.d13C = sd(d13C, na.rm = TRUE),
              m.d15N = mean(d15N),
              sd.d15N = sd(d15N, na.rm = TRUE)) )

### Write filtered df and summarized df to file for analysis
# df2  <- df2 %>% filter(SpecCode.new != "BNT") %>% droplevels()
# summ1 <- summ1 %>% filter(SpecCode.new != "BNT") %>% droplevels()
write_csv(df2, "data/data_raw_rKIN.csv")
write_csv(summ1, "data/data_summarized.csv")
