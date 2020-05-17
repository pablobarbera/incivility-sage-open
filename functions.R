#====================================================================
# Functions to classify incivility in tweets, used in Theocharis et al,
# 2020 Sage Open
# Author: Pablo Barbera
# Last update: 2020/05/14
#====================================================================

############## CLASSIFIER FUNCTIONS ##################
logistic_classifier_lasso <- function(X, y, seed=123, 
                                      upsample=FALSE, downsample=FALSE){
  
  # chooing training and test sets
  set.seed(seed)
  training <- sample(1:length(y), floor(.80 * length(y)))
  test <- (1:length(y))[1:length(y) %in% training == FALSE]
  
  if (upsample){
    # finding large class
    large_class <- which.max(table(y[training]))-1
    # sample size of large class
    n_large_class <- sum(y[training]==large_class)
    # upsampling smaller class to size of large class
    upsample <- sample(training[y[training]!=large_class],
                       n_large_class, replace=TRUE)
    # putting both together
    training <- c(training[y[training]==large_class],
                  upsample)
  }  
  if (downsample){
    # finding small class
    small_class <- which.min(table(y[training]))-1
    # sample size of saall class
    n_small_class <- sum(y[training]==small_class)
    # downsampling larger class to size of small class
    downsample <- sample(training[y[training]!=small_class],
                         n_small_class, replace=TRUE)
    # putting both together
    training <- c(training[y[training]==small_class],
                  downsample)
  }    
  
  # choosing lambda with cross-validation
  lasso <- glmnet::cv.glmnet(x=X[training,],
                             y=y[training],
                             alpha=1,
                             nfold=5,
                             family="binomial")
  
  # out-of-sample accuracy
  preds <- predict(lasso, X[test,], type="response")
  
  
  message("Accuracy on test set=", round(accuracy(preds>.50, y[test]),3))
  message("Precision on test set (cat 0)=", round(precision(preds<.50, y[test]==0),3))
  message("Recall on test set (cat 0)=", round(recall(preds<.50, y[test]==0),3))
  message("Precision on test set (cat 1)=", round(precision(preds>.50, y[test]),3))
  message("Recall on test set (cat 1)=", round(recall(preds>.50, y[test]),3))
  message("AUC=", sprintf('%0.3f', pROC::auc( as.vector((preds>.50)*1), 
                                              as.vector((y[test])*1 ))))
  
  # from the different values of lambda, let's pick the best one
  best.lambda <- which(lasso$lambda==lasso$lambda.min)
  beta <- lasso$glmnet.fit$beta[,best.lambda]
  
  # most predictive features
  df <- data.frame(coef = as.numeric(beta),
                   word = names(beta), stringsAsFactors=F)
  
  df <- df[order(df$coef),]
  df <- df[df$coef!=0,]
  message("Value = 0\n")
  message(paste0(df$word[1:50], collapse=", "))
  message("Value = 1")
  df <- df[order(df$coef, decreasing=TRUE),]
  message(paste0(df$word[1:50], collapse=", "))
  
  return(lasso)
  
}

predict_incivility <- function(text, old_dfm, classifier){
  
  # create dfm
  text <- corpus(gsub('@[0-9_A-Za-z]+', '@', text))
  newdfm <- create_test_dfm(old_dfm, text, verbose=FALSE)
  
  # create matrix
  Xnew <- as(newdfm, "dgCMatrix")
  
  # predict values
  preds <- predict(classifier, Xnew, type="response")
  return(as.numeric(preds))
  
}


############## TEXT ANALYSIS FUNCTIONS ##################

create_test_dfm <- function(dfm, corpus, verbose=TRUE){

  # DFM: old dfm
  # corpus: new corpus of documents
  toks <- tokens(corpus, remove_numbers=TRUE, remove_url=TRUE)
  toks <- tokens_remove(toks, "\\p{Z}", valuetype = "regex")
  new.dfm <- dfm(toks, ngrams=1, stem=TRUE,
                 remove=stopwords("english"), verbose=verbose)
  new.dfm <- dfm_match(new.dfm, features=featnames(dfm))
  
  return(new.dfm)
}

############## PERFORMANCE METRICS ##################

## function to compute accuracy
accuracy <- function(ypred, y){
    return(
      sum(ypred==y)/length(y)
      )
}
# function to compute precision
precision <- function(ypred, y){
  tab <- table(ypred, y)
  return((tab[2,2])/(tab[2,1]+tab[2,2]))
}
# function to compute recall
recall <- function(ypred, y){
  tab <- table(ypred, y)
  return(tab[2,2]/(tab[1,2]+tab[2,2]))
}






