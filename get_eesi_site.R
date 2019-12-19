pacman::p_load(tidyverse, polite, httr, rvest)

# system(
#   "wget --no-verbose --recursive --spider --force-html --level=10 --no-directories --reject=jpg,jpeg,png,gif,pdf,js,css,txt www.eesi.psu.edu 2>&1 | sort | uniq | grep -oe 'www[^ ]*' > new.eesi.files.list"
# )

website <-
  read_csv("new.eesi.files.list", col_names = "filename") %>%
  distinct() %>%
  arrange() %>%
  filter(str_detect(filename, ":$") == FALSE)

website

front_page_link <- "www.eesi.psu.edu/"
front_page_link

system(paste("w3m -dump ", front_page_link, " > front_page.md"))

file.edit("front_page.md")

# look at that file. figure out where the headers and footers begin and end.
# Capture that text to use in gsub-s or str-replace-s. If the headers and
# footers are consisten across pages, we'll be able to filter them.


# read_file("front_page.md") %>%
#   str_replace_all(pattern = removable_header, replacement = "\n") %>%
#   write_file("front_page_trimmed.md")

# doesn't work. better idea: read the file using the n_max and skip values.

file_length <- read_lines("front_page.md") %>% length()
header_length <- 81
footer_length <- 42
content_length <- 64

file_length
sum(header_length, content_length, footer_length)
file_length - footer_length

read_lines("front_page.md",
           skip = header_length,
           n_max = file_length - footer_length - header_length) %>%
  write_lines("front_page_trimmed.md")

file.edit("front_page_trimmed.md")

title <- read_html(front_page_link) %>%
  html_node("h1") %>%
  html_text()
title

head(read_lines("new.eesi.files.list"))

page_list <- website$filename[1:5]

fetch_page <-
  function(link = "www.eesi.psu.edu/",
           output = "masterdoc.md",
           header_length = 81,
           footer_length = 42) {
    title <- read_html(paste("https://", link, sep = "")) %>%
      html_node("h1") %>%
      html_text()
    command <- paste("w3m -dump ", link, " > dump.temp")
    system(command = command)
    file_length <- read_lines("front_page.md") %>% length()
    read_lines("dump.temp",
               skip = header_length,
               n_max = file_length - footer_length - header_length) %>%
      write_lines("dump.temp")
    body <- read_file("dump.temp")
    file.remove("dump.temp")
    paste("## ",
          title,
          "\n\n\n",
          body,
          "\n\n<hr>\n\n") %>%
      write_lines(path = output, append = TRUE)
  }

fetch_page()
file.edit("masterdoc.Rmd")

page_list <- website$filename[1:5]

fetch_site <- function(page_list = page_list,
                       append = FALSE,
                       header_length = 81,
                       footer_length = 42,
                       output = "masterdoc.md") {
  if (append == FALSE & file.exists(output)) {
    file.remove(output)
  }
  walk(
    page_list,
    ~ fetch_page( . ,
      output = output,
      header_length = header_length,
      footer_length = footer_length
    )
  )
}

fetch_site()
