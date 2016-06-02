#'@export
sequence_id <- function(id,  format="fasta", ...){
    q <- ensembl_body(match.call(), c("format", "id"))
    nid <- length(id)
    if(nid== 1){
        return(seq_one(id, q, format))
    }
    if(nid > 50){
        stop("Can download at most 50 sequences in one call. You asked for", nid, ".")
    }
    seq_many(id, q, format)
}


seq_one <- function(id, q, format){
    end_point <- paste0("sequence/id/", id)
    header <- ensembl_header(format, c("fasta", "json", "seqxml", "text", "yaml"))
    req <- ensembl_GET(end_point, header, query=q)
    httr::content(req)
}

seq_many <- function(id, q, format){
    if(format != "fasta"){
        warning("Only FASTA format is availble when requesting multiple sequences")
    }
    header <- "application/json"
    req <- ensembl_POST("sequence/id", header, body=list(ids=id), query=q)    
    httr::content(req)
}
