
#' @import ldat
#' @import lvec
#' @export
compare <- function(pairs, by, comparators = list(default_comparator), 
    x, y, default_comparator = identical) {
  # Process and preparare input
  if (missing(x)) x <- attr(pairs, "x")
  if (is.null(x)) stop("Missing x.")
  if (missing(y)) y <- attr(pairs, "y")
  if (is.null(y)) stop("Missing y.")
  if (missing(by) && !missing(by)) by <- names(comparators)
  if (missing(by) || is.null(by)) stop("by is missing.")
  if (any(by %in% names(pairs))) 
    stop("Variable in by already present in pairs.")
  if (!all(by %in% names(x)))
    stop("Not all variables in by are present in x.")
  if (!all(by %in% names(y))) 
    stop("Not all variables in by are present in y.")
  comparators <- extend_to(by, comparators, default = default_comparator)  
  # Compare
  chunks <- chunk(pairs$x)
  for (col in by) {
    res <- NULL
    comparator <- comparators[[col]]
    for (c in chunks) {
      x_i <- slice_range(pairs$x, range = c, as_r = TRUE)
      x_chunk <- x[[col]][x_i]
      y_i <- slice_range(pairs$y, range = c, as_r = TRUE)
      y_chunk <- y[[col]][y_i]
      comparison <- comparator(x_chunk, y_chunk)
      if (is.null(res)) {
        res <- if (is_ldat(pairs)) as_lvec(comparison) else comparison
        length(res) <- length(pairs$x)
      } else {
        lset(res, range = c, values = comparison)
      }
    }
    pairs[[col]] <- res
  }
  attr(pairs, "by") <- by
  attr(pairs, "comparators") <- comparators
  class(pairs) <- unique(c("compare", class(pairs)))
  pairs
}


extend_to <- function(by, what = list(default), default) {
  if (!is.list(what)) stop("what should be a list.")
  has_names <- !is.null(names(what))
  if (has_names) {
    res <- vector("list", length(by))
    names(res) <- by
    for (el in names(res)) {
      res[[el]] <- if (is.null(what[[el]])) default else what[[el]]
    }
  } else {
    res <- rep(what, length.out = length(by))
    names(res) <- by
  }
  res
}
