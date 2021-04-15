library(tidyverse)
library(RefManageR)
`%ni%` = Negate(`%in%`)
options(encoding = "UTF-8")


pubs <- RefManageR::ReadGS(scholar.id="5-qU7lkAAAAJ", check.entries=FALSE) %>% 
  as_tibble() 

# Get full authors list for each publication - by default scholar truncates long author lists, 
# can take some time but necessary to avoid 429 errors
authors_full = tibble(authors = character())

for (i in 1:nrow(pubs_df)) {
  
  pub_full_ch = scholar::get_complete_authors("5-qU7lkAAAAJ", pubid = pubs_df$pubid[i], delay=0.6)
  authors_full[i, ] <- pub_full_ch
  Sys.sleep(1)
  
}

pubs <- pubs%>% 
  mutate(author=authors_full$authors)


pubs %>% 
  filter(institution %ni% c("University of East Anglia", "OUP (Oxford)", "bioRxiv")) %>%
  RefManageR::as.BibEntry() %>% 
  RefManageR::WriteBib(file="bib/new_bib/journal.bib", biblatex = TRUE)

pubs %>% 
  filter(institution =="OUP (Oxford)") %>% 
  mutate(bibtype="Book") %>% 
  mutate(type=NA) %>%
  RefManageR::as.BibEntry() %>% 
  RefManageR::WriteBib(file="bib/new_bib/proceedings.bib", biblatex=TRUE)

pubs %>% 
  filter(institution =="bioRxiv") %>% 
  mutate(journal=institution) %>% 
  mutate(bibtype="Article") %>% 
  mutate(type=NA) %>% 
  RefManageR::as.BibEntry() %>% 
  RefManageR::WriteBib(file="bib/new_bib/working_paper.bib", biblatex=TRUE)

