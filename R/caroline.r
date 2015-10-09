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

#' Get the primate tree for a gene
#' @param symbol gene symbol
#' @export
primate_tree <- function(symbol){
    sp_tree <- ape::read.tree(
       text=genetree_member_symbol("homo_sapiens", symbol, "newick", nh_format="display_label_composite")
    )
    primates <- c('Panu', 'Hsap', 'Pabe' , 'Ptro', 'Csab', 'Ggor', 'Mmul', 'Cjac')
    toks <- strsplit(sp_tree$tip.label, "_")
    orth <- grepl(paste0("^",symbol), sapply(toks, "[[", 1))
    right_sp  <- sapply(toks, tail, 1) %in% primates
    to_drop <- sp_tree$tip.label[!(right_sp & orth)]
    ape::drop.tip(sp_tree, to_drop)
}



#' Get dN/dS data for primates for # variable gender with 20 "male" entries and 
# 30 "female" entries 
gender <- c(rep("male",20), rep("female", 30)) 
gender <- factor(gender) 
# stores gender as 20 1s and 30 2s and associates
# 1=female, 2=male internally (alphabetically)
# R now treats gender as a nominal variable 
summary(gender)a given gene symbol
#'@export
#'@param symbol gene symbol
#'@return a dataframe contaning dnds, species and taxonomic group 
dnds <- function(symbol){
    big_rec <- homology_symbol("hsap", symbol, format="json")
    homologies <- big_rec$data[[1]]$homologies
    primates <- Filter(function(x) is_primate(x), homologies)
    res <- lapply(primates, 
      function(x) c(dnds = .get_dnds(x), species=x$target$species, group=x$taxonomy_level))
    df0 <- do.call(rbind.data.frame, res)
    names(df0) <- c("dnds", "species", "group")
    df0$symbol <- symbol
    df0
}

.get_dnds <- function(x){
    if(is.null(x$dn_ds )){
        return("NA")
    }
    x$dn_ds
}

#' Checks if a homologous region (including lots of info) is for a primate
#'@export
#' @param x a homologous region
is_primate <- function(x){
    if(x$type == "ortholog_one2one"){
        return (x$taxonomy_level %in% c("Homininae", "Hominidae", "Hominoidea", "Catarrhini", "Simiiformes"))
    }
    return(FALSE)
}

.parse_xml <- function(){
    xml_tree <- XML::xmlTreeParse(
       genetree_member_symbol("homo_sapiens", symbol, "phyloxml", sequence="none"), 
       useInternalNodes=TRUE
    )
    terminals <- Filter(function(x) xmlName(x) == "clade" & "sequence" %in% names(XML::xmlChildren(x)), 
                        xml_tree["//*"])
    res <- lapply(terminals, function(x) list(orth = grepl(tolower(symbol),  tolower(XML::xmlValue(x["sequence"][[1]][[2]]))),
                                             spp = sub("\\ ", "_", XML::xmlValue(x["taxonomy"][[1]][[2]]))))
    names(res) <-  sapply(terminals, function(x) XML::xmlValue(x[[1]]))
    node_summary <- XML::xmlValue(x["sequence"][[1]][[2]])

}

#' @export
analyse_primate_tree <- function(tr, plot=FALSE){
    spp <- sapply(strsplit(tr$tip.label, "_"), tail, 1)
    human_tips <- which(spp == "Hsap")
    if(plot){
        cols <- ifelse(tr$edge[,2]  %in% human_tips, "red", "grey60")
        ape::plot.phylo(tr, edge.color=cols)
    }
    tr$edge.length[tr$edge[,2] %in% human_tips ]
}

.fetch_snp_data <- function(snp_ids){
  snps_data <- variation_id(snp_ids)    
  res <- lapply(snps_data, function(rec) list(pos=rec$mappings[[1]]$start, 
                                              maf=if(is.null(rec$MAF)) NA else as.numeric(rec$MAF))
  )
  do.call(rbind.data.frame, res)
}

