
library(readxl)
library(dplyr)
library(tm)
library(tmap)
library(topicmodels)
library(reshape2)
library(ggplot2)
library(wordcloud)
library(pals)
library(corporaexplorer)
library(quanteda)
require(topicmodels)
library(lda)
library(LDAvis)
library(tidyr)
library(stringr)

#Load metadata
setwd("~/collections-as-data/metadata")
metadata <- purrr::map_dfr(list.files(pattern="*.xlsx"), readxl::read_excel)
df <- purrr::map_dfr(list.files(pattern="*.xlsx"), readxl::read_excel)
df$Year <- as.integer(sub('.*?\\b(\\d{4})\\b.*', '\\1', paste(df$Title, df$Date)))
df2 = data.frame(column=df$Year)
df<-cbind(df,df2)
table(df$Year)
head(df)
dim(df)#192 by 13

#Merge with transcripts
setwd("~/collections-as-data/transcripts/")
file.list <- list.files(path = ".", pattern="*.txt", full.names=TRUE)
df_transcript <- data.frame( files= sapply(file.list, 
                                           FUN = function(x)readChar(x, file.info(x)$size)),
                             stringsAsFactors=FALSE)
names(df_transcript)[1]<-"Text"

df_transcript$Collection <- substr(file.list, start=3, stop=11)
df_transcript$Filename <- substr(file.list, start=3, stop=100)

df$DigitalObjectName = sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(df$Digital.ID))
df_transcript$DigitalObjectName = sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(df_transcript$Filename))
joined_metadata <- merge(df,df_transcript, by="DigitalObjectName")
dim(joined_metadata)#149 by 17

#Create corpus file
corpus <- Corpus(DataframeSource(data.frame(doc_id=joined_metadata$DigitalObjectName,text=joined_metadata$Text)))
processedCorpus <- tm_map(corpus, content_transformer(tolower))
english_stopwords <- readLines("https://slcladal.github.io/resources/stopwords_en.txt", encoding = "UTF-8")

processedCorpus <- tm_map(processedCorpus, removeWords, english_stopwords)
processedCorpus <- tm_map(processedCorpus, removePunctuation, preserve_intra_word_dashes = TRUE)
processedCorpus <- tm_map(processedCorpus, removeNumbers)
processedCorpus <- tm_map(processedCorpus, stemDocument, language = "en")
processedCorpus <- tm_map(processedCorpus, stripWhitespace)
length(processedCorpus)

#Generate initial test topic model
minimumFrequency <- 5
DTM <- DocumentTermMatrix(processedCorpus, control = list(bounds = list(global = c(minimumFrequency, Inf))))
# have a look at the number of documents and terms in the matrix
dim(DTM) # 149 times 3622
which(slam::row_sums(DTM)==0) #49 and 114
#Excluding those in the joined metadata where rowsums are zero
rowsumzero<-as.matrix(which(slam::row_sums(DTM)==0))
joined_metadata<- joined_metadata[-rowsumzero,]

sel_idx <- slam::row_sums(DTM) > 0
DTM <- DTM[sel_idx, ]
dim(DTM) #147 by 3622

# number of topics
K <- 7
# set random number generator seed
set.seed(9161)
# compute the LDA model, inference via 1000 iterations of Gibbs sampling
topicModel <- LDA(DTM, K, method="Gibbs", control=list(iter = 500, verbose = 25))

# have a look a some of the results (posterior distributions)
tmResult <- posterior(topicModel)
# format of the resulting object
attributes(tmResult)

nTerms(DTM)              # lengthOfVocab #3622

beta <- tmResult$terms   # get beta from results
dim(beta)                # K distributions over nTerms(DTM) terms
#7 times 3622
rowSums(beta)            # rows in beta sum to 1

nDocs(DTM)               # size of collection #147

theta <- tmResult$topics 
dim(theta)  #147 by 7

#***#

# re-rank top topic terms for topic names
topicNames <- apply(lda::top.topic.words(beta, 10, by.score = T), 2, paste, collapse = " ")

# What are the most probable topics in the entire collection?
topicProportions <- colSums(theta) / nrow(DTM)  # mean probablities over all paragraphs
names(topicProportions) <- topicNames     # assign the topic names we created before
sort(topicProportions, decreasing = TRUE) # show summed proportions in decreased order

countsOfPrimaryTopics <- rep(0, K)
names(countsOfPrimaryTopics) <- topicNames
for (i in 1:nrow(DTM)) {
  topicsPerDoc <- theta[i, ] # select topic distribution for document i
  # get first element position from ordered list
  primaryTopic <- order(topicsPerDoc, decreasing = TRUE)[1] 
  countsOfPrimaryTopics[primaryTopic] <- countsOfPrimaryTopics[primaryTopic] + 1
}
sort(countsOfPrimaryTopics, decreasing = TRUE)

