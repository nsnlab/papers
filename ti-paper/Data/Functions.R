## Libraries used for data analyses
#Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = "true") 
#remotes::install_github("https://github.com/cran/retimes")
# load libraries
library("readr")
library(plyr)
library("Hmisc")
library("ggpubr")
library("gridExtra")
library(psych)
library(psycho)
library(gmodels)
#install.packages("tidyverse")
library(dplyr)
library(psyphy)
library(gridExtra)
library(emmeans)
library(pander)
library(reshape2)
library(corrplot)
library(lme4)
library(car)
library(lmerTest)
library(formattable)
library(afex)
library("ppcor")
library(ggeasy)
library(rstan)
library(brms)
library(bayestestR)
library(see)
library(coda)
library(tidybayes)
library(RColorBrewer)
library(sjPlot)
library(retimes)
#library(WRS2)

## Useful functions for data analyses

# --- Standard error ----
se <- function(x) sqrt(var(x)/length(x))  

# --- One-sample t-test --------
# Calculates one sample t-tes from a dataframe.
# Use in combination with ddply
# e.g. = ddply(df, .(group var1, group var2, group var3), t.test.plyr, "var to calculate")

# one-sample t-test calculated against 0
# type can be any type taken by t.test

t.test.plyr <- function(x, var, mean=0, alternative = type){
  y <- rep(NA,11)
  y[6] <- nrow(x)[1]              # count observations
  if(nrow(x) < 2) return(y)       # exits if too less observations
  res <- t.test(x[var], mu=mean, alternative=type)  # doing the test
  
  y[1] <- res$statistic           # extract values of interest
  y[2] <- res$p.value      
  y[3] <- res$estimate     
  y[4] <- res$conf.int[1]  
  y[5] <- res$conf.int[2]  
  y[7] <- res$parameter    
  y[8] <- res$method       
  y[9] <- res$alternative  
  y[10] <- res$null.value   
  res$sig <-  NA
  
  if (as.numeric(res$p.value) < 0.05) {  #if significant, uncorrected, add single asterix
    res$sig <- '*'}
  y[11] <- res$sig
  names(y) <- c("statistic","p.value","estimate","conf.int1", "conf.int2", "nobs","dof","method","alternative","null.value","sig")
  return(y)
}


t.test_acc.plyr <- function(x, var, alternative = type){
  y <- rep(NA,11)
  y[6] <- nrow(x)[1]              # count observations
  if(nrow(x) < 2) return(y)       # exits if too less observations
  res <- t.test(x[var], mu=mean, alternative=type)  # doing the test
  
  y[1] <- res$statistic           # extract values of interest
  y[2] <- res$p.value      
  y[3] <- res$estimate     
  y[4] <- res$conf.int[1]  
  y[5] <- res$conf.int[2]  
  y[7] <- res$parameter    
  y[8] <- res$method       
  y[9] <- res$alternative  
  y[10] <- res$null.value   
  res$sig <-  NA
  
  if (as.numeric(res$p.value) < 0.05) {  #if significant, uncorrected, add single asterix
    res$sig <- '*'}
  y[11] <- res$sig
  names(y) <- c("statistic","p.value","estimate","conf.int1", "conf.int2", "nobs","dof","method","alternative","null.value","sig")
  return(y)
}


# --- FDR corrected p-values for one-sample t-tests ---------
# Give as input the output from t.test.plyr above. It will apply FDR correction to all p-values and mark significance to use for plotting

ost_FDR <-  function(x){
  x$FDR <- x$p.value
  x$FDR <- p.adjust(x$FDR, method = "fdr", n = (sum(!is.na(x$FDR))))
  
  x$sig <- NA
  for (r in 1:nrow(x)) {
    if (as.numeric(x$p.value[r]) < 0.05) {  #if significant, uncorrected, add single asterix
      if (!is.na(x$FDR[r])) {
        if (as.numeric(x$FDR[r]) < 0.05) {
          x$sig[r] <- '**'}
        else
          x$sig[r] <- '*'}
    }
  }
  return(x)
}

# ---- Correlations between two variables in a dataframe - to be used with ddply so results can be provided split by variables of interest
corrgroup <- function(x, var1, var2){
  COR <- cor(x[[var1]], x[[var2]])
  p.value <- cor.test(x[[var1]], x[[var2]])$p.value        
            
  return(data.frame(COR, p.value))
}

