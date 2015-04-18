#'@export
vars_from_symbol <- function(symbol, flanking=0, format="json"){
    gene <- lookup_symbol(symbol)
    region <- paste0(gene$seq_region_name, ":", gene$start - flanking, "-", gene$end - flanking)
    overlap(region=region, feature="variation", format=format)
}
