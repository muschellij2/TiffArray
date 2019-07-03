### ========================
### TiffArraySeed objects
### ----------------------


#' "TiffArrayList" class
#'
#' @name TiffArrayList-class
#' @family TiffArrayList
#'
setOldClass("TiffArrayList")


#' @importClassesFrom HDF5Array HDF5ArraySeed
#' @aliases DelayedArray,TiffArraySeed-method
#' @exportClass TiffArraySeed
#' @rdname TiffArraySeed
setClass(
    "TiffArraySeed",
    contains = "HDF5ArraySeed")

#' @importClassesFrom HDF5Array HDF5Array
#' @rdname TiffArray
#' @exportClass TiffArray
setClass(
    "TiffArray",
    contains = "HDF5Array",
    slots = c(
        seed = "TiffArraySeed"))

#' TiffMatrix Class
#'
#' @importClassesFrom DelayedArray DelayedMatrix
#' @rdname TiffMatrix
#'
#' @return A `TiffMatrix` object.
#' @exportClass TiffMatrix
setClass("TiffMatrix", contains = c("TiffArray", "DelayedMatrix"))



#' Seed for TiffArray Class
#'
#' @param filepath The path (as a single character string) to the HDF5
#'  file where the dataset is located.
#' @param name The name of the image in the HDF5 file.
#' @param type `NA` or the R atomic type, passed to
#' [HDF5Array::HDF5Array()]
#' @param header list of header information to override call of
#' [tiff_header]
#'
#' @return A `TiffArraySeed` object
#' @export
#' @importFrom HDF5Array HDF5ArraySeed
#' @importFrom rhdf5 h5read
#' @importFrom S4Vectors new2
#' @examples
#' nii_fname = system.file("img", "2ch_ij.tif", package = "ijtiff")
#' res = TiffArraySeed(nii_fname)
#' hdr = tiff_header(res)
#' res2 = TiffArraySeed(nii_fname, header = hdr)
TiffArraySeed <- function(
    filepath,
    name = "image",
    type = NA,
    header = NULL) {
    # for filepath for .tif.gz
    fe = tools::file_ext(filepath)
    if (fe == "gz") {
        fe = tools::file_ext(sub("[.]gz$", "", filepath))
    }
    if (fe %in% c("tif", "tiff")) {
        x = ijtiff::read_tif(filepath)
        header = tiff_header(x)
        filepath = tempfile(fileext = ".h5")
        writeTiffArray(x, filepath = filepath,
                       name = name,
                       header = header)
        rm(x); gc()
    }

    seed = HDF5Array::HDF5ArraySeed(
        filepath, name = name, type = type)
    .tiffArraySeed_from_HDF5ArraySeed(seed, header = header)
}


.tiffArraySeed_from_HDF5ArraySeed = function(seed, header = NULL) {
    args = list(
        filepath = seed@filepath,
        name = seed@name,
        dim = seed@dim,
        first_val = seed@first_val,
        chunkdim = seed@chunkdim
    )
    if (is.null(header)) {
        hdr = read_attributes(seed@filepath, name = seed@name)
    } else {
        hdr = header
    }
    args = c("TiffArraySeed", args)
    res = do.call(S4Vectors::new2, args = args)
    attributes(res) = hdr
    res
}

write_attributes = function(filepath, name = "image", header) {
    header$chunkdim = NULL
    if ("dim" %in% names(header)) {
        if (!("dim_" %in% names(header))) {
            header$dim_ = header$dim
        }
        header$dim = NULL
    }
    if (length(header) == 0) {
        return(invisible(NULL))
    }
    fid = rhdf5::H5Fopen(filepath)
    # open up the dataset to add attributes to, as a class
    did <- rhdf5::H5Dopen(fid, name = name)
    for (i in names(header)) {
        rhdf5::h5writeAttribute(did,
                         attr = header[[i]],
                         name = i)
    }
    rhdf5::H5Dclose(did)
    rhdf5::H5Fclose(fid)
    return(invisible(NULL))
}

read_attributes = function(filepath, name = "image") {
    hdr = rhdf5::h5readAttributes(filepath, name = name)
    hdr$dim = hdr$chunkdim =  NULL
    hdr
}