# ---- Partial Correlations between two variables in a dataframe - to be used with ddply so results can be provided split by variables of interest
pp.corrgroup <- function(x, var1, var2, cov1){
  COR <-  pcor.test(x[[var1]], x[[var2]], x[[cov1]])$estimate
  p.value <- pcor.test(x[[var1]], x[[var2]], x[[cov1]])$p.value
  return(data.frame(COR, p.value))
}

# ---- Robust Correlations between two variables in a dataframe - to be used with ddply so results can be provided split by variables of interest
robcorrgroup <- function(x, var1, var2){
  COR <- pbcor(x[[var1]], x[[var2]], beta = 0.2)$cor
  p.value <- pbcor(x[[var1]], x[[var2]], beta = 0.2)$p.value        
  
  return(data.frame(COR, p.value))
}

# ---- FDR corrected p-values for connectivity analysis in the hippocampus - exclude conditions when seed and target are the same
hipp_ost_FDR <-  function(x, seeds, targets){
  
  x$FDR <- x$p.value
  x$FDR[x[[seeds]] == x[[targets]]]<- NA
  
  x$FDR <- p.adjust(x$FDR, method = "fdr", n = (sum(!is.na(x$FDR))))
  
  x$sig <- NA
  
  for (r in 1:nrow(x)) {
    if (as.numeric(x$p.value[r]) < 0.05) {  #if significant, uncorrected, add single asterix
      if (!is.na(x$FDR[r])) {
        if (as.numeric(x$FDR[r]) < 0.05) {
          x$sig[r] <- '**'}
        else
          x$sig[r] <- '*'}
    }
  }
  
  return(x)
}


# --- Function to summarize correlation outputs
flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame(
    row = rownames(cormat)[row(cormat)[ut]],
    column = rownames(cormat)[col(cormat)[ut]],
    cor  =(cormat)[ut],
    p = pmat[ut]
  )
}

# ----- Plotting Functions ----------

theme_clean <- function() {
  theme_minimal(base_family = "Helvetica") +
    theme(panel.border = element_blank(), 
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", color = NA),
          plot.title = element_text(face = "bold"),
          axis.title = element_text(face = "bold"),
          strip.text = element_text(face = "bold", size = rel(0.8), hjust = 0),
          legend.title = element_blank(),
          axis.text = element_text(size = 12), 
          #axis.title = element_text(size = 14),
          legend.text = element_text(size = 12), 
    )
}



# --- Get legend from the last plot to use as a common legend
# Useful when combining multiple plots with grid.arrange. The legend becomes its own object and can have an independent size associated with it.

get_legend<-function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}


# --- Define breaks for x-y plots
get_breaks <- function(n = NULL, by = NULL, from = NULL, to = NULL){
  breaks <- ggplot2::waiver()
  if(!is.null(n)){
    breaks  <- get_breaks_number(n = n)
  }
  else if(is.numeric(by)){
    breaks <- get_breaks_position(by = by, from = from, to = to)
  }
  breaks
}


# --- Set the number of breaks
get_breaks_number <- function(n){
  scales::breaks_extended(n = n)
}

# --- Set breaks using increasing step
# Adapted from scales::breaks_extended
get_breaks_position <- function(by, from = NULL, to = NULL){
  by_default <- by
  from_default <- from
  to_default <- to
  function(x,  by = by_default, from = from_default, to = to_default) {
    x <- x[is.finite(x)]
    if (length(x) == 0) {
      return(numeric())
    }
    rng <- range(x)
    if( rng[1] > 0 & is.null(from)) from <- 0
    xmin <- ifelse(is.null(from), floor(rng[1]), from)
    xmax <- ifelse(is.null(to), rng[2], to)
    seq(from = xmin, to = xmax, by = by)
  }
}




# --- PPI functions --------------
# Plot one sample t-tests in matrix format
plot_ost <- function(ppiStats, seeds, targets, fill, upper, star, var1){
  
  
  #ppiStats[[fill]][ppiStats[[seeds]] == ppiStats[[targets]]] <- NA 
  
  p <- ggplot(data = ppiStats, aes(x=(ppiStats[[seeds]]), y=(ppiStats[[targets]]), fill=as.numeric(ppiStats[[fill]]))) + 
    geom_tile(color = "white") +
    scale_fill_gradientn(colors = c("#5172a3","#f7f7f7","#ec6e14"), 
                         limits=c(-(upper),upper), name="Change in\nConnectivity") +
    ggtitle(paste0(var1)) + 
    xlab('Seed') + ylab('Target') +
    #geom_text(aes(label = sig, x = (ppiStats[[seeds]]), y = (ppiStats[[targets]])), na.rm = TRUE, show.legend = FALSE) +
    # Remove panel background
    theme(axis.text.x = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),
          axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
          axis.title.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
          axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
          panel.background = element_blank())
  
  if (star == 1) {
    p <- p + geom_text(aes(label = sig, x = (ppiStats[[seeds]]), y = (ppiStats[[targets]])), size = 12, na.rm = TRUE, show.legend = FALSE)
  }
  
  return(p)
  
}

