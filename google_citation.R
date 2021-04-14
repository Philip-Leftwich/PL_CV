library(tidyverse)
`%ni%` = Negate(`%in%`)

pubs_df <- scholar::get_publications("5-qU7lkAAAAJ") %>%
  distinct(title, .keep_all = TRUE) %>%
  transmute(bibtype = "Article", author = as.character(author),
            title = as.character(title),
            journaltitle = as.character(journal), year, key = row_number(),
            number = as.character(number), cites = as.numeric(cites),
            pubid = as.character(pubid)
  )

# Get full authors list for each publication - by default scholar truncates long author lists, 
# can take some time but necessary to avoid 429 errors
authors_full = tibble(authors = character())

for (i in 1:nrow(pubs_df)) {
  
  pub_full_ch = scholar::get_complete_authors("5-qU7lkAAAAJ", pubid = pubs_df$pubid[i], delay=0.6)
  authors_full[i, ] <- pub_full_ch
  Sys.sleep(1)
  
}




RefManageR::ReadGS(scholar.id="5-qU7lkAAAAJ", check.entries=FALSE) %>% 
  as_tibble() %>% 
  mutate(author=authors_full$authors) -> pubs

pubs %>% 
  filter(institution %ni% c("University of East Anglia", "OUP (Oxford)", "bioRxiv")) %>%
  RefManageR::as.BibEntry() %>% 
  RefManageR::WriteBib(file="bib/journal.bib", .Encoding="UTF-8")

pubs %>% 
  filter(institution =="OUP (Oxford)") %>% 
  mutate(bibtype="Book") %>% 
  mutate(type=NA) %>%
  RefManageR::as.BibEntry() %>% 
  RefManageR::WriteBib(file="bib/proceedings.bib", .Encoding="UTF-8")

pubs %>% 
  filter(institution =="bioRxiv") %>% 
  mutate(journal=institution) %>% 
  mutate(bibtype="Article") %>% 
  mutate(type=NA) %>% 
  RefManageR::as.BibEntry() %>% 
  RefManageR::WriteBib(file="bib/working_paper.bib", .Encoding="UTF-8")

