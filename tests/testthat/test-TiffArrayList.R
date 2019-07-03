testthat::context("Operations of TiffArrayList")

nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
n_images = 5L
fnames = rep(nii_fname, n_images)
res = TiffArrayList(fnames)


testthat::test_that("Converting TiffArrayList to TiffMatrix", {

  mat = as(res, "TiffMatrix")
  testthat::expect_is(mat, "TiffMatrix")
  testthat::expect_equal(DelayedArray::matrixClass(mat), "TiffMatrix")

})


testthat::test_that("tiff_header TiffArrayList", {

  hdr = tiff_header(res)
  hdr2 = tiff_header(res[[length(res)]])
  testthat::expect_equal(hdr, hdr2)
})



testthat::test_that("Converting TiffArrayList to TiffArray", {

  mat = as(res, "TiffArray")
  testthat::expect_is(mat, "TiffArray")
  testthat::expect_equal(DelayedArray::matrixClass(mat), "TiffMatrix")

  dmat = dim(mat)[4]
  testthat::expect_equal(dmat, n_images)

})



testthat::test_that("Converting TiffArrayList to TiffArray", {

  mat = as(res, "TiffMatrix")
  vec = DelayedMatrixStats::rowMedians(mat)
  writeTiffArray(vec, header = tiff_header(res))

  res_mat = as(vec, "TiffMatrix")
  res_mat = writeTiffArray(res_mat, header = tiff_header(res))
  class(res_mat)
  res_arr = as(res_mat, "TiffArray")

  arr = array(vec, dim = dim(res[[1]]) )
  hdr = tiff_header(res)
  res_arr = writeTiffArray(arr, header = hdr)
  tiff_header(res_arr)

})
