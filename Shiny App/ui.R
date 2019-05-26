#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinycssloaders)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Predict the next word"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       textInput("input_phrase", "Input your text here:"),
    #verbatimTextOutput("value"),
       submitButton(text = "Predict!", icon("bar-chart-o"), width = "100%")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        h4(textOutput("yourinput")),
        h3(textOutput("return_input")),
        h4(textOutput("youroutput")),
        h3(textOutput("return_output"))
    )
  )
))



