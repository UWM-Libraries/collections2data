#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
jscode <- "Shiny.addCustomMessageHandler('mymessage', function(message) {window.location = 'httpss://https://ls-shiny-prod.uwm.edu/collections_as_data/code/rshiny_dashboard/corporaexplorer/app/';});"

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    tags$head(tags$script(jscode)),
    # Application title
    titlePanel("Corpora Explorer - Content Warning"),
    
    # Sidebar with a slider input for number of bins
    
    actionButton("show", "Content Warning"),
    
    checkboxInput("Redirect","Redirect",value = F)
    
))
