#'@export
effect_from_substitution <- function(symbol, site, from, to){
    eid <- lookup_symbol(symbol)$id
    cat(paste0(eid,":", "c.", site, from, ">", to, "\n"))
}
