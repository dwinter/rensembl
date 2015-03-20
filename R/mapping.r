#'Convert  coordinates between gene
#'@export
map_genomic_coordinates <- function(id, type, region, format='json'){
    header = ensembl_header(format)
    end <- paste("map", type, region, sep="/")
    req <- ensembl_GET(end,header=header)
    httr::content(req)
}

