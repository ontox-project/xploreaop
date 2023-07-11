#library(shiny)
#library(networkD3)

library(here)
source(
  here::here(
    "helpers.R")
)


library(shinydashboard)



shinyUI(fluidPage(

  titlePanel("xploreaop; A Shiny AOP Explorer"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        inputId = "Node_select",
        label = "Click on the tab 'Select nodes' to select specific nodes to display",
        choices =  ,
        selected = "all",
        width = "100%", inline = TRUE),
      width = 12
    ),
  mainPanel(
      tabsetPanel(
        tabPanel("Chemical Network", width = 5,
                 selectInput(
                   inputId = "network_type",
                   label = "choose either with or without biomarker information",
                   choices = c('With biomarkers as inbetween nodes', "With biomarkers as end nodes", 'No biomarkers'),
                   selected = "No biomarkers",
                   multiple = FALSE
                 ),
                 selectInput(
                   inputId = "aop_type",
                   label = "Chose which AOP you would like to display",
                   choices = c("steatosis", "cholestasis"),
                   selected = "steatosis",
                   multiple = FALSE
                 ),
                 selectInput(
                   inputId = "chemical",
                   label = "Choose chemicals",
                   choices = NULL,
                   selected = NULL,
                   multiple = TRUE
                 ),
                 bsPopover("chemical","Enter chemical(s) of interest", "You can select from the drop-down menu (click inside the box to make it appear) or start typing then select the desired option and press enter. Click on the name of a chemical and press return to remove it.", "right"),
                 downloadButton('download',"Download the data for selected chemicals"),
                 br(),
                 br(),
                 strong("\nHighlight a node and its connections by clicking on it. You can also click and drag to modify its position. Click on a link to see the DOI of the article in which the relationship was found. The corresponding abstract will be displayed below the graph if available (you might need to scroll down). You can zoom in to read details more clearly."),
                 visNetworkOutput("chem", height = "100vh"),
                 htmlOutput("abstract")
                 )

      ), width = 10
    )
  )
)
)

