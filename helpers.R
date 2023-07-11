## Packages
library(networkD3)
library(visNetwork)
library(igraph, warn.conflicts = FALSE)
library(shiny)
library(rmarkdown)
library(networkD3)
library(tidyverse)
library(igraph)
library(ggraph)
library(tidygraph)
library(htmlwidgets)
library(shinyWidgets)
library(easyPubMed)
library(here)
library(shinyBS)

load_data_relations <- function(){

  # df <- readr::read_csv(
  #   here::here(
  #     "data-raw",
  #     "steatosis_raw_v7_09_06_2022.csv"
  #   )
  #)

  load(here::here(
    "data",
    "data_steat_choles.rda"
  ))

  df <- data_steat_choles

   # df <- xploreaop::data_steat_choles

  ## mutations on the data for chemical-KE-outcome plot
  df <- df %>%
    dplyr::select(doi, chemical, ke_down, ke_up, aop)%>%
    mutate(chemical = sub("(.)", "\\U\\1", `chemical`, perl=TRUE))%>% # Capitalize each chemical - avoids distinct names
    mutate(compound = `chemical`) %>%
    dplyr::rename(from = `chemical`, to = `ke_down`, via = `ke_up`)%>%
    distinct()
  doi <- df$doi
  aop <- df$aop
  df1 <- df %>% dplyr::select(doi, `from`, `via`, `compound`) %>% dplyr::rename(to = `via`)
  df2 <- df %>% dplyr::select(doi, `via`, `to`, `compound`) %>% dplyr::rename(from = `via`)
  df <- merge(df1,df2, all = TRUE)
  df$id <- 1:nrow(df)
  df$doi <- c(rep(doi, 2))
  df$aop <- c(rep(aop, 2))
  return(as_tibble(df))
}


load_data_relations_biomarkers_as_inbetween_nodes <- function(){

  # df <- readr::read_csv(
  #   here::here(
  #     "data-raw",
  #     "steatosis_raw_v7_09_06_2022.csv"
  #   )
  # )

  # df <- xploreaop::data_steat_choles

  load(here::here(
    "data",
    "data_steat_choles.rda"
  ))

df <- data_steat_choles

  ## mutations on the data for chemical-KE-biomarker-outcome plot
  df <- df %>%
    dplyr::select(
      aop,
      doi,
      `chemical`,
      `ke_down`,
      `ke_up`,
      `ke_up_biomarker`,
      `ke_down_biomarker`) %>%
    mutate(`chemical` = sub("(.)", "\\U\\1", `chemical`, perl=TRUE))%>% # Capitalize each chemical - avoids distinct names
    mutate(`compound` = `chemical`) %>% distinct()
  df_complete <- data.frame(id = c(1 : (length(df$chemical) *4)))
  df_complete$from <-  c(df$chemical, df$ke_up, df$ke_up_biomarker, df$ke_down)
  df_complete$to <-  c(df$ke_up, df$ke_up_biomarker, df$ke_down, df$ke_down_biomarker)
  df_complete$doi <- rep(df$doi, 4)
  df_complete$aop <- rep(df$aop, 4)
  df_complete$compound <- rep(df$compound, 4)
  df_complete$ke_up_biomarker <-rep(df$ke_up_biomarker,4)
  df_complete$ke_down_biomarker <-rep(df$ke_down_biomarker,4)
  df <- df_complete
  return(as_tibble(df))
}

load_data_relations_biomarkers_as_end_nodes <- function(){

  # df <- readr::read_csv(
  #   here::here(
  #     "data-raw",
  #     "steatosis_raw_v7_09_06_2022.csv"
  #   )
  # )

 # df <- xploreaop::data_steat_choles

  load(here::here(
    "data",
    "data_steat_choles.rda"
  ))

  df <- data_steat_choles


  ## mutations on the data for chemical-KE-biomarker-outcome plot
  df <- df %>%
    dplyr::select(
      aop,
      doi,
      `chemical`,
      `ke_down`,
      `ke_up`,
      `ke_up_biomarker`,
      `ke_down_biomarker`) %>%
    mutate(`chemical` = sub("(.)", "\\U\\1", `chemical`, perl=TRUE))%>% # Capitalize each chemical - avoids distinct names
    mutate(`compound` = `chemical`) %>% distinct()
  df_complete <- data.frame(id = c(1 : (length(df$chemical) *4)))
  df_complete$from <-  c(df$chemical, df$ke_up, df$ke_up, df$ke_down)
  df_complete$to <-  c(df$ke_up, df$ke_up_biomarker, df$ke_down, df$ke_down_biomarker)
  df_complete$doi <- rep(df$doi, 4)
  df_complete$aop <- rep(df$aop, 4)
  df_complete$compound <- rep(df$compound, 4)
  df_complete$ke_up_biomarker <-rep(df$ke_up_biomarker,4)
  df_complete$ke_down_biomarker <-rep(df$ke_down_biomarker,4)
  df <- df_complete
  return(as_tibble(df))
}

get_article_info <- function(DOI){
  if(!is.null(DOI)){
    ## get article info from PubMed
    articles <- easyPubMed::get_pubmed_ids(DOI)
    pmid <- articles$IdList |> unlist()
    res <- fetch_pubmed_data(articles, format = "xml")
    ## get title
    title <- custom_grep(res, "ArticleTitle", "char")
    title <- paste("<b>", title, "</b>")
    title <- paste(title, "<br>")
    ## get authors
    authors_tbl <- table_articles_byAuth(res, included_authors = "all")
    authors_surnames <- authors_tbl$lastname
    authors_initials <- authors_tbl$firstname
    authors_full <- paste(
      authors_surnames, authors_initials, sep = ", ", collapse = "; ")
    authors_full_markup <- paste(
      authors_full, "<br>"
    )
    ## get abstract
    abstract <- custom_grep(res, "AbstractText")
    abstract <- paste(abstract, collapse = " ")
    abstract <- paste("<p>", abstract, "</p>")
    ## weblink to article page
    pubmed_link <- paste0("https://pubmed.ncbi.nlm.nih.gov/", pmid)
    hlink <- paste(
      "<a", paste0(
        "href=", paste0("'", pubmed_link, "'")),
      paste0(
        "target=","'_blank'"),
      " >Go to article page in PubMed</a><br>")
    ## doi
    doi <- paste0(
      "<a href=", paste0("'", "https://doi.org/",
                         unique(authors_tbl$doi),"'"),
      " target='_blank'",
      paste0(">", "DOI=", authors_tbl$doi |> unique()
      )
    )
    ## concatenate results
    res <- paste(
      title,
      authors_full_markup,
      hlink,
      "<b>ABSTRACT</b>",
      abstract,
      doi)
  }

  else{
    res <- "No DOI selected yet"
  }

  return(res)
}

biomarkers <- c(load_data_relations_biomarkers_as_inbetween_nodes()$ke_up_biomarker,
                load_data_relations_biomarkers_as_inbetween_nodes()$ke_down_biomarker) %>%
  unique()
outcomes <- c("steatosis", "cholestasis")

load_nodes <- function(df_relations){  # node levels
  items <- c(df_relations$from, df_relations$to) |>
    unique()
  items
}
