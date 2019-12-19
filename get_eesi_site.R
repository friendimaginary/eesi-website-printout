pacman::p_load(tidyverse, polite, httr, rvest)

system(
  "wget \
       --no-verbose \
       --recursive \
       --spider \
       --force-html \
       --level=10 -\
       -no-directories \
       --reject=jpg,jpeg,png,gif,pdf,js,css \
       www.eesi.psu.edu 2>&1 | sort | uniq | grep -oe 'www[^ ]*' \
       > new.eesi.files.list"
)

files <- read_lines("new.eesi.files.list")

files %>%
  as_tibble() %>%
  rename(files = value)

front_page_link <- "https://www.eesi.psu.edu/"
front_page_link

system(paste("w3m -dump ", front_page_link, " > front_page.md"))

file.edit("front_page.md")



removable_header <- read_lines("front_page.md", n_max = 82)
removable_tailer <- read_lines("front_page.md", skip = 140)