# --- Get stats after LMM and emmeans --------------
get_ppi_stats_fromEmmeans <- function(contrastMatrix, var1, seeds, targets){
  ### INPUT:
  # contrastMatrix --> contrast matric from emmeans
  # var 1 = stim type 1 - 2; e.g contrast=="Sham - TI"
  
  ### OUTPUT:
  # ppiStats  --> a data.frame with the FDR corrected p value per seed-target comparison and * to indicate < .05
  ps <- substitute(var1)
  stats.ppi <- contrastMatrix$contrasts %>% summary() %>% as.data.frame()
  stats.ppi <- subset(stats.ppi, eval(ps))
  
  
  
  stats.ppi[[seeds]] <- as.character(stats.ppi[[seeds]])
  stats.ppi[[targets]] <- as.character(stats.ppi[[targets]])
  stats.ppi$p.value[stats.ppi[[seeds]] == stats.ppi[[targets]]]<- NA
  
  stats.ppi$sig <- NA
  
  for (r in 1:nrow(stats.ppi)) {
    if (as.numeric(stats.ppi$p.value[r]) < 0.05) {  #if significant
      stats.ppi$sig[r] <- '*'}
  }
  
  return(stats.ppi)
}


# --- 
get_ppi_stats_fromEmmeans_hipp <- function(contrastMatrix, var1, seeds, targets){
  ### INPUT:
  # contrastMatrix --> contrast matric from emmeans
  # var 1 = stim type 1 - 2; e.g contrast=="Sham - TI"
  
  ### OUTPUT:
  # ppiStats  --> a data.frame with the FDR corrected p value per seed-target comparison and * to indicate < .05
  ps <- substitute(var1)
  stats.ppi <- contrastMatrix$contrasts %>% summary() %>% as.data.frame()
  
  stats.ppi <- subset(stats.ppi, eval(ps))
  #stats.ppi <- stats.ppi[!is.na(stats.ppi$estimate),] 
  
  
  stats.ppi[[seeds]] <- as.character(stats.ppi[[seeds]])
  stats.ppi[[targets]] <- as.character(stats.ppi[[targets]])
  stats.ppi$p.value[stats.ppi[[seeds]] == stats.ppi[[targets]]] <- NA

  stats.ppi$sig <- NA

  for (r in 1:nrow(stats.ppi)) {
    if (!is.na(stats.ppi$estimate[r])) {
      if (as.numeric(round(stats.ppi$p.value[r]),digits=2) <= 0.05) {  #if significant
        stats.ppi$sig[r] <- '*'}
    }
   
  }

  return(stats.ppi)
}

# --- Plot PPI ----------
plot_meanPPI <- function(ppiStats, seeds, targets, fill, upper, star, var1, var2){
  
  # if the order of the variables is not alphabetic, meaning var1 > var2, then multiply estimate by -1 to get the right sign for the estimate
  if (var1 > var2) {
    ppiStats[[fill]] <- ppiStats[[fill]]*(-1)
  }
  
  
  ppiStats[[fill]][ppiStats[[seeds]] == ppiStats[[targets]]] <- NA 
  
  p <- ggplot(data = ppiStats, aes(x=(ppiStats[[seeds]]), y=(ppiStats[[targets]]), fill=ppiStats[[fill]])) + 
    geom_tile(color = "white") +
    scale_fill_gradientn(colors = c("#5172a3","#f7f7f7","#ec6e14"), 
                         limits=c(-(upper),upper), name="Change in\nConnectivity") +
    ggtitle(paste0( var1, " > ", var2)) + 
    xlab('Seed') + ylab('Target') +
    #geom_text(aes(label = sig, x = (ppiStats[[seeds]]), y = (ppiStats[[targets]])), na.rm = TRUE, show.legend = FALSE) +
    # Remove panel background
    theme(axis.text.x = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),
          axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
          axis.title.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
          axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
          panel.background = element_blank())
  
  if (star == 1) {
    p <- p + geom_text(aes(label = sig, x = (ppiStats[[seeds]]), y = (ppiStats[[targets]])), size = 12, na.rm = TRUE, show.legend = FALSE)
  }
  
  return(p)
  
}

