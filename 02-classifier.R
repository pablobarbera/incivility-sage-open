#====================================================================
# Run machine learning classifier
# Author: Pablo Barbera
# Last update: 2017/10/23
#====================================================================

# loading packages and functions
library(readr)
library(quanteda)
source("functions.R")

#######################################################################
##### CREATING BAG OF WORDS DFM ######
#######################################################################

# loading training dataset
d <- read_csv("data/training-data.csv", col_types="cccc")

# adding synthetic labels
d2 <- read_csv("data/synthetic-labels.csv", col_types="cccc")
d <- rbind(d, d2)

# clean text and create DFM
d$text <- gsub('@[0-9_A-Za-z]+', '@', d$text)
corp <- corpus(d$text)
dfm <- dfm(corp, remove_url=TRUE, remove=stopwords("english"),
           ngrams=1, verbose=TRUE, stem=TRUE, 
           remove_numbers=TRUE)
dfm <- dfm_trim(dfm, min_docfreq = 2, verbose=TRUE)

save(dfm, file="data/dfm-file.rdata")
topfeatures(dfm, n=50)

#######################################################################
### INCIVILITY CLASSIFIER: LASSO
#######################################################################

# creating outcome variable
d$uncivil_dummy <- ifelse(d$uncivil=="yes", 1, 0)
mean(d$uncivil_dummy)

# bag-of-words classifier
X <- as(dfm, "dgCMatrix")
lasso <- logistic_classifier_lasso(X=X, y=d$uncivil_dummy, downsample = TRUE)
save(lasso, file="data/lasso-classifier.rdata")

