#====================================================================
# Compute predicted values on any set of tweets
# Author: Pablo Barbera
# Last update: 2018/08/19
#====================================================================

library(quanteda)
source("functions.R")

# loading classifier and dfm
load("data/lasso-classifier.rdata")
load("data/dfm-file.rdata")

# predicting a single tweet
text <- "politicians are morons"

predict_incivility(text="politicians are awful",
                   old_dfm = dfm,
                   classifier = lasso)

# predicting multiple tweets
df <- data.frame(
  text = c( # no incivility
            "I respect your opinion", "you are an example of leadership",
            # some incivility
            "oh shut up", "you are a traitor",
            # very uncivil
            "what an asshole and a loser", "spineless piece of shit")
)
predict_incivility(df$text, 
                   old_dfm = dfm,
                   classifier = lasso)



