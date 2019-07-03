testthat::context("Trying to make TiffArray objects")

nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
h5_fname = tempfile(fileext = ".h5")
img = ijtiff::read_tif(nii_fname)
img_hdr = tiff_header(img)

check_array = function(x) {
  testthat::expect_is(x, "TiffArray")
  testthat::expect_is(x, "HDF5Array")
  testthat::expect_is(x, "DelayedArray")
}
testthat::test_that("Writing an Array", {
  res = writeTiffArray(img)
  check_array(res)
})

testthat::test_that("Writing and Reading an Array", {

  res = writeTiffArray(img, filepath = h5_fname)
  testthat::expect_true(file.exists(h5_fname))
  check_array(res)

  hdr = Tiff_header(res)
  testthat::expect_is(hdr, "TiffHeader")
  rm(res)

  res = TiffArray(h5_fname)
  check_array(res)
})

testthat::test_that("Checking equivalent headers", {

  res = writeTiffArray(img)
  hdr = tiff_header(res)
  rm(res)

  testthat::expect_true(all(names(img_hdr) == names(hdr)))
  testthat::expect_true(length(img_hdr) == length(hdr))
  xx = mapply(function(x, y) {
    testthat::expect_equal(x, y)
    NULL
  }, img_hdr, hdr)

  a_img_hdr = attributes(img_hdr)
  a_hdr = attributes(hdr)
  xx = mapply(function(x, y) {
    testthat::expect_equal(x, y)
    NULL
  }, a_img_hdr, a_hdr)
  rm(xx)


})


testthat::test_that("Writing and Reading just tiff file on disk", {

  res = writeTiffArray(nii_fname)
  check_array(res)

  hdr = tiff_header(res)
  testthat::expect_is(hdr, "tiffHeader")
  rm(res)

  res = TiffArray(nii_fname)
  check_array(res)
})



