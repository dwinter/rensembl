#'Convert  coordinates between gene
#'@export
map_genomic_coordinates <- function(id, type, region, format='json'){
    header = ensembl_header(format, c("json"))
    end <- paste("map", type, id, region, sep="/")
    req <- ensembl_GET(end,header=header)
    httr::content(req)
}

