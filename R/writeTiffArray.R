#' Write TiffArray Object
#'
#' @param x a `tiff` object or file path to `tiff` file
#' @param filepath The path (single character string) to the HDF5 file.
#' @param name The name of the image in the HDF5 file.
#' @param chunkdim The dimensions of the chunks to use for
#' writing the data to disk.
#' Passed to [HDF5Array::writeHDF5Array].
#' @param level The compression level,
#' passed to [HDF5Array::writeHDF5Array].
#' @param verbose Display progress,
#' passed to [HDF5Array::writeHDF5Array].
#' @param header list of header information;
#' overrides call of [tiff_header]
#' @param overwrite `FALSE` by default and an in the
#' event that an HDF5 file already exists for `filepath`
#' input then do not overwrite it.
#' If set to `TRUE` then the "image" and "hdr" objects at this file
#' location will overwrite.
#'
#' @return A `TiffArray` object.
#' @export
#' @importFrom ijtiff read_tif
#' @importFrom HDF5Array writeHDF5Array
#' @importFrom rhdf5 h5closeAll h5delete h5write
#' @examples
#' nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
#' res = writeTiffArray(nii_fname)
#' tiff_header(res)
#' filepath = tempfile(fileext = ".h5")
#' res = writeTiffArray(nii_fname, filepath = filepath)
#' testthat::expect_error(
#'    writeTiffArray(nii_fname, filepath = filepath),
#'    regexp = "already exist",
#' )
#' res = writeTiffArray(nii_fname, filepath = filepath, overwrite = TRUE)
#' img = ijtiff::read_tif(nii_fname)
#' writeTiffArray(c(img), header = tiff_header(img))
writeTiffArray <- function(x, filepath = tempfile(fileext = ".h5"),
  name = "image", chunkdim = NULL, level = NULL,
  verbose = FALSE, header = NULL, overwrite = FALSE){
  # Check if filepath exists as h5 already
  # If it does delete it, will error if the file exists and no overwrite
  if (file.exists(filepath)) {
    if (overwrite) {
      # Could keep the file but remove the contents/groups in the h5 with
      rhdf5::h5delete(file = filepath, name = name)
    } else {
      stop(paste0("The HDF5 filepath given already exists. ",
                  "Please delete file or set overwrite = TRUE."))
    }
  }
  run_gc = FALSE
  # for filepath for .nii.gz
  if (is.character(x)) {
    fe = tools::file_ext(x)
    fe = tolower(fe)
    if (fe == "gz") {
      fe = tools::file_ext(sub("[.]gz$", "", x))
      fe = tolower(fe)
    }
    if (fe %in% c("tif", "tiff")) {
      x = ijtiff::read_tif(x, msg = verbose)
      run_gc = TRUE
    }
  }
  if (!is.null(header)) {
    hdr = header
  } else {
    hdr = tiff_header(x)
  }
  if ("dim" %in% names(hdr)) {
    if (!("dim_" %in% names(hdr))) {
      hdr$dim_ = hdr$dim
    }
    hdr$dim = NULL
  }
  hdr$class = NULL
  if (is.vector(x)) {
    x = matrix(x, ncol = 1)
  }
  if (!is(x, "DelayedArray")) {
    x = array(x, dim = as.integer(dim(x)))
  }
  HDF5Array::writeHDF5Array(x = x, filepath = filepath, name = name,
                            chunkdim = chunkdim, level = level,
                            verbose = verbose)
  if (run_gc) {
    rm(x); gc()
  }
  if (!is.null(hdr)) {
    write_attributes(filepath = filepath, name = name, header = hdr)
    rhdf5::h5closeAll() # Close all open HDF5 handles in the environment
  }
  TiffArray(filepath, name = name, header = header)
}
