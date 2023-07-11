## functions

#' @title Download a file from a private github repo
#' @export

download_data <- function(url, file_remote, file_local) {

  command <- paste0("curl -H 'Authorization: token ", rstudioapi::askForSecret(name = "Enter Github Token"), "' ",
                    "-H 'Accept: application/vnd.github.v3.raw' ",
                    "-o ", file_local, " ",
                    "-L ", url, file_remote)
  system(command)
}

#' @title Load nodes from a 'relations' dataset
#' @export
load_nodes <- function(df_relations){  # node levels
  items <- c(df_relations$source, df_relations$target) |>
    unique()
  items
}
