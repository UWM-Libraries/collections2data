setwd("~/syeda_demo/transcripts/")
#install.packages(c("tm","topicmodels","reshape2","ggplot2","wordcloud","pals"))
library(tm)
library(topicmodels)
library(reshape2)
library(ggplot2)
library(wordcloud)
library(pals)

options(stringsAsFactors = F)         # no automatic data transformation
options("scipen" = 100, "digits" = 4) # supress math annotation
file.list <- list.files(path = ".", pattern="*.txt", full.names=TRUE)
df <- data.frame( files= sapply(file.list, 
                  FUN = function(x)readChar(x, file.info(x)$size)),
                  stringsAsFactors=FALSE)
names(df)[1]<-"text"
df$Filename <- substr(file.list, start=3, stop=100)
#corpus <- Corpus(DataframeSource(df))
corpus <- Corpus(DataframeSource(data.frame(doc_id=df$Filename,text=df$text)))
processedCorpus <- tm_map(corpus, content_transformer(tolower))
english_stopwords <- readLines("https://slcladal.github.io/resources/stopwords_en.txt", encoding = "UTF-8")

processedCorpus <- tm_map(processedCorpus, removeWords, english_stopwords)
processedCorpus <- tm_map(processedCorpus, removePunctuation, preserve_intra_word_dashes = TRUE)
processedCorpus <- tm_map(processedCorpus, removeNumbers)
processedCorpus <- tm_map(processedCorpus, stemDocument, language = "en")
processedCorpus <- tm_map(processedCorpus, stripWhitespace)

minimumFrequency <- 5
DTM <- DocumentTermMatrix(processedCorpus, control = list(bounds = list(global = c(minimumFrequency, Inf))))
# have a look at the number of documents and terms in the matrix
dim(DTM)

sel_idx <- slam::row_sums(DTM) > 0
DTM <- DTM[sel_idx, ]


# number of topics
K <- 20
# set random number generator seed
set.seed(9161)
# compute the LDA model, inference via 1000 iterations of Gibbs sampling
topicModel <- LDA(DTM, K, method="Gibbs", control=list(iter = 500, verbose = 25))

# have a look a some of the results (posterior distributions)
tmResult <- posterior(topicModel)
# format of the resulting object
attributes(tmResult)

nTerms(DTM)              # lengthOfVocab

beta <- tmResult$terms   # get beta from results
dim(beta)                # K distributions over nTerms(DTM) terms

rowSums(beta)            # rows in beta sum to 1

nDocs(DTM)               # size of collection

theta <- tmResult$topics 
dim(theta)               # nDocs(DTM) distributions over K topics

rowSums(theta)[1:10]     # rows in theta sum to 1

terms(topicModel, 10)


# visualize topics as word cloud
topicToViz <- 11 # change for your own topic of interest
# select to 40 most probable terms from the topic by sorting the term-topic-probability vector in decreasing order
top40terms <- sort(tmResult$terms[topicToViz,], decreasing=TRUE)[1:40]
words <- names(top40terms)
# extract the probabilites of each of the 40 terms
probabilities <- sort(tmResult$terms[topicToViz,], decreasing=TRUE)[1:40]
# visualize the terms as wordcloud
mycolors <- brewer.pal(8, "Dark2")
wordcloud(words, probabilities, random.order = FALSE, color = mycolors)