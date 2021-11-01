#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    observeEvent(input$show, {
        showModal(modalDialog(
            title = "Language and Subject Matter",
            "Users are advised that some of the material in the LGBTQ+ AV text c
ollection contain descriptions of discrimination and expressions of hate, violen
ce, death and disease, mental distress, and other trauma. The archive user will
also encounter many uplifting records of individual and collective courage, of d
ignity, humor, and community creativity! But the user should be prepared to enco
unter difficult content. The materials reflect a range of experiences, viewpoint
s, and time periods. It is possible that users may experience distress when enco
untering terminology that may have been deliberately derogatory, ill-informed, o
r is now deemed outdated.",
            easyClose = TRUE
        ))
    })
    observeEvent(input$Redirect,{
        if(input$Redirect){
            browseURL("https://ls-shiny-prod.uwm.edu/collections_as_data/code/rshiny_dashboard/corporaexplorer/app/")
        }
    })
    

})
