#' Dump a Tiff header
#'
#' @rdname tiff_header
#' @aliases tiff_header,TiffArraySeed-method
#' @param image An image or TiffArray object.
#'
#' @return A list of class `tiffHeader`, which has
#' the attribute information.
#' @export
#' @examples
#' nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
#' tiff_header(nii_fname)
#' res = writeTiffArray(nii_fname)
#' tiff_header(res)
setGeneric("tiff_header", function(image) {
  standardGeneric("tiff_header")
})

#' @rdname tiff_header
#' @export
#' @aliases tiff_header,TiffArray-method
setMethod("tiff_header", "TiffArray", function(image) {
  tiff_header(image@seed)
})

#' @rdname tiff_header
#' @export
#' @aliases tiff_header,TiffArrayList-method
setMethod("tiff_header", "TiffArrayList", function(image) {
  nii_seeds = vapply(image, function(x) {
    is(x, "TiffArray") | is(x, "TiffArraySeed")
  }, FUN.VALUE = logical(1))
  if (!any(nii_seeds)) {
    stop("No images in TiffArrayList are TiffArray or TiffArraySeed")
  }
  image = image[ nii_seeds ]
  image = image[[ length(image) ]]
  tiff_header(image)
})



#' @rdname tiff_header
#' @export
#' @aliases tiff_header,DelayedArray-method
setMethod("tiff_header", "DelayedArray", function(image) {
  seeds = DelayedArray::seedApply(image, identity)
  if (length(seeds) == 0) {
    seeds = NULL
  }
  if (!is.null(seeds)) {
    nii_seeds = vapply(seeds, function(x) {
      is(x, "TiffArray") | is(x, "TiffArraySeed")
    }, FUN.VALUE = logical(1))
    if (!any(nii_seeds)) {
      stop(paste0("No seeds in DelayedArray are TiffArray ",
                  "or TiffArraySeed"))
    }
    seeds = seeds[ nii_seeds ]
    seeds = seeds[[ length(seeds) ]]
  } else {
    seeds = slot(image, "seed")
  }
  tiff_header(seeds)
})

#' @rdname tiff_header
#' @export
#' @aliases tiff_header,HDF5Array-method
setMethod("tiff_header", "HDF5Array", function(image) {
  warning("No header available, giving NULL")
  NULL
})

#' @rdname tiff_header
#' @export
#' @aliases tiff_header,HDF5ArraySeed-method
setMethod("tiff_header", "HDF5ArraySeed", function(image) {
  warning("No header available, giving NULL")
  NULL
})


#' @rdname tiff_header
#' @export
#' @aliases tiff_header,ijtiff_img-method
setMethod("tiff_header", "ijtiff_img", function(image) {
  out = attributes(image)
  out$dim_ = out$dim
  out$chunkdim = NULL
  out$name = NULL
  out$filepath = NULL
  out$class = NULL
  out$first_val = NULL
  out$dim = NULL
  class(out) = "tiffHeader"
  out
})

#' @rdname tiff_header
#' @export
#' @aliases tiff_header,ANY-method
setMethod("tiff_header", "ANY", function(image) {
  out = attributes(image)
  out$chunkdim = NULL
  out$name = NULL
  out$filepath = NULL
  out$class = NULL
  out$first_val = NULL
  out$dim = NULL
  class(out) = "tiffHeader"
  out
})


#' @rdname tiff_header
#' @aliases tiff_header,TiffArraySeed-method
#' @export
setMethod("tiff_header", "TiffArraySeed", function(image) {
  out = attributes(image)
  out$chunkdim = NULL
  out$name = NULL
  out$filepath = NULL
  out$class = NULL
  out$first_val = NULL
  out$dim = NULL
  class(out) = "tiffHeader"
  out
})
