#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinyjs)
library(corporaexplorer)
library(LDAvis)

#Loading primary corpus file used by Corpora Explorer.
corpus <- readRDS("saved_corporaexplorerobject_no_timeline.rds")

# Define UI for application that draws a histogram
shinyUI(


    fluidPage(
    useShinyjs(),
    # Application title
    titlePanel("LGBTQ+ AV Mining"),
    fluidRow(id='corporaexplorer',explore(corpus,ui_options = list(font_size = "14px"), plot_options = list(plot_size_factor=2.5, colours=c("green", "orange", "blue", "gray","yellow", "purple")))),
    # Sidebar with a slider input for number of topic followed by user selectable documentation.
    sidebarLayout(
        sidebarPanel(
          #Provide content warning pop-up.
            actionButton("show", "Content Warning"),
            #Acknowledge content warning button.
            div(id="contentwarningbox",checkboxInput(inputId="contentwarning", "Acknowledge Content Warning", value = FALSE, width = NULL)),
            #LDA Topic slider bar.
            div(id="topicselector", sliderInput("nTerms", "Number of topics to display", min = 4, max = 15, value = 5)),
            div(id="documentation",       
                radioButtons("documentationradio", "Help Guide:",
                                                       c("Corpora Explorer", "Topic Model")
                             ),
                  div(id="CorporaHelp",
                  column(2,imageOutput("image1", height = 201),actionButton("help1", "Review transcript of objects within each collection."),
                         imageOutput("image2", height = 201),actionButton("help2","Searching for terms across each collection."))
                  ),
                  div(id="TopicModelHelp",
                    column(2,imageOutput("image3", height = 201),actionButton("help3", "Selection of amount of Topics."),
                           imageOutput("image4", height = 201),actionButton("help4","Identification of term distribution across topics."))
                  )
                
            )
        ),

        
        # Primary navigation panel of RShiny dashboard.
        mainPanel(
                      tabsetPanel(
                          
                          tabPanel("Topic modeling visualization",{
                                    div(id="chart",
                                      visOutput('myChart'),
                                      DT::dataTableOutput('topicTable')
                                    )  
                                   }),
                          tabPanel("Topic Modeling", conditionalPanel("output.show2",print("TEST2")),
                                   shinyjs::hidden(
                                       div(id = "advanced", 
                                           plotOutput('timelinechart')
                                       )  
                                   )
                                   ),
                          tabPanel("About", p('
                                    The UWM Libraries house important archives holding historical and contemporary LGBTQ+ materials. Included are rich records of LGBTQ+ communities in Milwaukee, Wisconsin, and the Midwest generally. Not only do these archives contain textual documents such as community newsletters, advocacy group records, and personal letters-they also contain audiovisual materials. Examples include local television news and radio broadcasts, early LGBTQ+ community cable programming, and videorecorded oral histories.
                                    '))
                      )
      
 
        )
    )
)

)
