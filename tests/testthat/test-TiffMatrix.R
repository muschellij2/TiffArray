testthat::context("Operations of TiffMatrix")

nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
h5_fname = tempfile(fileext = ".h5")
img = ijtiff::read_tif(nii_fname)
img_hdr = tiff_header(img)



check_array = function(x) {
  testthat::expect_is(x, "TiffArray")
  testthat::expect_is(x, "HDF5Array")
  testthat::expect_is(x, "DelayedArray")
}



testthat::test_that("Operations and DelayedArray give header", {

  res = writeTiffArray(img)
  mat = as(res, "TiffMatrix")
  testthat::expect_is(mat, "TiffMatrix")
  testthat::expect_equal(DelayedArray::matrixClass(mat), "TiffMatrix")
  check_array(mat)

  hdf5mat = HDF5Array::HDF5Array(res@seed@filepath, "image")
  testthat::expect_is(as(hdf5mat, "TiffMatrix"), "TiffMatrix")
  testthat::expect_warning(as(hdf5mat, "TiffMatrix"))
  testthat::expect_equal(DelayedArray::matrixClass(mat), "TiffMatrix")
  check_array(mat)

  mat = DelayedArray::acbind(mat, mat, mat, mat)
  testthat::expect_is(mat, "DelayedMatrix")
  testthat::expect_equal(DelayedArray::matrixClass(mat), "DelayedMatrix")

  vec_result = DelayedMatrixStats::rowMedians(mat)
  result = matrix(vec_result, ncol = 1)
  result = writeTiffArray(result, header = tiff_header(res))
  res_arr = as(result, "TiffArray")

  as(res_arr, "tiffImage")

})

