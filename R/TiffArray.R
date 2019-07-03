### - - - - - - - -
### Constructor
###

#' @importMethodsFrom DelayedArray DelayedArray
setMethod(
    "DelayedArray", "TiffArraySeed",
    function(seed) {
        DelayedArray::new_DelayedArray(
            seed, Class = "TiffArray")
    }
)


#' Tiff images as DelayedArray objects, using HDF5Array
#'
#' TiffArray, a [HDF5Array::HDF5Array] with a header.
#'
#' @note All the operations available for
#' [HDF5Array::HDF5Array] objects work on
#' TiffArray objects.
#'
#'
#' @param filepath The path (as a single character string) to the HDF5
#'  file where the dataset is located.
#' @param name The name of the image in the HDF5 file.
#' @param type `NA` or the R atomic type, passed to
#' [HDF5Array::HDF5Array()].
#' @param header list of attribute information to override call of
#' [tiff_header]
#'
#' @return A `TiffArray` object
#' @export
#'
#' @aliases class:TiffArray
#' @aliases TiffArray-class
#' @aliases TiffArray
#'
#' @importFrom DelayedArray DelayedArray
#' @import methods
#' @examples
#' nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
#' res = TiffArray(nii_fname)
#' res2 = TiffArray(slot(slot(res, "seed"), "filepath"))
#' res2 = TiffArray(slot(res, "seed"))
TiffArray <- function(
    filepath, name = "image",
    type = NA, header = NULL){
    if (is(filepath, "TiffArraySeed")) {
        seed <- filepath
    } else {
        seed <- TiffArraySeed(
            filepath, name = name,
            type = type,
            header = header)
    }
    DelayedArray::DelayedArray(seed)
}