# --- Plot PPI one-sample t-test ----------
plot_hipp_ost <- function(ppiStats, seeds, targets, fill, upper, star, var1){
  
  
  ppiStats[[fill]][ppiStats[[seeds]] == ppiStats[[targets]]] <- NA 
  

  
  p <- ggplot(data = ppiStats, aes(x=(ppiStats[[seeds]]), y=(ppiStats[[targets]]), fill=as.numeric(ppiStats[[fill]]))) + 
    geom_tile(color = "white") +
    scale_fill_gradientn(colors = c("#5172a3","#f7f7f7","#ec6e14"), 
                         limits=c(-(upper),upper), name="Change in\nConnectivity") +
    ggtitle(paste0(var1)) + 
    xlab('Seed') + ylab('Target') +
    #geom_text(aes(label = sig, x = (ppiStats[[seeds]]), y = (ppiStats[[targets]])), na.rm = TRUE, show.legend = FALSE) +
    # Remove panel background
    theme(axis.text.x = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),
          axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
          axis.title.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
          axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
          panel.background = element_blank())
  
  if (star == 1) {
    p <- p + geom_text(aes(label = sig, x = (ppiStats[[seeds]]), y = (ppiStats[[targets]])), size = 12, na.rm = TRUE, show.legend = FALSE)
  }
  
  return(p)
  
}

##### spatial maps cadaver ------

estimate_amp_by_distance <- function(df,target_distance, target_depth) {
  data_for_distance <- df %>% 
    filter(distance == target_distance) %>%
    arrange(depth)
  
  # approx() is one way to do a linear interpolation
  approx(data_for_distance$depth, data_for_distance$mv_env_amp_norm, xout = target_depth)$y
}


estimate_amp_by_depth <- function(target_depth, target_distance) {
  data_for_depth <- amp_interp_depth %>% 
    filter(depth == target_depth) %>%
    arrange(distance)
  approx(data_for_depth$distance, data_for_depth$mv_env_amp_norm, xout = target_distance)$y
}


HF_estimate_amp_by_distance <- function(df,target_distance, target_depth) {
  data_for_distance <- df %>% 
    filter(distance == target_distance) %>%
    arrange(depth)
  
  # approx() is one way to do a linear interpolation
  approx(data_for_distance$depth, data_for_distance$mv_env_max_norm, xout = target_depth)$y
}


HF_estimate_amp_by_depth <- function(target_depth, target_distance) {
  data_for_depth <- amp_interp_depth %>% 
    filter(depth == target_depth) %>%
    arrange(distance)
  approx(data_for_depth$distance, data_for_depth$mv_env_max_norm, xout = target_distance)$y
}


##### Multiple scatter plots ------
scatter_fun <- function(x, y, xname, title, df) {
  
  if (x == "meanRespTypePerc") {
    b1 = 10; b2 = 30; l1 = 25; l2 = 80} else if (x == "medianRT") {
      b1 = 2; b2 = 2; l1 = 1.5; l2 = 8} else {
        b1 = 0.5; b2 = 2; l1 = 1.8; l2 = 3.5
      }
  
  p <- ggscatter(df, x=x, y=y,
                 add = "reg.line", 
                 add.params = list(color = "black", fill = "lightgray"),
                 conf.int = TRUE,
                 cor.coef = TRUE, cor.method = "pearson",
                 xlab = xname, ylab = "BOLD (% signal change)") + 
    scale_y_continuous(limits =  c(-.5, 1)) + 
    scale_x_continuous(breaks = get_breaks(by = b1, from = b2), limits =  c(l1, l2)) +
    theme(plot.title = element_text(color="black", size=14, face="bold", hjust = 0.5),
          axis.text.x = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),
          axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
          axis.title.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
          axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
          panel.background = element_blank()) + ggtitle(title)
  return(p)
}


scatter_fun_subset <- function(x, y, xname, region, title, df) {
  
  if (x == "meanRespTypePerc") {
    b1 = 10; b2 = 30; l1 = 25; l2 = 80} else if (x == "medianRT") {
      b1 = 2; b2 = 2; l1 = 1.5; l2 = 8} else {
        b1 = 0.5; b2 = 2; l1 = 1.8; l2 = 3.5
      }
  
  p <- ggscatter(subset(df, ROI==region), x=x, y=y,
                 add = "reg.line", 
                 add.params = list(color = "black", fill = "lightgray"),
                 conf.int = TRUE,
                 cor.coef = TRUE, cor.method = "pearson",
                 xlab = xname, ylab = "BOLD (% signal change)") + 
    scale_y_continuous(limits =  c(-.5, 1)) + 
    scale_x_continuous(breaks = get_breaks(by = b1, from = b2), limits =  c(l1, l2)) +
    theme(plot.title = element_text(color="black", size=14, face="bold", hjust = 0.5),
          axis.text.x = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),
          axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
          axis.title.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
          axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
          panel.background = element_blank()) + ggtitle(title)
  return(p)
}


