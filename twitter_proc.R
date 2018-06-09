#Xiaohu Zhao (zhao.1722)

# setup & authentication
install.packages('twitteR')
install.packages('tm')
install.packages('XML') 
library(twitteR)
#library(ROAuth)
#setup_twitter_oauth("APIkey","APIsecret","Accesstoken","Accesssecret")

###################################################################################

require(tm)
# download tweets in English
tweets<-searchTwitter('#FridayFeeling', lang="en", n=1000)
# convert tweets into a data frame
tweets_df = twListToDF(tweets)
#write.csv(tweets_df, file = 'D:/fridayfeeling.csv', row.names = F)

# remove retweet entities
rei_clean = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", tweets_df$text)
# remove Atpeople
rei_clean = gsub("@\\w+", "", rei_clean)
# remove punctuation symbols
rei_clean = gsub("[[:punct:]]", "", rei_clean)
# remove numbers
rei_clean = gsub("[[:digit:]]", "", rei_clean)
# remove links
rei_clean = gsub("http\\w+", "", rei_clean)


# build a corpus
mydata.corpus <- Corpus(VectorSource(rei_clean))

# make each letter lowercase
mydata.corpus <- tm_map(mydata.corpus, tolower) 

# remove punctuation 
mydata.corpus <- tm_map(mydata.corpus, removePunctuation)

# remove generic and custom stopwords
mydata.corpus <- tm_map(mydata.corpus, removeWords, c(stopwords('english'), 'fridayfeeling'))

# build a term-document matrix
mydata.dtm <- TermDocumentMatrix(mydata.corpus)

# inspect the document-term matrix
mydata.dtm

# inspect most popular words
findFreqTerms(mydata.dtm, lowfreq=30)


# remove sparse terms to simplify the cluster plot
mydata.dtm2 <- removeSparseTerms(mydata.dtm, sparse=0.9)

# convert the sparse term-document matrix to a standard data frame
mydata.df <- as.data.frame(inspect(mydata.dtm))

# inspect dimensions of the data frame
nrow(mydata.df)
ncol(mydata.df)


mydata.df.scale <- scale(mydata.df)
d <- dist(mydata.df.scale, method = "euclidean") # distance matrix
fit <- hclust(d, method="ward")
plot(fit) # display dendogram?

groups <- cutree(fit, k=4) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters
rect.hclust(fit, k=4, border="red")
###################################################################################

# sentiment analysis
library(twitteR)
library(plyr)
library(stringr)

setwd("E:/Courses/CSE 5243 Intr Data Mining/Final Project")
source("E:/Courses/CSE 5243 Intr Data Mining/Final Project/scoreSentiment.r")

pos = readLines("positive_words.txt")
neg = readLines("negative_words.txt")

# tweets with colors
red_tweets = searchTwitter("red", n=500, lang="en")
blue_tweets = searchTwitter("blue", n=500, lang="en")
green_tweets = searchTwitter("green", n=500, lang="en")
black_tweets = searchTwitter("black", n=500, lang="en")
white_tweets = searchTwitter("white", n=500, lang="en")
yellow_tweets = searchTwitter("yellow", n=500, lang="en")

# get text
red_txt = sapply(red_tweets, function(x) x$getText())
blue_txt = sapply(blue_tweets, function(x) x$getText())
green_txt = sapply(green_tweets, function(x) x$getText())
black_txt = sapply(black_tweets, function(x) x$getText())
white_txt = sapply(white_tweets, function(x) x$getText())
yellow_txt = sapply(yellow_tweets, function(x) x$getText())

# how many tweets of each color
nd = c(length(red_txt), length(blue_txt), length(green_txt), length(black_txt), length(white_txt), length(yellow_txt))

# join texts
colors = c(red_txt, blue_txt, green_txt, black_txt, white_txt, yellow_txt) 

# apply function score.sentiment
scores = score.sentiment(colors, pos, neg, .progress='text')

# add variables to data frame
scores$color = factor(rep(c("red", "blue", "green", "black", "white", "yellow"), nd))
scores$very.pos = as.numeric(scores$score >= 2)
scores$very.neg = as.numeric(scores$score <= -2)

# how many very positives and very negatives
numpos = sum(scores$very.pos)
numneg = sum(scores$very.neg)

# global score
global_score = round( 100 * numpos / (numpos + numneg) )
###################################################################################

library(ggplot2)

# boxplot
box_color <- matrix(0, nrow = 500, ncol = 6)
#colnames(box_color) <- c("red", "blue", "green", "black", "white", "yellow")
box_color[,c(1)] <- scores$score[c(1:500)]
box_color[,c(2)] <- scores$score[c(501:1000)]
box_color[,c(3)] <- scores$score[c(1001:1500)]
box_color[,c(4)] <- scores$score[c(1501:2000)]
box_color[,c(5)] <- scores$score[c(2001:2500)]
box_color[,c(6)] <- scores$score[c(2501:3000)]

par(mfrow=c(1,6), oma = c(1,1,0,0) + 0.1,  mar = c(3,3,1,1) + 0.1)
boxplot(box_color[,c(1)], col="green", pch=21)
mtext("red", cex=0.8, side=1, line=2)
boxplot(box_color[,c(2)], col="green", pch=21)
mtext("blue", cex=0.8, side=1, line=2)
boxplot(box_color[,c(3)], col="green", pch=21)
mtext("green", cex=0.8, side=1, line=2)
boxplot(box_color[,c(4)], col="green", pch=21)
mtext("black", cex=0.8, side=1, line=2)
boxplot(box_color[,c(5)], col="green", pch=21)
mtext("white", cex=0.8, side=1, line=2)
boxplot(box_color[,c(6)], col="green", pch=21)
mtext("yellow", cex=0.8, side=1, line=2)


