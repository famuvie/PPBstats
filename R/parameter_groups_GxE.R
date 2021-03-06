#' Get matrix with variables in column and effect in row from check_model_GxE
#'
#' @description
#' \code{parameter_groups_GxE} gets matrix with variables in column and effect in row
#'
#' @param list_out_check_model_GxE A list whose elements are output from \code{\link{check_model_GxE}}
#'  
#' @param parameter parameter on which to get the matrix
#' 
#' @return 
#' The function returns a data frame with variables in column and effect of paramters in row
#' 
#' @author Pierre Riviere
#' 
#' @seealso \code{\link{parameter_groups}}
#'
parameter_groups_GxE = function(
  list_out_check_model_GxE,
  parameter
  ){

  # 1. Prepare data set ----------
  n_G = n_E = n_varG = NULL
  for(i in 1:length(list_out_check_model_GxE)){
    n_G = c(n_G, names(list_out_check_model_GxE[[i]]$GxE$ANOVA$germplasm_effects$effects))
    n_varG = c(n_varG, names(list_out_check_model_GxE[[i]]$GxE$ANOVA$germplasm_effects$intra_variance))
    n_E = c(n_E, names(list_out_check_model_GxE[[i]]$GxE$ANOVA$location_effects$effects))
  }
  n_G = unique(n_G)
  n_E = unique(n_E)
  n_varG = unique(n_varG)
  
  df_G = matrix(NA, ncol = length(list_out_check_model_GxE), nrow = length(n_G))
  colnames(df_G) = names(list_out_check_model_GxE)
  rownames(df_G) = n_G
  
  df_E = matrix(NA, ncol = length(list_out_check_model_GxE), nrow = length(n_E))
  colnames(df_E) = names(list_out_check_model_GxE)
  rownames(df_E) = n_E
  
  df_varG = matrix(NA, ncol = length(list_out_check_model_GxE), nrow = length(n_varG))
  colnames(df_varG) = names(list_out_check_model_GxE)
  rownames(df_varG) = n_varG
  
  for(i in 1:length(list_out_check_model_GxE)){
    g = list_out_check_model_GxE[[i]]$GxE$ANOVA$germplasm_effects$effects
    df_G[names(g),i] = g
    vg = list_out_check_model_GxE[[i]]$GxE$ANOVA$germplasm_effects$intra_variance
    df_varG[names(vg),i] = vg
    e = list_out_check_model_GxE[[i]]$GxE$ANOVA$location_effects$effects
    df_E[names(e),i] = e
  }
  
  if(parameter == "germplasm") { out = df_G }
  if(parameter == "var_intra_germplasm") { out = df_varG }
  if(parameter == "location") { out = df_E }
  
  # 3. Return results
  attributes(out)$PPBstats.object = "parameter_groups_GxE"
  return(out)
}
