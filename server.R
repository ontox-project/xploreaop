## load helpers
library(here)
source(here::here("helpers.R"))
#library(easyPubMed)

## Load data

No_biomarkers <- load_data_relations()
With_biomarkers_inbetween <- load_data_relations_biomarkers_as_inbetween_nodes()
With_biomarkers_end <- load_data_relations_biomarkers_as_end_nodes()

shinyServer(function(input, output, session) {

  selected_dataset <- reactive({
    switch(input$network_type,
           "No biomarkers" = No_biomarkers,
           "With biomarkers as inbetween nodes" = With_biomarkers_inbetween,
           "With biomarkers as end nodes" = With_biomarkers_end)
  })


 aop_dataset <- reactive({

   selected_dataset() |>
     group_by(aop) |>
     nest()



 #   data_steat <- selected_dataset() |>
 #     dplyr::filter(aop == "steatosis")
 #
 #   data_choles <- selected_dataset() |>
 #     dplyr::filter(aop == "cholestasis")
 #
 #
 # switch(input$aop_type,
 #        "steatosis" = data_steat,
 #        "cholestasis" = data_choles)
})

 data_per_aop <- reactive({

   if(input$aop_type == "steatosis"){
     df <- aop_dataset()$data[[1]]
   }


   if(input$aop_type == "cholestasis"){
     df <- aop_dataset()$data[[2]]
   }

   df

 })



  edges <- reactive({
   data_per_aop() |>
      dplyr::filter(compound %in% input$chemical)|>
      dplyr::mutate(title=doi)
  })

  observe({
    node_choices <- c(edges()$from, edges()$to) %>% unique()

    updateCheckboxGroupInput(session, "Node_select",
                             label = paste("nodes"),
                             choices = node_choices,
                             selected = node_choices)
  })

  chemicals <- reactive({
    data_per_aop()$compound |> unique() |> sort()
  })

  observe({
    updateSelectInput(session, "chemical",
                      label = "Compound",
                      choices = chemicals(),
                      selected = NULL)
  })


  nodes <- reactive({
    data.frame(id = c(edges()$from, edges()$to))%>%
      distinct()|>
      dplyr::mutate(group = case_when(
        id %in% chemicals()  ~ "chemical",
        id %in% outcomes ~ "outcome",
        id %in% biomarkers ~ "biomarker",
        TRUE ~ "ME"
      )) %>%
      dplyr::mutate(title=id)|>
      dplyr::mutate(label=id)|>
      dplyr::mutate(color.background = case_when(
        group=="chemical" ~ "lightblue",
        group=="ME" ~ "lightgreen",
        group=="outcome" ~ "red",
        group=="biomarker" ~ "yellow"),
        color.highlight = color.background, color.border = "grey") %>%
      dplyr::mutate(shape = case_when(
        group=="chemical" ~ "dot",
        group=="ME" ~ "diamond",
        group=="outcome" ~ "triangle",
        group=="biomarker" ~ "ellipse")) %>%
      dplyr::filter(id %in% input$Node_select)
    })


  # Download associated data
  output$download <- downloadHandler(
    filename = function(){paste0(paste(input$chemical, collapse="_"), ".csv")},
    content = function(fname){
      write.csv(edges(), fname)
    }
  )


  # Plot NLP network
  output$chem <- renderVisNetwork({
    visNetwork(nodes(), edges(), width = "100%" , height = 1080) %>%
      visEdges(arrows = "to") %>%
      visEvents(select = "function(edges) {
                Shiny.onInputChange('current_edge_selection', edges.edges);
                ;}") %>%
      visGroups(groupname = "chemical", color = "lightblue", shape = "dot") %>%
      visGroups(groupname = "ME", color = "lightgreen", shape = "diamond") %>%
      visGroups(groupname = "biomarker", color = "yellow", shape = "ellipse") %>%
      visGroups(groupname = "outcome", color = "red", shape = "triangle") %>%
      visLegend(width = 0.1, position = "right", main = "Legend")  %>%
      visOptions(autoResize = TRUE)

  })

  # Display PubMed abstract associated to PMID containing selected relationship
  DOI <- reactive({
    if (!is.null(input$current_edge_selection) &
        length(input$current_edge_selection)==1) {
      info <- data.frame(edges())
      DOI <- info[info$id == input$current_edge_selection, "doi"]
    }
    else{
      DOI <- NULL
    }
    return(DOI)
  })

  output$abstract <- renderPrint({
    get_article_info(DOI())
  })



})

