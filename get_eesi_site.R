pacman::p_load(tidyverse, polite, httr, rvest)

flist <-
  read_lines("eesi.html.files.list.txt") %>% str_replace("./", "")
flist
dlist <-
  read_lines("eesi.html.dirs.list.txt") %>% str_replace("./", "")
dlist

for (i in dlist) {
  if (dir.exists(i) == F) {
    dir.create(i)
  }
}

domain <- "https://www.eesi.psu.edu/"

rm(front_page)
front_page <-
  read_html("https://www.eesi.psu.edu/index.shtml",
            options = c("RECOVER", "NOERROR"))
front_page

for (i in flist) {
  paste(domain, i, sep = "") %>%
    download.file(
      url = .,
      destfile = i,
      method = "curl",
      extra = "-L"
    )
}

for (i in flist) {
#  rmarkdown::pan
}

flist_sort <-
  bind_cols(filename = flist, order1 = rep(NA_integer_, times = length(flist))) %>%
  mutate(order1 = case_when(filename == "index.shtml" ~ -1L,
                            TRUE ~ str_count(filename, "/"))) %>%
  mutate(order2 = case_when(str_detect(filename, "index.html") ~ 0,
                            str_detect(filename, "index.shtml") ~ 0,
                            TRUE ~ 1)) %>%
  arrange(order1, order2, filename)
flist_sort

?rmarkdown::pandoc_convert
rmarkdown::pandoc_convert(flist_sort$filename[1], output = "full_site.docx", verbose = TRUE)
file.edit("full_site.md")
