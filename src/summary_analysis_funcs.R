# parameter extraction ----

## MPD ----
summarize_mpd_data = function(data) {
  df_summary_mpd = data |> 
    group_by(across(!c(voltage, current))) |> 
    summarize(
      Idark = extract_i_from_iv(voltage, current, V0 = -2),
      If_mpd = extract_i_from_iv(voltage, current, V0 = 1),
      .groups = "drop"
    )
  return(df_summary_mpd)
  
}

## LIV ####
summarize_liv_data = function(data) {
  
  If_vec = c(100, 400)*1e-3
  Ix_vec = c(50)*1e-3
  Pop_vec = c(80)*1e-3
  df_summary_liv = data |> 
    group_by(across(!c(current, power, voltage, mpd_current))) |> 
    summarize_raw_liv_data(If_vec, Ix_vec, Pop_vec, Ik1 = 250, Ik2 = 495) |> 
    ungroup() |> 
    mutate(across(matches("^Pf\\d$"), \(x) 10*log10(abs(x)), .names = "{.col}_dBm"), .after = Pf2)
  return(df_summary_liv)
  
}

## OSA ####
# TODO: add Ppk, BW20dB ?

summarize_osa_data = function(data) {
  
  df_summary_osa = data |> 
    group_by(across(!c(wavelength, power))) |> 
    summarize(
      Lp = extract_peak_wav(wavelength, power),
      SMSR = extract_smsr(wavelength, power),
      .groups = "drop"
    )
  
}



## SUMMARY ----
join_the_summaries = function(data1, data2, data3) {
  
  df_summary_osa_wide = data2 |> 
    rename(If_osa = If) |> 
    filter(If_osa %in% c(100e-3, 400e-3)) |> 
    # group_by(dut_id, test_id) |> 
    group_by(dut_id) |> 
    mutate(If_index = seq_along(If_osa),
           If_osa = If_osa/1e-3) |> 
    ungroup() |> 
    pivot_wider(
      names_from = If_index,
      values_from = c(test_id, If_osa, Lp, SMSR),
      names_sep = ""
    ) |> 
    arrange(dut_id)
  
  df_summary = left_join(
    x = data1,
    y = df_summary_osa_wide,
    by = join_by(work_order, bi_status, fc_id, ch, dut_id, temperature),
    suffix = c(".liv", ".osa")
  ) |> 
    arrange(dut_id, bi_status)
  
  df_summary = left_join(
    x = df_summary,
    y = data3,
    by = join_by(work_order, bi_status, fc_id, ch, dut_id, temperature),
    suffix = c(".left", ".mpd")
  )
  
  return(df_summary)
  
}