# barplot of average score
meanscore = tapply(scores$score, scores$color, mean)
df = data.frame(color=names(meanscore), meanscore=meanscore)
#df$colors <- reorder(df$color, df$meanscore)
colnames(df) = c('color', 'meanscore')
gbar = ggplot(df, aes(x = color, y = meanscore)) + ggtitle('Mean Sentiment Score') +
  theme(plot.title = element_text(size = 14, face = 'bold', vjust = 1), axis.title.x = element_text(vjust = -1))

gbar + geom_bar(stat = 'identity',alpha=0.6)


color_pos = ddply(scores, .(color), summarise, mean_pos=mean(very.pos))
colnames(color_pos) = c('color', 'pos_score')
gbar = ggplot(color_pos, aes(x = color, y = pos_score)) + ggtitle('Positive Sentiment Score') +
  theme(plot.title = element_text(size = 14, face = 'bold', vjust = 1), axis.title.x = element_text(vjust = -1))

gbar + geom_bar(stat = 'identity',alpha=0.6)

color_neg = ddply(scores, .(color), summarise, mean_pos=mean(very.neg))
colnames(color_neg) = c('color', 'neg_score')
gbar = ggplot(color_neg, aes(x = color, y = neg_score)) + ggtitle('Negative Sentiment Score') +
  theme(plot.title = element_text(size = 14, face = 'bold', vjust = 1), axis.title.x = element_text(vjust = -1))

gbar + geom_bar(stat = 'identity',alpha=0.6)

###################################################################################

data <- read.csv('E:/Courses/CSE 5243 Intr Data Mining/Final Project/twitter-airline-sentiment/Tweets.csv')
str(data)
# Proportions of Tweet Sentiments
prop.table(table(data$airline_sentiment))
pie(table(data$airline_sentiment))

# Proportion of Tweets by Airlines
prop.table(table(data$airline))
pie(table(data$airline))

# Percentage Tweets per airline which are of different sentiments
smallData = as.data.frame(prop.table(table(data$airline_sentiment, data$airline)))
colnames(smallData) = c('Sentiment', 'Airline', 'Percentage_Tweets')

gbar = ggplot(smallData, aes(x = Airline, y = Percentage_Tweets, fill = Sentiment)) + ggtitle('Percentage of Tweets each Airline') +
  theme(plot.title = element_text(size = 14, face = 'bold', vjust = 1), axis.title.x = element_text(vjust = -1))

gbar + geom_bar(stat = 'identity',alpha=0.6)

###################################################################################

data_al <- matrix(0, nrow = 14640, ncol = 2)
data_al[,c(1)] <- data$airline_sentiment

pos = readLines("positive_words.txt")
neg = readLines("negative_words.txt")

data$text = gsub("^@\\w+ *", "", data$text)
scores_al = score.sentiment(data$text, pos, neg, .progress='text')


wordsToRemove = c('get', 'cant', 'can', 'now', 'just', 'will', 'dont', 'ive', 'got', 'much')


for(i in 1:14640){
  if(scores_al$score[c(i)] > 0){
    data_al[c(i), c(2)] <- 3
  }
  else if(scores_al$score[c(i)] < 0){
    data_al[c(i), c(2)] <- 1
  }
  else{
    data_al[c(i), c(2)] <- 2
  }
}

count_al = 0
for(j in 1:14640){
  if(data_al[c(j), c(1)] == data_al[c(j), c(2)]){
    count_al <- count_al + 1
  }
}
predict_accuracy = count_al / 14640

count_al = 0
count_nn = 0
for(j in 1:14640){
  if(data_al[c(j), c(1)] == 2){
    count_nn <- count_nn + 1
    if(data_al[c(j), c(1)] == data_al[c(j), c(2)]){
      count_al <- count_al + 1
    }
  }
}
predict_accuracy = count_al / count_nn

###################################################################################
library(tm); library(SnowballC)
library(dplyr)
library(wordcloud)

data$text = gsub("^@\\w+ *", "", data$text)
positive_al = subset(data, airline_sentiment == 'positive')
negative_al = subset(data, airline_sentiment == 'negative')

# build a corpus
aldata.corpus <- Corpus(VectorSource(negative_al$text))

# make each letter lowercase
aldata.corpus <- tm_map(aldata.corpus, tolower) 

# remove punctuation 
aldata.corpus <- tm_map(aldata.corpus, removePunctuation)

# remove generic and custom stopwords
aldata.corpus <- tm_map(aldata.corpus, removeWords, c(stopwords('english'), 'get', 'got', 'much', 'just', 'will', 'ive'))

# build a term-document matrix
aldata.dtm <- TermDocumentMatrix(aldata.corpus)

# inspect the document-term matrix
m = as.matrix(aldata.dtm)

# inspect most popular words
findFreqTerms(aldata.dtm, lowfreq=30)


# remove sparse terms to simplify the cluster plot
aldata.dtm2 <- removeSparseTerms(aldata.dtm, sparse=0.97)

# convert the sparse term-document matrix to a standard data frame
aldata.df <- as.data.frame(inspect(aldata.dtm2))

# inspect dimensions of the data frame
nrow(aldata.df)
ncol(aldata.df)


word_freqs = sort(rowSums(m), decreasing=TRUE) 
# create a data frame with words and their frequencies
freqWords = data.frame(word=names(word_freqs), freq=word_freqs)


wordcloud(freqWords$word, freqWords$freq, random.order = FALSE,
          random.color = FALSE, colors = brewer.pal(8, 'Dark2'))