## Normalise by total - EF

normalise_by_total <- function(var1, var2, var3, df) {
  # var1 = median
  # var 2 = ROI
  # var 3 = VolBrain
  
  tot_vol <- df[[var3]][df[[var2]]=="Ant"] +  df[[var3]][df[[var2]]=="Mid"] +  df[[var3]][df[[var2]]=="Post"]
  
  Ant_w <-  df[[var1]][df[[var2]]=="Ant"]*df[[var3]][df[[var2]]=="Ant"] / tot_vol 
  Mid_w <- df[[var1]][df[[var2]]=="Mid"]*df[[var3]][df[[var2]]=="Mid"] / tot_vol
  Pot_w <- df[[var1]][df[[var2]]=="Post"]*df[[var3]][df[[var2]]=="Post"] / tot_vol
  
  tot_w <- mean(Ant_w+Mid_w+Pot_w)
  return(tot_w)
  
}



scatter_fun2 <- function(x, y, ROIy, xname, miny, maxy, df) {
  xlabt=xname
  ylabt=paste("Norm. BOLD -", ROIy, "Hipp", sep=" ")
  p <- ggscatter(df, x=x, y=y,
                 add = "reg.line", 
                 add.params = list(color = "black", fill = "lightgray"),
                 conf.int = TRUE,
                 cor.coef = TRUE, cor.method = "pearson") + 
    scale_y_continuous(limits =  c(miny, maxy)) + 
    xlab(xlabt) + 
    ylab(ylabt) +
    theme(plot.title = element_text(color="black", size=14, face="bold", hjust = 0.5),
          axis.text.x = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),
          axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
          axis.title.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
          axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
          panel.background = element_blank()) 
  return(p)
}

scatter_fun3 <- function(x, y, ROIy, xname, miny, maxy, df) {
  xlabt=xname
  ylabt=paste("Norm. BOLD -", ROIy, "Hipp", sep=" ")
  COR <- pbcor(df[[x]], df[[y]], beta = 0.2)$cor
  p.value <- pbcor(df[[x]], df[[y]], beta = 0.2)$p.value  
  yrng<-range(df[[y]])
  xrng<-range(df[[x]])
  
  p <- ggscatter(df, x=x, y=y,
                 add = "reg.line", 
                 add.params = list(color = "black", fill = "lightgray"),
                 conf.int = TRUE,
                 cor.coef = TRUE, cor.method = "pearson") + 
    scale_y_continuous(limits =  c(miny, maxy)) + 
    xlab(xlabt) + 
    ylab(ylabt) +
    theme(plot.title = element_text(color="black", size=14, face="bold", hjust = 0.5),
          axis.text.x = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),
          axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
          axis.title.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
          axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
          panel.background = element_blank()) +
    annotate(geom = "text", x = xrng[1], y = yrng[2]+0.08, 
             label = paste("rc, R=",round(COR, digits = 2), ",p=",round(p.value, digits = 2)), hjust=0, vjust=0.2)
  return(p)
}



### Standard Plots
### 
plotstandard <- function(df, yvar, ytitle){

p <- ggplot(data = df, aes(x = StimType, y = .data[[yvar]], fill = StimType)) +
  geom_boxplot(alpha=0.6, outlier.shape = NA, notch=TRUE) + 
  theme(plot.title = element_text(color="black", size=14, face="bold", hjust = 0.5),
        axis.text.x = element_text(color = "grey20", size = 14, angle = 0, face = "bold"),
        axis.text.y = element_text(color = "grey20", size = 12, angle = 0, face = "plain"),  
        axis.title.x = element_blank(),
        axis.title.y = element_text(color = "grey20", size = 14, angle = 90, face = "bold"),
        legend.text = element_blank(),
        legend.background = element_blank(),
        legend.key=element_blank(),
        panel.background = element_blank(),
        legend.title=element_blank()) + 
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(strip.text.x = element_text(size = 14), legend.position = "none", 
        strip.text.y = element_text(size = 20)) + ggtitle("") + scale_fill_manual(values = c("#747674", "#941701"), name = "", labels = c("Sham", "TI 1:3"))  + 
  scale_y_continuous(name = ytitle) 



return(p)

}

