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
    
    mainPanel(h1(strong("Content Warning")),
              h3("Users are advised that some of the material in the LGBTQ+ AV text collection contain descriptions of discrimination and expressions of hate, violence, death and disease, mental distress, and other trauma. The archive user will also encounter many uplifting records of individual and collective courage, of dignity, humor, and community creativity! But the user should be prepared to encounter difficult content. The materials reflect a range of experiences, viewpoints, and time periods. It is possible that users may experience distress when encountering terminology that may have been deliberately derogatory, ill-informed, or is now deemed outdated."),
    
    shiny::actionButton(inputId='accept', label="Acknowledge Content Warning", 
                                                onclick ="window.open('https://ls-shiny-prod.uwm.edu/collections_as_data/code/corporaexplorer')"))
    
    
    
))
