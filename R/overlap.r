#'@export

overlap <- function(region =NULL, gene_id = NULL, translation_id = NULL, feature,  
                    species='homo_sapiens', bio_type, cell_type, db_type = 'core', 
                    logic_name, misc_set,  so_term,  species_set = 'mamalls', 
                    trim_downstream = FALSE, trim_upstream= FALSE, format="json"){
   end <- if(is.null(region)){
            if(is.null(gene_id)){
                if(is.null(translation_id)){
                    stop("Must provide one of region, gene_id, translation_id")
                }
                paste("overlap/translation", translation_id, sep="/")               
            } else paste("overlap/id", gene_id, sep="/")               
        } else paste("overlap/region", species, region, sep="/")    
    q <- ensembl_body(match.call(), c(species, region))
    header <- ensembl_header(format, c("gff3", "gff", "bed", "json", "xml"))
    req <- ensembl_GET(end, header, query=q)
    httr::content(req)
}


