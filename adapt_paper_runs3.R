# This was used in version submitted (rejected) to Technometrics

# Comparisons for adapt paper
# source('C:/Users/cbe117/Documents/GitHub/DOE-code/compare_adaptconceptR6.R')
source('.//compare_adaptconceptR6.R')

# In order, these are
# 1. sFFLHD (nonadapt)
# 2. Sobol (nonadapt)
# 3. ALC (no weighting)
# 4. grad mean
# 5. IMVSE
# 6. VSMED
# 7. max VSE at point, not over surface

# obj=c("nonadapt","desirability","desirability", "desirability"), 
# selection_method=c("nonadapt", 'SMED', 'ALC_all_best', 'max_des_red_all_best'),
# design=c('sFFLHD', 'sFFLHD', 'sFFLHD', 'sFFLHD'),
# des_func='des_func_grad_norm2_mean',
objs <- c("nonadapt","nonadapt","desirability","desirability",
          "desirability", "desirability", "desirability")
selection_methods <- c("nonadapt","nonadapt", 'ALC_all_best',
                       'max_des_red_all_best', 'max_des_red_all_best',
                       'SMED', 'max_des_all_best')
designs <- c('sFFLHD_Lflex', "sobol", 'sFFLHD_Lflex', 'sFFLHD_Lflex', 'sFFLHD_Lflex',
             'sFFLHD_Lflex', 'sFFLHD_Lflex')
des_funcs <- c('des_func_grad_norm2_mean','des_func_grad_norm2_mean',
               'des_func_grad_norm2_mean','des_func_mean_grad_norm2',
               'des_func_grad_norm2_mean','des_func_grad_norm2_mean',
               'des_func_grad_norm2_mean')


run_test <- function(funcstring, reps, batches, D, L, stage1batches,
                     seed_start, design_seed_start, startover=FALSE) {
  # print("c1 doesn't exist, creating new")
  if (Sys.info()['sysname'] == "Windows") {
    parallel_cores <- 'detect-1'
  } else {
    which_matches <- which(substr(commandArgs(),1,18) == "number_of_threads=")
    if (length(which_matches) == 1) {
      parallel_cores <- as.integer(substr(commandArgs()[which_matches], 19, 21))
    } else {
      parallel_cores <- 1
    }
  }
  c1 <- compare.adaptR6$new(func=funcstring, reps=reps, batches=batches, D=D, L=L,
                              n0=0, stage1batches=stage1batches, 
                              obj=objs, 
                              selection_method=selection_methods,
                              design=designs,
                              des_func=des_funcs,
                              actual_des_func=paste0('actual_des_func_grad_norm2_mean_', funcstring),
                              alpha_des=1, weight_const=0,
                              package="laGP_GauPro_kernel",
                              error_power=2,
                              seed_start=seed_start, design_seed_start=design_seed_start,
                              parallel=T, # always do parallel for temp_save
                              parallel_cores=parallel_cores, save_output=FALSE
  )
  # Check if already saved
  c1_file <- paste0(c1$folder_path, "//object.rds")
  if (file.exists(c1_file) && !startover) { # Load if saved, and recover
    print("c1 already exists, loading")
    c1 <- readRDS(c1_file)
    c1$recover_parallel_temp_save(save_if_any_recovered=TRUE)
  } else { # Otherwise create new
    # Now it is created above and overwritten if not used
    c1$recover_parallel_temp_save(save_if_any_recovered=TRUE)
  }
  # Run all, save temps
  print("Running all c1")
  already_run <- sum(c1$completed_runs)
  c1$run_all(parallel_temp_save=TRUE, noplot=TRUE, run_order="reverse")
  print("Finished c1, saving")
  if (sum(c1$completed_runs) > already_run) {c1$save_self()}
  return(c1)
}

