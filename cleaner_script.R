## cleaner_script.R

# load packages

pacman::p_load(tidyverse, polite, httr, rvest)

# get list of files--only once, or once in a while.

# system(
#   "wget --no-verbose --recursive --spider --force-html --level=10 --no-directories --reject=jpg,jpeg,png,gif,pdf,js,css,txt www.eesi.psu.edu 2>&1 | sort | uniq | grep -oe 'www[^ ]*' > new.eesi.files.list"
# )

# clean out some garbage links
website <-
  read_csv("new.eesi.files.list", col_names = "filename") %>%
  distinct() %>%
  arrange() %>%
  filter(str_detect(filename, ":$") == FALSE) %>%
  filter(str_detect(filename, "www.eesi.psu.edu&https") == FALSE) %>%
  filter(str_detect(filename, "robots.txt$") == FALSE)

# Inspect the front page with file.edit(). Figure out where the headers and
# footers begin and end. If the headers and footers are consisten across pages,
# we'll be able to filter them.

front_page_link <- "www.eesi.psu.edu/"
system(paste("w3m -dump ", front_page_link, " > front_page.md"))

file_length <- read_lines("front_page.md") %>% length()
header_length <- 81
footer_length <- 42
content_length <- 64

page_list <- website$filename # test with website$filename[1:5]

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

fetch_site <- function(page_list = page_list,
                       append = FALSE,
                       header_length = 81,
                       footer_length = 42,
                       output = "masterdoc.md") {
  if (append == FALSE & file.exists(output)) {
    file.remove(output)
  }
  walk(.x = page_list,
       .f = ~ try(fetch_page(link = . ,
                         output = output,
                         header_length = header_length,
                         footer_length = footer_length)))
}



timing <-
  bench::mark({
    fetch_site(website$filename)
  })

file.edit("masterdoc.md")
timing
