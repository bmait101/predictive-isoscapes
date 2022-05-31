# Bryan M
# March 10, 2018
# Script file to run trout without GUI

# Load MixSIAR package
library(MixSIAR)
library(splancs)

#===============================================================================
### 1. Load data
#===============================================================================
# Load mixture data
mix.filename <- "data/trout_consumer.csv"
mix <- load_mix_data(filename=mix.filename, 
                     iso_names=c("d13C","d15N"), 
                     factors="Region", 
                     fac_random=TRUE, 
                     fac_nested=FALSE, 
                     cont_effects=NULL)

# Load source data
source.filename <- "data/trout_sources.csv"
source <- load_source_data(filename=source.filename, source_factors="Region", 
                            conc_dep=FALSE, data_type="means", mix)

# Load discrimination data
discr.filename <- "data/trout_discrimination.csv"
discr <- load_discr_data(filename=discr.filename, mix)

#===============================================================================
### 2. Make isospace plot and illustrate priors
#===============================================================================
plot_data(filename="isospace_plot", 
          plot_save_pdf=FALSE,
          plot_save_png=FALSE,
          mix,source,discr)
# Data loaded correctly, and mixture data in the source polygon. 

# If 2 isotopes/tracers, calculate normalized surface area of the convex hull polygon(s)
if(mix$n.iso==2) calc_area(source=source,mix=mix,discr=discr)

# Define your prior, and then plot using "plot_prior"
# default "UNINFORMATIVE" / GENERALIST prior (alpha = 1)
plot_prior(alpha.prior=1,source, 
           plot_save_pdf=FALSE,
           plot_save_png=FALSE)

#===============================================================================
### 3. Choose model structure options
#===============================================================================
# Write JAGS model file (define model structure)
# Model will be saved as 'model_filename' ("MixSIAR_model.txt" is default,
#    but may want to change if in a loop)

# There are 3 error term options available:
#   1. Residual * Process (resid_err = TRUE, process_err = TRUE)
#   2. Residual only (resid_err = TRUE, process_err = FALSE)
#   3. Process only (resid_err = FALSE, process_err = TRUE)

model_filename <- "MixSIAR_model.txt"
resid_err <- TRUE
process_err <- TRUE
write_JAGS_model(model_filename, resid_err, process_err, mix, source)

#===============================================================================
### 4. Run JAGS model
#===============================================================================
# Run model
# JAGS output will be saved as 'jags.1'

# MCMC run options:
# run <- "test"       # chainLength=1000, burn=500, thin=1, chains=3, calcDIC=TRUE
# run <- "very short" # chainLength=10000, burn=5000, thin=5, chains=3, calcDIC=TRUE
# run <- "short"      # chainLength=50000, burn=25000, thin=25, chains=3, calcDIC=TRUE
# run <- "normal"     # chainLength=100000, burn=50000, thin=50, chains=3, calcDIC=TRUE
# run <- "long"       # chainLength=300000, burn=200000, thin=100, chains=3, calcDIC=TRUE
# run <- "very long"  # chainLength=1000000, burn=500000, thin=500, chains=3, calcDIC=TRUE
# run <- "extreme"    # chainLength=3000000, burn=1500000, thin=500, chains=3, calcDIC=TRUE

# Can also set custom MCMC parameters
# run <- list(chainLength=200000, burn=150000, thin=50, chains=3, calcDIC=TRUE)

jags.1 <- run_model(run="very short", mix, source, discr, model_filename, 
                    alpha.prior = 1, resid_err, process_err)

# After a test run works, increase the MCMC run to a value that may converge
# jags.1 <- run_model(run="normal", mix, source, discr, model_filename, 
                    # alpha.prior = 1, resid_err, process_err)

#===============================================================================
### 5. Choose outputs options and process output
#===============================================================================
# Process JAGS output

# Choose output options (see ?output_options for details)
output_options <- list(summary_save = TRUE,                 
                       summary_name = "summary_statistics", 
                       sup_post = FALSE,                    
                       plot_post_save_pdf = TRUE,           
                       plot_post_name = "posterior_density",
                       sup_pairs = FALSE,             
                       plot_pairs_save_pdf = FALSE,    
                       plot_pairs_name = "pairs_plot",
                       sup_xy = FALSE,           
                       plot_xy_save_pdf = TRUE,
                       plot_xy_name = "xy_plot",
                       gelman = TRUE,
                       heidel = FALSE,  
                       geweke = TRUE,   
                       diag_save = TRUE,
                       diag_name = "diagnostics",
                       indiv_effect = FALSE,       
                       plot_post_save_png = FALSE, 
                       plot_pairs_save_png = FALSE,
                       plot_xy_save_png = FALSE)

# Create diagnostics, summary statistics, and posterior plots
output_JAGS(jags.1, mix, source, output_options)

