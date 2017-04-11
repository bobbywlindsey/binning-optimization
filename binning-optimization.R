robustFtest = function(obs_vector, orig_df) {
  tryCatch(ftest(big_model, lm(obs_vector ~., data = orig_df))$p_value,
           warning = function(w) {print(paste("some warning", x)); ftest(big_model, lm(obs_vector ~., data = orig_df))$p_value},
           error = function(e) {0}) 
} 

get_optimal_bins = function(bin_proposals, big_model, obs_vector, df, cat_feature) {
  p_values = list()
  i = 1
  for (proposal in bin_proposals) {
    orig_df = df
    # perform F-test
    applied_proposal = as.factor(proposal[unlist(cat_feature)])
    most_frequent_level = names(which.max(table(applied_proposal)))
    applied_proposal = relevel(applied_proposal, most_frequent_level)
    cat_feature_name = names(cat_feature)
    orig_df[cat_feature_name] = NULL
    orig_df[cat_feature_name] = applied_proposal
    
    #small_model = lm(obs_vector ~., data = orig_df)
    #p_values[[i]] = ftest(big_model, small_model)$p_value
    
    p_values[[i]] = robustFtest(obs_vector, orig_df)
    i = i + 1
  }
  
  best_p_value_index = which.max(p_values)
  best_p_value = p_values[best_p_value_index][[1]]
  optimal_bins = bin_proposals[best_p_value_index][[1]]
  return(list(best_p_value = best_p_value, optimal_bins = optimal_bins))
}

search_optimal_bins = function(cat_feature, big_model, obs_vector, df, threshold = 0.23, print = FALSE) {
  # must start at 2 otherwise contrast issue with just one group
  n = length(levels(unlist(cat_feature)))
  # caution: if choosing n bins, this will error if big model only
  # has one independent variable
  # always n-1 so that small_model has less coefficients than big_model
  bin_range = 2:(n-1)
  cat(paste("Searching through", sum(sapply(bin_range, function(k) Strlng2(n, k))) , "binning scenarios...", "\n"))
  # initialize variables
  optimal_bins_results = list() 
  best_bin_number = NULL
  best_p_value = 0
  best_optimal_bins = NULL
  # loop through every bin number and get optimal bin proposals
  for (i in 1:length(bin_range)) {
    k = bin_range[i]
    proposals = get_bin_proposals(levels(unlist(cat_feature)), k)
    results = get_optimal_bins(proposals, big_model, obs_vector, df, cat_feature)
    p_value = results$best_p_value
    optimal_bins = results$optimal_bins
    optimal_bins_results[[i]] = list(num_bins = k, p_value = p_value)
    # update values if p_value higher than the one we
    # already have
    if (p_value > best_p_value) {
      best_bin_number = k
      best_p_value = p_value
      best_optimal_bins = optimal_bins
    }
  }
  if (print == TRUE) {print(do.call(rbind, optimal_bins_results))}
  return(list(best_bin_number = k, best_p_value = best_p_value, best_optimal_bins = best_optimal_bins))
}

apply_optimal_bins = function(df, optimal_bins_list) {
  for (i in 1:length(df)) {
    cat = df[[i]]
    df[i] = as.factor(optimal_bins_list[[i]][df[[i]]])
  }
  return(df)
}