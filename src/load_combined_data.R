# ================================================
# Script Name: data_wrangling.R
# Author: Brian Pile
# Date Created: 2025-06-08
# Last Updated: 2025-06-08
#
# Purpose:
#   To load the combined LIV, OSA, and MPD data using a dedicated script. After loading,
#   any new column creation and formatting is performed. Finally, the data is
#   checked for missing, duplicate, and unexpected values.
#
# Inputs:
#   - Processed data - combined LIV, OSA, and MPD csv files
#
# Outputs:
#   - Output data - a wide summary data frame with parameter extraction and
#     pass/fail results
#
# ================================================

# suppressPackageStartupMessages(library(tidyverse))
# library(here)
# library(loadr)
# source(here("local_config.R"))
source(here("local_scripts/local_combine_data_funcs.R"))


# load and condition combined data ----

## MPD IV ----
filename_iv = paste(work_order, "MPD IV combined data.csv")
if (!file.exists(here("data/processed", filename_iv))) {
  message("Wrangling MPD!!!")
  combine_mpd(filename = here("data/processed", filename_iv))
}

df_mpd_iv = data.table::fread(
  file = here("data/processed", filename_iv),
  colClasses = c(
    bi_status = "factor",
    ch = "character"
  )
) |> 
  as_tibble() |> 
  mutate(dut_id = paste(sep = "-", fc_id, ch), .after = ch) |> 
  mutate(bi_status = factor(bi_status, levels = c("pre", "post")))

## LIV ----
filename_liv = paste(work_order, "LIV combined data.csv")
if (!file.exists(here("data/processed", filename_liv))) {
  message("Wrangling LIV!!!")
  combine_liv(filename = here("data/processed", filename_liv))
}

df_liv = data.table::fread(
  file = here("data/processed", filename_liv),
  colClasses = c(
    bi_status = "factor",
    ch = "character"
  )
) |> 
  as_tibble() |> 
  mutate(dut_id = paste(sep = "-", fc_id, ch), .after = ch) |> 
  mutate(bi_status = fct_relevel(bi_status, "pre", "post"))


## OSA ----
filename_osa = paste(work_order, "OSA combined data.csv")
if (!file.exists(here("data/processed", filename_osa))) {
  message("Wrangling OSA!!!")
  combine_osa(filename = here("data/processed", filename_osa))
}

df_osa = data.table::fread(
  file = here("data/processed", filename_osa),
  colClasses = c(
    bi_status = "factor",
    ch = "character"
  )
) |> 
  as_tibble() |> 
  mutate(dut_id = paste(sep = "-", fc_id, ch), .after = ch) |> 
  mutate(bi_status = factor(bi_status, levels = c("pre", "post")))

# cleanup some variables
rm(filename_iv, filename_liv, filename_osa)


# Filtering ----
# - Retain only the last measurement made, no repeats allowed
# - The last measurement should correspond to the largest test_id increment

df_mpd_iv = df_mpd_iv |> 
  filter(
    .by = c(bi_status, dut_id),
    test_id == max(test_id)
  )

df_liv = df_liv |> 
  filter(
    .by = c(bi_status, dut_id),
    test_id == max(test_id)
  )

df_osa = df_osa |> 
  filter(
    .by = c(bi_status, dut_id, If),
    test_id == max(test_id)
  )
