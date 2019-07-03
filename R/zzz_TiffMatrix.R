#' "ijtiff_img" class
#'
#' @name ijtiff_img-class
#' @aliases ijtiff_img
#' @family ijtiff_img
#'
setOldClass("ijtiff_img")



# write to current dump
.as_TiffArray <- function(from) writeTiffArray(from)

#' @aliases coerce,ANY,TiffArray-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("ANY", "TiffArray", .as_TiffArray)

#' @aliases coerce,DelayedArray,TiffArray-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("DelayedArray", "TiffArray", .as_TiffArray)

#' @aliases coerce,DelayedMatrix,TiffMatrix-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs(
  "DelayedMatrix", "TiffMatrix",
  function(from) as(as(from, "TiffArray"), "TiffMatrix"))


#' @aliases coerce,HDF5Array,TiffArray-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("HDF5Array", "TiffArray", .as_TiffArray)

#' @aliases coerce,HDF5Array,TiffMatrix-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs(
  "HDF5Array",
  "TiffMatrix",
  function(from) as(as(from, "TiffArray"), "TiffMatrix"))

#' @aliases coerce,HDF5Matrix,TiffMatrix-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs(
  "HDF5Matrix", "TiffMatrix",
  function(from) as(as(from, "TiffArray"), "TiffMatrix"))


#' @importMethodsFrom DelayedArray matrixClass
#' @rdname TiffMatrix
#' @aliases matrixClass,TiffArray-method
#' @name matrixClass
#' @param x Typically a DelayedArray object.
setMethod("matrixClass", "TiffArray", function(x) "TiffMatrix")

#' @aliases coerce,TiffArray,TiffMatrix-method
#' @importMethodsFrom methods coerce
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("TiffArray", "TiffMatrix", function(from) {
  # from = res
  dfrom = dim(from)
  nd = length(dfrom)
  if (nd > 4) {
    stop(paste0("TiffMatrix from TiffArray not ",
                "defined for > 4 dimensions!"))
  }
  dfrom = c(dfrom, rep(1L, 4 - nd))
  out_dim = c(prod(dfrom[seq(3)]), dfrom[seq(4, length(dfrom))])
  out_dim = as.integer(out_dim)
  if (nd > 2) {
    hdr = tiff_header(from)
    mat = matrix(from, ncol = dfrom[4])
    writeTiffArray(mat, header = hdr)
    # }
  } else {
    new("TiffMatrix", from)
  }
})


#' @aliases coerce,TiffArrayList,TiffMatrix-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("TiffArrayList", "TiffMatrix", function(from) {
  verbose = attr(from, "verbose")
  if (is.null(verbose)) {
    verbose = FALSE
  }
  applier = lapply
  if (verbose) {
    if (requireNamespace("pbapply", quietly = TRUE)) {
      applier = pbapply::pblapply
    }
  }
  from = applier(from, function(x) {
    as(x, "TiffMatrix")
  })
  hdr = tiff_header(from[[1]])
  from = do.call(DelayedArray::acbind, args = from)
  writeTiffArray(from, header = hdr)
})


#' @aliases coerce,numeric,TiffMatrix-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("numeric", "TiffMatrix", function(from) {
  from = matrix(from, ncol = 1)
  as(as(from, "TiffArray"), "TiffMatrix")
})

#' @rdname TiffArray
#' @aliases coerce,numeric,TiffArray-method
#' @export
#' @name coerce
setAs("numeric", "TiffArray",
      function(from) as(as(from, "TiffMatrix"), "TiffArray")
)

#' @aliases coerce,TiffArray,ijtiff_img-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("TiffArray", "ijtiff_img", function(from) {
  hdr = tiff_header(from)
  from = as.array(from)
  for (i in names(hdr)) {
    attr(from, i) = hdr[[i]]
  }
  class(from) = c("ijtiff_img", "array")
  from
})

#' @aliases coerce,TiffMatrix,ijtiff_img-method
#' @rdname TiffArray
#' @name coerce
#' @export
setAs("TiffMatrix", "ijtiff_img", function(from) {
  as(as(from, "TiffArray"), "ijtiff_img")
})


#' @aliases coerce,TiffMatrix,TiffArray-method
#' @rdname TiffArray
#' @export
#' @name coerce
setAs("TiffMatrix", "TiffArray", function(from) {
  hdr = tiff_header(from)
  d = hdr$dim_
  mat = array(from, dim = d)
  writeTiffArray(mat, header = hdr)
})  # no-op

#' @rdname TiffArray
#' @aliases coerce,ANY,TiffMatrix-method
#' @export
#' @name coerce
setAs("ANY", "TiffMatrix",
      function(from) as(as(from, "TiffArray"), "TiffMatrix")
)

#' @rdname TiffArray
#' @aliases coerce,TiffArrayList,TiffArray-method
#' @export
#' @name coerce
setAs(
  "TiffArrayList", "TiffArray",
  function(from) {
    ndims = lapply(from, dim)
    ndims = vapply(ndims, length, FUN.VALUE = integer(1))
    stopifnot(all(ndims == ndims[1]))
    ndims = unique(ndims)
    hdr = tiff_header(from[[1]])

    verbose = attr(from, "verbose")
    if (is.null(verbose)) {
      verbose = FALSE
    }
    applier = lapply
    if (verbose) {
      if (requireNamespace("pbapply", quietly = TRUE)) {
        applier = pbapply::pblapply
      }
    }

    # Adapted from
    # https://support.bioconductor.org/p/107051/
    from = applier(from, function(x) {
      dim(x) = c(dim(x), 1)
      x = DelayedArray::aperm(x, perm = (ndims + 1):1)
      x
    })
    # 1 for
    if (verbose) {
      message("Binding data together")
    }
    res = do.call(DelayedArray::arbind, args = from)
    res = aperm(res, (ndims + 1):1)
    if (verbose) {
      message("Running writeTiffArray")
    }
    res = writeTiffArray(res, header = hdr, verbose = verbose)
    res
  })


