#'Convert  coordinates between gene and genome
#'@export
map_genomic_coordinates <- function(id, type, region, format='json'){
    header = ensembl_header(format, c("json"))
    end <- paste("map", type, id, region, sep="/")
    req <- ensembl_GET(end,header=header)
    httr::content(req)
}

#'Convert coordinates between genome builds
#'@export
map_species_builds <- function(species, region, asm_one, asm_two, 
                               coord_system="chromosome", format='json'){
    header = ensembl_header(format, c("json", "xml"))
    end <- paste("map", species, asm_one, region, asm_two, sep="/")
    print(end)
    q <- list(coord_system=coord_system)
    req <- ensembl_GET(end, header=header, body=q)
    httr::content(req)
}


