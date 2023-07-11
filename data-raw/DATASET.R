#################################################
## Preprocessing of data in the data-raw folder
## Output can be found in folder ./data
## Date: march 2023
## Author Marc A.T. Teunis
#################################################

## Packages
library(tidyverse)
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
library(stringr)


#################################################
## Raw data is downloaded from two different
## Github repositories and stored in .data-raw
##################################################

## get urls and files
ext_data <- readr::read_csv(
  here::here(
    "data-raw",
    "external-data-info.csv"
  )
)

# ## Download files (run to update the files from source)
# l <- list(
#   url = ext_data$url,
#   file_remote = ext_data$file,
# files_local <- paste0(
#   here::here("data-raw", ext_data$file)
# ))
#
# purrr::pmap(
#   .l = l,
#   xploreaop::download_data
# )

##############################################
## Generate datasets
##############################################

##############################################
## Steatosis
##############################################

## Weight of Evidence for KIE-KIE relationships
data_steat_woe <- readr::read_csv(
  here::here(
    "data-raw",
    "D010",
    "steatosis_EE_countFliter_edge_weight_10_01_2022.csv")
) |>
  janitor::clean_names() |>
  dplyr::mutate(type_interaction = "kie-kie")

## literature data
data_steat_literature <- readr::read_csv(
    here::here(
      "data-raw",
      "D010",
      "steatosis_raw_v7_09_06_2022.csv"
      )
    ) |>
    janitor::clean_names() |>
  mutate(aop = "steatosis") |>
  dplyr::select(-notes) |>
  dplyr::relocate(doi, .after = aop)

####################################################
# Cholestasis data
####################################################

## literature data
data_choles_literature <- readr::read_csv2(
  here::here(
    "data-raw",
    "D020",
    "cholestasis_grouped_data_08_11_22.csv")
) |>
  janitor::clean_names() |>
  mutate(aop = "cholestasis", doi = as.character(article_id))


## Join steatosis and cholestasis datasets
## Check if colnames are equal
all(names(data_choles_literature) == names(data_steat_literature))

data_steat_choles <- dplyr::bind_rows(
  data_steat_literature,
  data_choles_literature
)

usethis::use_data(data_steat_choles, overwrite = TRUE)

data_kie_chem_interactions <- data_steat_choles |>
  dplyr::select(
    ke_up,
    ke_down,
    chemical
  ) |>
  group_by(chemical, ke_up, ke_down) |>
  tally() |>
  dplyr::rename(no_articles = n) |>
  dplyr::mutate(
    type_interaction = "chem-kie"
  )


data_kie_chem_interactions_tidy <- data_kie_chem_interactions |>
  pivot_longer(cols = c(ke_up, ke_down), names_to = "type", values_to = "ke")


### create nodes
df_nodes <- tibble(
  from = data_kie_chem_interactions$ke_up,
  to = data_kie_chem_interactions$ke_down,
  weight = data_kie_chem_interactions$no_articles) |>
  unique()


############################################################
# TEST VIZ
############################################################

# https://www.google.com/search?client=firefox-b-d&q=ggraph+youtube#fpstate=ive&vld=cid:7527bf2d,vid:geYZ83Aidq4


## Edge list KIE
graph <- df_nodes |>
  tidygraph::as_tbl_graph()

graph

lay = create_layout(graph = graph, layout = "stress")

ggraph(lay) +
  geom_edge_link(aes()) +
  geom_node_point() +
  geom_node_text(aes(label = name), repel=TRUE)

## From a chemical
## Edge list KIE
graph <- df_nodes |>
  dplyr::filter(to == "de_novo_lipogenesis_fa_synthesis") |>
  tidygraph::as_tbl_graph()

graph

lay = create_layout(graph = graph, layout = "graphopt")

ggraph(lay) +
  geom_edge_link(aes(width = weight)) +
  geom_node_point() +
  geom_node_text(aes(label = name), repel=TRUE, max.overlaps = 100)


graph <- data_kie_chem_interactions |>
  dplyr::filter(chemical == "ethanol" | chemical == "20%_frutose") |>
  select(
    ke_up,
    ke_down,
    chemical
  ) |>
  mutate(
    from = ke_up,
    to = ke_down
  ) |> tidygraph::as_tbl_graph()

graph

lay = create_layout(graph = graph, layout = "stress")

ggraph(lay) +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), repel=TRUE, max.overlaps = 100) +
  facet_edges(~chemical)







#
#
# ###########################################################
# # Get additional chemical data via PubChem API
# ###########################################################
#
# chemicals <- data_steat_choles$chemical |>
#   unique() |>
#   enframe() |>
#   mutate(new_name = str_replace_all(string = value, pattern = "_", replacement = "-"))
#
# # chemicals <- chemicals |>
# #   mutate(cid = map(
# #     .x = new_name,
# #     webchem::get_cid,
# #     from = "name",
# #     verbose = TRUE
# #   ))
#
# ## store on disk
# usethis::use_data()
#
# ## read from disk
# chemicals <- XPloreAOP::chemicals
#
#
#
#
#
#
# ## get chemical ids from PubChem
# source("helpers.R")
#
#
#
# ## check regex
# str_view(string = chemicals_clean[1],
#          pattern = "\\(.*")
#
# ## cleanup backets
# chemicals_clean <-
#   map(
#     chemicals_clean,
#     str_replace_all,
#     pattern = "\\(.*",
#     replacement = ""
#   ) |> as.character()
#
# ## strip white spaces
# chemicals_clean <- map(
#   chemicals_clean,
#   str_trim,
#   side = "both"
# )
#
# chemicals_clean
#
# cids <- map_df(
#   chemicals_clean,
#   webchem::get_cid,
#   verbose = TRUE
# )
#
# write_csv(cids, file = here::here("data", "cids.csv"))
# cids <- read_csv(here::here("data", "cids.csv"))
#
# cids$cid |> is.na() |> sum() -> x
# percentage_not_identified <- 100*(x/nrow(cids))
# percentage_not_identified |> round(1)
#
# compound <- map(
#   cids$cid |> na.omit(),
#   webchem::pc_prop,
#   propeties = "inchi",
#   verbose = TRUE
# )
#
# compounds_df <- dplyr::bind_rows(compound) |>
#   janitor::clean_names()
#
# compounds_enriched <- left_join(cids, compounds_df,
#                                 by = c())
#
# write_csv(compounds_enriched,
#           file = here::here(
#             "data",
#             "chemicals_enriched.csv"))
#
#
#
#
#
