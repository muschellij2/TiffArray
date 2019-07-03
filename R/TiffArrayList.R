#' Write TiffArray Object
#'
#' @param x a character or list of objects to be called with
#' [writeTiffArray]
#' @param ... additional arguments to pass to [TiffArray]
#' @param verbose show progress bars if `pbapply` package installed.
#'
#' @return A list of class `TiffArrayList`, which is a
#' list if `TiffArray` objects
#' @export
#' @examples
#' nii_fname = system.file("img", "2ch_ij.tif", package = "ijtiff")
#' nii_fname = rep(nii_fname, 3)
#' res = TiffArrayList(nii_fname)
#' if (requireNamespace("pbapply", quietly = TRUE)) {
#'    res = TiffArrayList(nii_fname, verbose = TRUE)
#' } else {
#'    testthat::expect_warning({
#'    res = TiffArrayList(nii_fname, verbose = TRUE)
#'    })
#' }
#' testthat::expect_is(res, "TiffArrayList")
#' mat = as(res, "TiffMatrix")
#' arr = as(res, "TiffArray")
#' h5 = unlist(DelayedArray::seedApply(res, slot, "filepath"))
#' res2 = TiffArrayList(h5)
#' testthat::expect_is(res2, "TiffArrayList")
#' mat = as(res2, "TiffMatrix")
#' arr = as(res2, "TiffArray")
TiffArrayList <- function(x, ..., verbose = FALSE) {
  applier = lapply
  if (verbose) {
    if (requireNamespace("pbapply", quietly = TRUE)) {
      applier = pbapply::pblapply
    } else {
      warning(paste0("verbose is set to TRUE for ",
                     "TiffArrayList, but pbapply not ",
                     "installed, defaulting to lapply"))
    }
  }
  res = applier(x, function(xx) {
    TiffArray(xx, ...)
  })
  class(res) = "TiffArrayList"
  attr(res, "verbose") = verbose
  res
}
