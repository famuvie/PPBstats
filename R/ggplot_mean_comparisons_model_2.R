#' Get ggplot from mean_comparisons_model_2
#'
#' @description
#' \code{ggplot_mean_comparisons_model_2} returns ggplot from \code{\link{mean_comparisons_model_2}}
#' 
#' @param x, y outputs from \code{\link{mean_comparisons_model_2}}
#' 
#' @details See \code{\link{get_ggplot}}
#' 
#' @return See \code{\link{get_ggplot}}
#' 
#' @seealso 
#' \itemize{
#' \item \code{\link{get_ggplot}}, 
#' \item \code{\link{mean_comparisons_model_2}}
#' }
#'
plot.mean_comparisons_model_2 <- function(
  x,
  y = NULL,
  ggplot.type = c("biplot-alpha-beta", "barplot"),
  nb_parameters_per_plot = 8
) {
  
  # 1. Error message
  ggplot.type <- match.arg(ggplot.type, several.ok = FALSE)
  
  if( is.null(y) & ggplot.type == "biplot-alpha-beta" ) {
    stop("With ggplot.type = \"biplot-alpha-beta\", y can not be NULL.")
  }
  
  if (!is.null(y) && !inherits(y, "mean_comparisons_model_2")) {
    stop(substitute(y), "must come from PPBstats::check_model from model_2.")
  }
  
  data_Mpvalue = x$Mpvalue
  data = x$mean.comparisons
  
  if(ggplot.type == "barplot") {  
    data = arrange(data, median)  
    data$max = max(data$median, na.rm = TRUE)
    data$split = add_split_col(data, nb_parameters_per_plot)
    data_split = plyr:::splitter_d(data, .(split))  
    
    para.name = unlist(strsplit(as.character(data[1, "parameter"]), "\\["))[1]
    
    out = lapply(data_split, function(dx){
      p = ggplot(dx, aes(x = reorder(parameter, median), y = median)) + geom_bar(stat = "identity")
      p = p + geom_text(aes(x = reorder(parameter, median), y = median/2, label = groups), angle = 90, color = "white")
      p = p + ggtitle(paste(para.name, "\n alpha = ", dx[1, "alpha"], "; alpha correction :", dx[1, "alpha.correction"]))
      p = p + xlab("") + theme(axis.text.x = element_text(angle = 90)) + ylab("") + coord_cartesian(ylim = c(0, dx[1,"max"]))
      return(p)
    })
    out = list(out)
    names(out) = para.name
  }
  
  
  # 2.5. biplot-alpha-beta ----------
  if(ggplot.type == "biplot-alpha-beta"){
    
    a = data
    test_a = unlist(strsplit(as.character(a[1,"parameter"]), "\\["))[1]
    if( test_a != "alpha" ){ stop("With ggplot.type = \"biplot-alpha-beta\", data must come from get.mean.comparisons with paramater = \"alpha\".") }
    a$germplasm = gsub("alpha", "", a$parameter)
    colnames(a)[which(colnames(a) == "parameter")] = "parameter_a"
    colnames(a)[which(colnames(a) == "median")] = "alpha_i"
    
    b = y$mean.comparisons
    test_b = unlist(strsplit(as.character(b[1,"parameter"]), "\\["))[1]
    if( test_b != "beta" ){ stop("With ggplot.type = \"biplot-alpha-beta\", data_2 must come from get.mean.comparisons with paramater = \"beta\".") }
    b$germplasm = gsub("beta", "", b$parameter)
    colnames(b)[which(colnames(b) == "parameter")] = "parameter_b"
    colnames(b)[which(colnames(b) == "median")] = "beta_i"
    
    
    ab = join(a, b, "germplasm")
    ab=ab[which(!is.na(ab$beta_i) & !is.na(ab$alpha_i)),]
    ab$germplasm = gsub("\\[", "", ab$germplasm)
    ab$germplasm = gsub("\\]", "", ab$germplasm)
    
    ab$split = add_split_col(ab, nb_parameters_per_plot)
    d_ab = plyr:::splitter_d(ab, .(split))
    
    xlim = range(ab$alpha_i)
    ylim = range(ab$beta_i)
    
    out = lapply(d_ab,function(y){
      p = ggplot(y, aes(x = alpha_i, y = beta_i, label = germplasm)) + coord_cartesian(xlim = xlim, ylim = ylim, expand = FALSE)
      p = p + geom_text() + geom_hline(yintercept = 0)
    })
  }
  
  # return results
  return(out)
}

