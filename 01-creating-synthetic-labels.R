#====================================================================
# Create synthetic labels using Google Perspective API
# Author: Pablo Barbera
# Last update: 2019/10/06
#====================================================================

# loading packages and functions
library(readr)
library(peRspective)
library(quanteda)
source("functions.R")

######################################################################
## PERSPECTIVE SCORES ON EXISTING TRAINING DATASET
######################################################################

# loading existing training dataset, coded on CrowdFlower
d <- read_csv("data/training-data.csv", col_types="cccc")

# enriching with Google Perspective API predictions
# 1) add columns for each category
for (j in peRspective::prsp_models){
  d[,j] <- NA
}
# 2) add predictions for each category
for (i in 1:nrow(d)){
  message(i, '/', nrow(d))
  try(d[i,peRspective::prsp_models] <- prsp_score(d$text[i], 
                                                  languages="en", 
                                                  sleep=1,
                      score_model=peRspective::prsp_models))
  if (i %% 500 == 0){
    write.csv(d, file="data/perspective-scores-training.csv",
              row.names=FALSE)
  }
}

######################################################################
## PERSPECTIVE SCORES ON NEW TRAINING DATASET
######################################################################

# loading random sample of 16K additional tweets
d2 <- read_csv("data/tweets-for-synthetic-training.csv",
               col_types="ccc")

# enriching with Google Perspective API predictions
# 1) add columns for each category
for (j in peRspective::prsp_models){
  d2[,j] <- NA
}

for (i in 1:nrow(d2)){
  message(i, '/', nrow(d2))
  try(d2[i,peRspective::prsp_models] <- prsp_score(d2$text[i], languages="en", sleep=1,
                                                  score_model=peRspective::prsp_models))
  if (i %% 500 == 0){
    write.csv(d2, file="data/additional-perspective-scores.csv",
              row.names=FALSE)
  }
}


######################################################################
## CREATING SYNTHETIC LABELS ON NEW TRAINING DATASET
######################################################################

# training classifier on true labels
d <- read.csv("data/perspective-scores-training.csv",
              stringsAsFactors = FALSE)
d$uncivil_dummy <- ifelse(d$uncivil=="yes", 1, 0)

# creating DFM
train.dfm <- dfm(corpus(d$text), 
                remove_url=TRUE, remove=stopwords("english"),
                ngrams=1, verbose=TRUE, stem=TRUE, 
                remove_numbers=TRUE)

features <- cbind(train.dfm, as.matrix(d[,peRspective::prsp_models]))

lasso <- logistic_classifier_lasso(X=features, y=d$uncivil_dummy)

# predicting on new dataset to get synthetic labels
d2 <- read.csv("data/additional-perspective-scores.csv",
               stringsAsFactors = FALSE)
test.dfm <- create_test_dfm(train.dfm, corpus(d2$text))
features <- cbind(test.dfm, as.matrix(d2[,peRspective::prsp_models]))
preds <- predict(lasso, features, type="class")
d2$uncivil <- ifelse(as.vector(preds)=="1", "yes", "no")

write.csv(d2[,c("uncivil", "id_str", "created_at", "text")],
          file="data/synthetic-labels.csv",
          row.names=FALSE)


