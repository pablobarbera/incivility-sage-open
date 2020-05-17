# Replication materials: Theocharis et al, 2020, Sage Open

Replication materials for "[The Dynamics of Political Incivility on Twitter](https://journals.sagepub.com/doi/full/10.1177/2158244020919447)", by Yannis Theocharis, Pablo Barberá, Zoltán Fazekas, and Sebastian Adrian Popa, published in __Sage Open__.

> __Abstract:__
> Online incivility and harassment in political communication have become an important topic of concern among politicians, journalists, and academics. This study provides a descriptive account of uncivil interactions between citizens and politicians on Twitter. We develop a conceptual framework for understanding the dynamics of incivility at three distinct levels: macro (temporal), meso (contextual), and micro (individual). Using longitudinal data from the Twitter communication mentioning Members of Congress in the United States across a time span of over a year and relying on supervised machine learning methods and topic models, we offer new insights about the prevalence and dynamics of incivility toward legislators. We find that uncivil tweets represent consistently around 18% of all tweets mentioning legislators, but with spikes that correspond to controversial policy debates and political events. Although we find evidence of coordinated attacks, our analysis reveals that the use of uncivil language is common to a large number of users.


This README file provides an overview of the materials We are releasing in addition to the article:

- `code/01-creating-synthetic-labels.R` contains the code we used to create the synthetic labels to expand the training dataset. We used Google's Perspective API to create high-quality features that allowed us to expand our labeled set of tweets at a low cost. See article for more details.
- `code/02-classifier.R` contains the code to train the incivility classifier we use in the paper.
- `code/03-predict.R` contains examples showing how to predict incivility on new, unseen tweets.
- `data` is a folder with the training dataset, document-feature matrix, and classifier objects.


# How to use our classifier

The code we provide allows any researcher to fit our incivility classifier to new tweets (English only) without having to re-train the classifier.

<p>First, load the quanteda package (which we use for preprocessing the text), the classifier functions available in <code>functions.r</code> and the DFM/classifier objects.</p>

<pre class="r"><code>library(quanteda)
library(glmnet)
source(&quot;functions.R&quot;)
load(&quot;data/lasso-classifier.rdata&quot;)
load(&quot;data/dfm-file.rdata&quot;)</code></pre>

<p>Here’s how to compute the probability that a single tweet is uncivil, according to the definition we use in the paper.</p>

<pre class="r"><code># predicting a single tweet
tweet &lt;- &quot;politicians are morons&quot;
predict_incivility(text=tweet, old_dfm = dfm, classifier = lasso)</code></pre>

<pre><code>## [1] 0.9025192</code></pre>
<p>And here’s how to do the same, but for multiple tweets.</p>
<pre class="r"><code># predicting multiple tweets
df &lt;- data.frame(
  text = c( # no incivility
            &quot;I respect your opinion&quot;, &quot;you are an example of leadership&quot;,
            # some incivility
            &quot;oh shut up&quot;, &quot;you are a traitor&quot;,
            # very uncivil
            &quot;what an asshole and a loser&quot;, &quot;spineless piece of shit&quot;)
)
predict_incivility(df$text, 
                   old_dfm = dfm,
                   classifier = lasso)</code></pre>
                   
<pre><code>## [1] 0.2181500 0.1727687 0.6525642 0.6325972 0.9681808 0.9774939</code></pre>



