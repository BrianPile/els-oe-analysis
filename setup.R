# setup.R - Run this after cloning the repository

# Create necessary directories for the project
dirs <- c("src", "doc", "data/raw", "data/processed")

for (dir in dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    message("Created directory: ", dir)
  } else {
    message("Directory already exists: ", dir)
  }
}


# Create local_config.R if it doesn't exist
config_file = "local_config.R"

if (!file.exists(config_file)) {
  config_lines <- c(
    "# local_config.R - Local settings (DO NOT COMMIT)",
    'work_order = "WOXX-XXXX"'
  )
  
  writeLines(config_lines, config_file)
  message("Created local_config.R with default values.")
} else {
  message("local_config.R already exists.")
}


# Create local_data_wrangling.R if it doesn't exist. This will often need to be
# customized for each work order.
wrangle_file = "local_data_wrangling.R"

if (!file.exists(file.path("src", wrangle_file))) {
  
  code_string =
'# This is an auto-generated data wrangling script. Customize as needed!

#### MPD IV ####
wrangle_mpd = function(filename) {
  iv_files = list.files(
    path = "data/raw",
    pattern = "^\\\\d{2}FC\\\\d{4,5}_CH\\\\d[.]csv$",
    full.names = TRUE,
    recursive = TRUE
  )
  
  df_iv = iv_files |> 
    set_names() |> 
    map(\\(x) load_iv(file = x)) |> 
    list_rbind(names_to = "fullpath") |> 
    select(-fullpath)
  
  data.table::fwrite(df_iv, file = filename)
}

#### LIV ####
wrangle_liv = function(filename) {
  liv_files = list.files(
    path = "data/raw",
    pattern = "_LIV[.]xlsx$|_LIV[.]csv$",
    full.names = TRUE,
    recursive = TRUE
  )
  
  df_liv = liv_files |> 
    set_names() |> 
    map(\\(x) load_liv(file = x)) |> 
    list_rbind(names_to = "fullpath") |> 
    select(-fullpath)
  
  data.table::fwrite(df_liv, file = filename)
}

#### OSA ####
wrangle_osa = function(filename) {
  osa_files = list.files(
    path = "data/raw",
    pattern = "_OSA[.]xlsx$|_OSA[.]csv",
    full.names = TRUE,
    recursive = TRUE
  )
  
  df_osa = osa_files |> 
    set_names() |> 
    map(\\(x) load_osa(file = x)) |> 
    list_rbind(names_to = "fullpath") |> 
    select(-fullpath)
  
  data.table::fwrite(df_osa, file = filename)
}'
  
  writeLines(code_string, "src/local_data_wrangling.R")
  message("Created local_data_wrangling.R with default values.")

} else {
  message(paste(wrangle_file, "already exists."))
}
