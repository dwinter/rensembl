#'@export
vars_from_symbol <- function(symbol, flanking=0, format="json"){
    gene <- lookup_symbol(symbol)
    region <- paste0(gene$seq_region_name, ":", gene$start - flanking, "-", gene$end + flanking)
    overlap(region=region, feature="variation", format=format)
}

#'@export 
pi_around_gene <- function(symbol, flanking, window_size){
    snps <- vars_from_symbol(symbol, flanking)
    snp_ids <- sapply(snps, "[[", "id")
    if(length(snp_ids) > 1000){
        nids <- length(snp_ids)
        cat("that's quite a few snps... making", floor(nids/1000)+1, "calls...\n")
        starts <- seq(1,nids, 1000)
        res <- do.call(rbind.data.frame, lapply(starts, function(s) .fetch_snp_data(snp_ids[s:(s+999)])))

    }
    else{
        res <- .fetch_snp_data(snp_ids)
    }
    region_start <- min(res$pos)
    region_end   <- max(res$pos)
    breaks <- seq(region_start, region_end+window_size, window_size)
    window_centre <- breaks[ cut(res$pos, breaks, labels=FALSE, right=FALSE) ]
    aggregate(res$maf  ~ window_centre, FUN= function(q) sum( 2 *(1-q)*q) / window_size)
    
}


.fetch_snp_data <- function(snp_ids){
  snps_data <- variation_id(snp_ids)    
  res <- lapply(snps_data, function(rec) list(pos=rec$mappings[[1]]$start, 
                                              maf=if(is.null(rec$MAF)) NA else as.numeric(rec$MAF))
  )
  do.call(rbind.data.frame, res)
}



