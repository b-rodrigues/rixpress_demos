read_list_files <- functions(x){
    readr::read_delim(list.files(x, full.names = TRUE), delim = "|")
}
