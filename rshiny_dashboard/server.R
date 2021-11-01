#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(LDAvis)
library(ggplot2)
library(corporaexplorer)
library(DT)

shinyServer(function(input, output) {

    #Convert topic number slider bar with pre-generated LDA topic models and document lookup charts.
    topicValues <- reactive({
        Value = readRDS(paste("lda_topics/lda_",input$nTerms,"_terms.RDS",sep=""));

    })
    topicDocuments <- reactive({
        Value = readRDS(paste("lda_topics/lda_",input$nTerms,"_table.RDS",sep=""));
        
    })
    
    #Hide topic modeling until content warning acknowledged.
    output$myChart <- renderVis({topicValues()})
    output$topicTable <- DT::renderDataTable({topicDocuments()},options=list(autowidth = TRUE,scrollX = TRUE,dom = 'ft', pageLength = 15, rownames = TRUE))
    hide(id="chart")
    hide(id="topicselector")
    hide(id='corporaexplorerpanel')
    hide(id='documentation')
#    show(id='corporaexplorer')
    hide(id='corporaexplorer',anim=TRUE)
    hide(id='TopicModelHelp')

    shinyjs::onclick("contentwarning",{values$show2 <- TRUE
    return(values$show2)} )
    lda_visualization <- readRDS("lda_topics/lda_4_vis.RDS")
    output$timelinechart <- renderPlot(ggplot(lda_visualization, aes(x=year, y=value, fill=variable)) + 
            geom_bar(stat = "identity") + ylab("proportion") + 
            scale_fill_manual(values = paste0(alphabet(20), "FF"), name = "year") + 
            theme(axis.text.x = element_text(angle = 90, hjust = 1))
    )

    #Enable Topic Modeling after content warning.
    shinyjs::onclick("contentwarning",{
        hide(id="contentwarningbox", anim=TRUE)
        show(id = "chart", anim = TRUE)
        show(id="topicselector", anim=TRUE)
        show(id='corporaexplorerpanel', anim=TRUE)
        show(id='documentation', anim=TRUE)
        shinyjs::toggle(id='corporaexplorer', anim=TRUE)
        shinyjs::toggle(id = "advanced", anim = TRUE)
        })
    shinyjs::onclick("documentationradio",
                     {
                     if(input$documentationradio == "Corpora Explorer") {
                            show(id="CorporaHelp", anim=TRUE)
                            hide(id = "TopicModelHelp", anim = TRUE)
                     } else if (input$documentationradio == "Topic Model"){
                         hide(id="CorporaHelp", anim=TRUE)
                         show(id = "TopicModelHelp", anim = TRUE)
                    }}
    )


    
# Pop up text for Content Warning.    
    
    observeEvent(input$show, {
        showModal(modalDialog(
            title = "Language and Subject Matter",
            "Users are advised that some of the material in the LGBTQ+ AV text collection contain descriptions of discrimination and expressions of hate, violence, death and disease, mental distress, and other trauma. The archive user will also encounter many uplifting records of individual and collective courage, of dignity, humor, and community creativity! But the user should be prepared to encounter difficult content. The materials reflect a range of experiences, viewpoints, and time periods. It is possible that users may experience distress when encountering terminology that may have been deliberately derogatory, ill-informed, or is now deemed outdated.",
            easyClose = TRUE
        ))
    })

########### In app documentation support.
    
    
    output$image1 <- renderImage({
        return(list(
            src = "images/conda_1.png",
            contentType = "image/png",
            alt = "Face", height=200
        ))
    },deleteFile=FALSE)
    output$image2 <- renderImage({
        return(list(
            src = "images/conda_2.png",
            contentType = "image/png",
            alt = "Face", height=200
        ))
    },deleteFile=FALSE)
    output$image3 <- renderImage({
        return(list(
            src = "images/topics_1.png",
            contentType = "image/png",
            alt = "Face", height=200
        ))
    },deleteFile=FALSE)
    output$image4 <- renderImage({
        return(list(
            src = "images/topics_2.png",
            contentType = "image/png",
            alt = "Face", height=200
        ))
    },deleteFile=FALSE)
    observeEvent(input$help1, {
        showModal(modalDialog(
            title = "Use of CorporaExplorer",
            "Individual boxes within each collection indicate a unique object. By clicking on these boxes the full transcript will be available on the right.",            easyClose = TRUE
        ))
    })
    observeEvent(input$help2, {
        showModal(modalDialog(
            title = "Use of Search Terms within CorporaExplorer",
            "Multiple terms can be searched within the corpus. A heat map will be generated across the collection for the density of terms across each object, and by selecting an object links to each reference within the transcript.",            easyClose = TRUE
        ))
    })
    observeEvent(input$help3, {
        showModal(modalDialog(
            title = "Selection of amount of Topics",
            "Using the sliderbar you can select pre-trained LDA models with a variable amount of identified topics.",            easyClose = TRUE
        ))
    })
    observeEvent(input$help4, {
        showModal(modalDialog(
            title = "Identification of term distribution across topics",
            "By mousing over terms within an identified topic LDAvis will identify distribution of that term over other identified topics within this model.",            easyClose = TRUE
        ))
    })
    
})