# First runs, 100 reps, all up to 10*D
if (F) {
  reps <- 100
  bran1 <- try(run_test(funcstring='branin', D=2, L=2, batches=10, reps=reps,
                        stage1batches=3, seed_start=100, design_seed_start=1100))
  franke1 <- try(run_test(funcstring='franke', D=2, L=2, batches=10, reps=reps,
                       stage1batches=3, seed_start=200, design_seed_start=1200))
  lim1 <- try(run_test(funcstring='limnonpoly', D=2, L=2, batches=10, reps=reps,
                       stage1batches=3, seed_start=300, design_seed_start=1300))
  beam1 <- try(run_test(funcstring='beambending', D=3, L=3, batches=10, reps=reps,
                       stage1batches=3, seed_start=400, design_seed_start=1400))
  otl1 <- try(run_test(funcstring='OTL_Circuit', D=6, L=4, batches=15, reps=reps,
                       stage1batches=4, seed_start=500, design_seed_start=1500))
  piston1 <- try(run_test(funcstring='piston', D=7, L=5, batches=14, reps=reps,
                       stage1batches=4, seed_start=600, design_seed_start=1600))
  bh1 <- try(run_test(funcstring='borehole', D=8, L=5, batches=16, reps=reps,
                       stage1batches=5, seed_start=700, design_seed_start=1700))
  wing1 <- try(run_test(funcstring='wingweight', D=10, L=5, batches=20, reps=reps,
                       stage1batches=6, seed_start=800, design_seed_start=1800))
}

# Run again with 400 reps and 20*D points
if (F) {
  reps2 <- 400
  bran1 <- try(run_test(funcstring='branin', D=2, L=2, batches=2*10, reps=reps2,
                        stage1batches=3, seed_start=100, design_seed_start=1100))
  franke1 <- try(run_test(funcstring='franke', D=2, L=2, batches=2*10, reps=reps2,
                          stage1batches=3, seed_start=200, design_seed_start=1200))
  lim1 <- try(run_test(funcstring='limnonpoly', D=2, L=2, batches=2*10, reps=reps2,
                       stage1batches=3, seed_start=300, design_seed_start=1300))
  beam1 <- try(run_test(funcstring='beambending', D=3, L=3, batches=2*10, reps=reps2,
                        stage1batches=3, seed_start=400, design_seed_start=1400))
  otl1 <- try(run_test(funcstring='OTL_Circuit', D=6, L=4, batches=2*15, reps=reps2,
                       stage1batches=4, seed_start=500, design_seed_start=1500))
  piston1 <- try(run_test(funcstring='piston', D=7, L=5, batches=2*14, reps=reps2,
                          stage1batches=4, seed_start=600, design_seed_start=1600))
  bh1 <- try(run_test(funcstring='borehole', D=8, L=5, batches=2*16, reps=reps2,
                      stage1batches=5, seed_start=700, design_seed_start=1700))
  wing1 <- try(run_test(funcstring='wingweight', D=10, L=5, batches=2*20, reps=reps2,
                        stage1batches=6, seed_start=800, design_seed_start=1800))
}

# Do 400 reps and now 40*D points. Adding 0 to end of all seeds too.
if (T) {
  reps2 <- 400
  bran1   <- try(run_test(funcstring='branin',      D=2,  L=2, batches=4*10, reps=reps2,
                          stage1batches=3, seed_start=1000, design_seed_start=11000))
  franke1 <- try(run_test(funcstring='franke',      D=2,  L=2, batches=4*10, reps=reps2,
                          stage1batches=3, seed_start=2000, design_seed_start=12000))
  lim1    <- try(run_test(funcstring='limnonpoly',  D=2,  L=2, batches=4*10, reps=reps2,
                          stage1batches=3, seed_start=3000, design_seed_start=13000))
  beam1   <- try(run_test(funcstring='beambending', D=3,  L=3, batches=4*10, reps=reps2,
                          stage1batches=3, seed_start=4000, design_seed_start=14000))
  otl1    <- try(run_test(funcstring='OTL_Circuit', D=6,  L=4, batches=4*15, reps=reps2,
                          stage1batches=4, seed_start=5000, design_seed_start=15000))
  piston1 <- try(run_test(funcstring='piston',      D=7,  L=5, batches=4*14, reps=reps2,
                          stage1batches=4, seed_start=6000, design_seed_start=16000))
  bh1     <- try(run_test(funcstring='borehole',    D=8,  L=5, batches=4*16, reps=reps2,
                          stage1batches=5, seed_start=7000, design_seed_start=17000))
  wing1   <- try(run_test(funcstring='wingweight',  D=10, L=5, batches=4*20, reps=reps2,
                          stage1batches=6, seed_start=8000, design_seed_start=18000))
}
