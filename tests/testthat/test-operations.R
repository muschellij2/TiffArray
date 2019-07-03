testthat::context("Operations of TiffArray")

nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
h5_fname = tempfile(fileext = ".h5")
img = ijtiff::read_tif(nii_fname)
img_hdr = tiff_header(img)
arr_list = TiffArrayList(rep(nii_fname, 5))

check_array = function(x) {
  testthat::expect_is(x, "TiffArray")
  testthat::expect_is(x, "HDF5Array")
  testthat::expect_is(x, "DelayedArray")
}


testthat::test_that("Operations TiffArrayList give header", {

  res = Reduce("+", arr_list)
  testthat::expect_is(res, "DelayedArray")
  testthat::expect_is(as(res, "TiffArray"), "TiffArray")

  hdr = tiff_header(res)
  testthat::expect_is(hdr, "tiffHeader")
  writeTiffArray(res)

  res = res / 4
  testthat::expect_is(res, "DelayedArray")
  check_array(as(res, "TiffArray"))

  res = log(res + 1)
  testthat::expect_is(res, "DelayedArray")
  check_array(as(res, "TiffArray"))

  sub = res[1:30, 1:30, 1:3, 1]
  testthat::expect_is(sub, "DelayedArray")
  check_array(as(sub, "TiffArray"))

  sub = DelayedArray::aperm(res, c(3, 1, 2))
  testthat::expect_is(sub, "DelayedArray")
  check_array(as(sub, "TiffArray"))

  res[1:30, 1:30, 1:3, 1] = 1
  testthat::expect_is(res, "DelayedArray")
  check_array(as(res, "TiffArray"))

})


testthat::test_that("Operations and DelayedArray give header", {

  res = writeTiffArray(img)
  res2 = writeTiffArray(img)

  sum_img = res + res2
  testthat::expect_is(sum_img, "DelayedArray")

  testthat::expect_is(as(sum_img, "TiffArray"), "TiffArray")

  hdr = tiff_header(sum_img)
  testthat::expect_is(hdr, "tiffHeader")
  writeTiffArray(sum_img)

  rr = HDF5Array::HDF5Array(res2@seed@filepath, "image")
  image = res + rr
  hdr = tiff_header(image)
  testthat::expect_is(hdr, "tiffHeader")

  rr = HDF5Array::HDF5Array(res2@seed@filepath, "image")
  image = rr + rr
  testthat::expect_error(tiff_header(image), "No seeds")
  testthat::expect_is(hdr, "tiffHeader")

  testthat::expect_is(as(rr, "TiffArray"), "TiffArray")
  testthat::expect_warning(as(rr, "TiffArray"), "No header")

})

testthat::test_that("Conversion to TiffArray", {

  run_mat = matrix(rnorm(100), nrow = 10)
  testthat::expect_is(as(run_mat, "TiffArray"), "TiffArray")
  testthat::expect_is(as(as(run_mat, "TiffArray"), "TiffMatrix"),
                      "TiffMatrix")
  run_mat = as(run_mat, "TiffArray")
  testthat::expect_is(as(run_mat, "TiffMatrix"), "TiffMatrix")

  testthat::expect_is(as(rnorm(100), "TiffMatrix"), "TiffMatrix")

})

testthat::test_that("Conversion to TiffArray", {

  arr = writeTiffArray(nii_fname)
  out_img = as(as(arr, "TiffMatrix"), "ijtiff_img")
  testthat::expect_is(out_img, "ijtiff_img")

  testthat::expect_equal(dim(out_img), dim(img))

})


testthat::test_that("Operations and DelayedArray give header", {

  res = writeTiffArray(img)
  res2 = writeTiffArray(img)
  dim(res) = c(dim(res), 1)
  dim(res2) = c(dim(res2), 1)
  big_res <- DelayedArray::aperm(
    DelayedArray::arbind(
      DelayedArray::aperm(res, 4:1),
      DelayedArray::aperm(res2, 4:1)),
    4:1)

})
