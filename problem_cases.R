df3 <- df %>% select(KE..Up.,KE.up..biomarker,KE.Down.,KE.down..biomarker, chemical,DOI)

counter <- df3 %>% select(chemical,DOI) %>% group_by(chemical) %>% summarise("DOIs" = n_distinct(DOI))
counter2 <- counter %>% filter(DOIs > 1)
view(counter)
?summarise

#versie 1
df_complete$from <-  c(df$chemical, df$KE..Up., df$KE.up..biomarker, df$KE.Down.)
df_complete$to <-  c(df$KE..Up., df$KE.up..biomarker, df$KE.Down., df$KE.down..biomarker)

#versie 2
df_complete$from <-  c(df$chemical, df$KE..Up., df$KE..Up., df$KE.Down.)
df_complete$to <-  c(df$KE..Up., df$KE.up..biomarker, df$KE.Down., df$KE.down..biomarker)

#static DOI database
df <- readr::read_csv(
  here::here(
    "data-raw",
    "steatosis_raw_v7_09_06_2022.csv"
  )
)

DOIs <- unique(df$DOI)
df <- !is.na(DOIs)  
df_DOI <- as.data.frame(DOIs)  
df_DOI <- df_DOI %>% rename(id = DOIs)
df_DOI <- df_DOI %>% filter( !is.na(id))
df_DOI <- slice(df_DOI, (1:2))
df <- df_DOI
df_DOI <- df_DOI %>% mutate(res = get_article_info(id))  
  
df_DOI$res <- ""  
for (i in df_DOI$id) {
  df_DOI$res[i] <- get_article_info(df_DOI$id[i])
}  
  
get_article_info(df_DOI$DOIs)  
  
  
get_article_info <- function(DOI){
    
    
    
      ## get article info from PubMed
      articles <- easyPubMed::get_pubmed_ids(DOI)
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
      link <- paste0("https://pubmed.ncbi.nlm.nih.gov/", DOI)
      hlink <- paste(
        "<a", paste0(
          "href=", paste0("'", link, "'")),
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
