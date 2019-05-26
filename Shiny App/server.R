#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tm)
library(stringr)
library(tm)
library(SnowballC)
library(RWeka)
library(corpus)
library(tidyr)

# Load the data:
load("onegram.Rdata")
load("bigram.Rdata")
load("trigram.Rdata")
load("fourgram.Rdata")

# Function to remove the last word from a string:
rm_firstword <- function(phrase){
    #phrase <- sub(phrase, pattern = "'", replacement = "")
    sub(phrase, pattern = "^\\S* ", replacement = "")}

# Function to predict the next word based on the input phrase:
predict <- function(phrase){
    # Preprocess the input phrase:
    phrase <- tolower(phrase)
    phrase <- gsub("[-.?!]", " ", gsub("(?![-.?!'])[[:punct:]]", " ",
                                       phrase, perl=T))
    phrase <- gsub("  ", " ", phrase)
    
    dtm_4sub <- NA
    dtm_3sub <- NA
    dtm_2sub <- NA
    dtm_1sub <- NA
    
    # Create a variable wordlength:
    wordlength <- length(unlist(strsplit(phrase, split=" ")))
    
    # If the input phrase is longer than 3, keep only the last three:
    if(wordlength>3){
        phrase <- paste(rev(unlist(strsplit(phrase, split=" ")))[3],
                        rev(unlist(strsplit(phrase, split=" ")))[2],
                        rev(unlist(strsplit(phrase, split=" ")))[1], sep=" ")
        wordlength <- length(unlist(strsplit(phrase, split=" ")))
    }
    
    if(wordlength == 3){
        dtm_4sub <- freq_4[freq_4$phrase == phrase,]
        
        if(nrow(dtm_4sub)!=0){
            dtm_4sub$score <- dtm_4sub$count / freq_3[freq_3$original==phrase,"count"]}
        
        phrase <- rm_firstword(phrase)
        wordlength <- length(unlist(strsplit(phrase, split=" ")))}
    
    if(wordlength == 2){
        dtm_3sub <- freq_3[freq_3$phrase == phrase,]
        
        
        if(nrow(dtm_3sub)!=0){
            dtm_3sub$score <- 0.4 *(dtm_3sub$count/freq_2[freq_2$original==phrase,"count"])}
        
        phrase <- rm_firstword(phrase)
        wordlength <- length(unlist(strsplit(phrase, split=" ")))}
    
    if(wordlength == 1){
        dtm_2sub <- freq_2[freq_2$phrase == phrase,]
        
        if(nrow(dtm_2sub)!=0){
            dtm_2sub$score <- 0.4*0.4* (dtm_2sub$count/freq_1[freq_1$original==phrase,"count"])}
        
        phrase <- ""
        wordlength <- length(unlist(strsplit(phrase, split=" ")))}
    
    if(wordlength == 0){
        dtm_1sub <- freq_1
        dtm_1sub$score <- 0.4*0.4*0.4*dtm_1sub$count / sum(dtm_1sub$count)}
    
    new <- rbind(dtm_4sub, dtm_3sub, dtm_2sub, dtm_1sub)
    
    new <- aggregate(new$score, by=list(word=new$nextword), FUN=sum)
    new <- subset(new, !(new$word %in% stopwords(kind="en")))
    
    as.character(new[which.max(new$x),1])
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$return_output <- renderText({
        withProgress(message = 'Just a second, we are predicting the next word', value = 0, {
        a <- predict(input$input_phrase)})
        a})
    
    output$return_input <- renderText({input$input_phrase})
    output$yourinput <- renderText({paste("Your input phrase is:")})
    output$youroutput <- renderText({"The predicted next word is:"})                        
})