for (K in 4:15){
  
  set.seed(9161)
  # compute the LDA model, inference via 1000 iterations of Gibbs sampling
  topicModel <- LDA(DTM, K, method="Gibbs", control=list(iter = 500, verbose = 25))
  
  # have a look a some of the results (posterior distributions)
  tmResult <- posterior(topicModel)
  # format of the resulting object
  attributes(tmResult)
  
  nTerms(DTM)              # lengthOfVocab #2291
  
  beta <- tmResult$terms   # get beta from results
  dim(beta)                # K distributions over nTerms(DTM) terms
  #8 times 2291
  rowSums(beta)            # rows in beta sum to 1
  
  nDocs(DTM)               # size of collection #92
  
  theta <- tmResult$topics 
  dim(theta)               #92 times 8, nDocs(DTM) distributions over K topics
  
  rowSums(theta)[1:10]     # rows in theta sum to 1
  
  terms(topicModel, 10)
  
  
  # visualize topics as word cloud
#  topicToViz <- 8 # change for your own topic of interest
  # select to 40 most probable terms from the topic by sorting the term-topic-probability vector in decreasing order
#  top40terms <- sort(tmResult$terms[topicToViz,], decreasing=TRUE)[1:40]
#  words <- names(top40terms)
  # extract the probabilites of each of the 40 terms
#  probabilities <- sort(tmResult$terms[topicToViz,], decreasing=TRUE)[1:40]
  # visualize the terms as wordcloud
#  mycolors <- brewer.pal(8, "Dark2")
#  wordcloud(words, probabilities,min.freq=3,random.order = FALSE, color = mycolors)
  
  ### LDAvis ###
  
  rCorpus<-unlist(processedCorpus)
  
  # tokenize on space and output as a list:
  doc.list <- strsplit(rCorpus, "[[:space:]]+")
  
  # compute the table of terms:
  term.table <- table(unlist(doc.list))
  term.table <- sort(term.table, decreasing = TRUE)
  
  # remove terms that are stop words or occur fewer than 5 times:
  del <- names(term.table) %in% english_stopwords | term.table < 5
  term.table <- term.table[!del]
  
  vocab <- names(term.table)
  
  # now put the documents into the format required by the lda package:
  get.terms <- function(x) {
    index <- match(x, vocab)
    index <- index[!is.na(index)]
    rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
  }
  documents <- lapply(doc.list, get.terms)
  
  
  # Compute some statistics related to the data set:
  D <- length(documents)  # number of documents (95)
  W <- length(vocab)  # number of terms in the vocab (2946)
  doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document [1385, 1443, 924,998, ...]
  N <- sum(doc.length)  # total number of tokens in the data (110,518)
  term.frequency <- as.integer(term.table)  # frequencies of terms in the corpus [2256, 1607, 1318,...]
  
  # MCMC and model tuning parameters:
#  K <- 8
  G <- 5000
  alpha <- 0.02
  eta <- 0.02
  
  # Fit the model:
  library(lda)
  set.seed(357)
  t1 <- Sys.time()
  fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                     num.iterations = G, alpha = alpha, 
                                     eta = eta, initial = NULL, burnin = 0,
                                     compute.log.likelihood = TRUE)
  t2 <- Sys.time()
  t2 - t1  # about 11 minutes on laptop
  
  theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
  phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))
  
  corpusReviews <- list(phi = phi,
                        theta = theta,
                        doc.length = doc.length,
                        vocab = vocab,
                        term.frequency = term.frequency)
outputname <-paste("~/collections-as-data/code/rshiny_dashboard/lda_topics/lda_",K,"_terms.RDS",sep="")
json <- createJSON(phi = corpusReviews$phi, 
                   theta = corpusReviews$theta, 
                   doc.length = corpusReviews$doc.length, 
                   vocab = corpusReviews$vocab, 
                   term.frequency = corpusReviews$term.frequency)
saveRDS(json,outputname)


################### July 27

col<-max(table(max.col(theta, ties.method="first")))
ash<-data.frame(matrix(, nrow = K, ncol =col ))

## Table to see which documents belongs to different topics
for (i in 1:K){
  aa<-max.col(theta, ties.method="first")==i
  ash[i,]<-c(which(aa==TRUE),rep(NA,col-length(which(aa==TRUE))))
  row.names(ash)[i] <- paste("Topic ", i)
}

ash<-data.frame(matrix(, nrow = K, ncol =col ))
for (i in 1:K){
  aa<-max.col(theta, ties.method="first")==i
#  ash[i,]<-c(which(aa==TRUE),rep(NA,col-length(which(aa==TRUE))))
  ash[i,]<-c(subset(row.names(DTM),max.col(theta, ties.method="first")==i),rep(NA,col-length(which(aa==TRUE))))
    row.names(ash)[i] <- paste("Topic ", i)
}
#ash[] <-  ash2[as.matrix(ash)]
#ash<-ash %>%
#  as.data.frame %>%
#  mutate(Topic_no = str_c('Topic', row_number()), .before = 1) %>% 
#  pivot_longer(cols = -Topic_no, values_drop_na = TRUE) %>%   
#  group_by(Topic_no) %>%
#  group_by(grp = as.integer(gl(n(), 2, n())), .add = TRUE) %>%  
#  summarise(Object_Transcripts = toString(value), .groups = 'drop_last')
#View(ash)

#for (i in 1:nrow(ash)){
#  if ((ash[i,2]>1)==TRUE){
#    ash[i,1] = ""
#    
#  }
#}

#View(ash)
Table_13<-ash[,-2]
#View(Table_13)
tableoutputname <-paste("~/collections-as-data/code/rshiny_dashboard/lda_topics/lda_",K,"_table.RDS",sep="")
saveRDS(Table_13,tableoutputname)

}