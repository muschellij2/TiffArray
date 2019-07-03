
<!-- README.md is generated from README.Rmd. Please edit that file -->

The `TiffArray` package is under development please check back later\!

# TiffArray

<!-- badges: start -->

muschellij2 badges: [![Build
Status](https://travis-ci.com/muschellij2/TiffArray.svg?branch=master)](https://travis-ci.com/muschellij2/TiffArray)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/muschellij2/TiffArray?branch=master&svg=true)](https://ci.appveyor.com/project/muschellij2/TiffArray)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/TiffArray)](https://cran.r-project.org/package=TiffArray)
[![Codecov test
coverage](https://codecov.io/gh/muschellij2/TiffArray/branch/master/graph/badge.svg)](https://codecov.io/gh/muschellij2/TiffArray?branch=master)
[![Coverage
Status](https://img.shields.io/coveralls/muschellij2/TiffArray.svg)](https://coveralls.io/r/muschellij2/TiffArray?branch=master)
<!-- badges: end -->

The goal of `TiffArray` is to allow for memory efficient fast random
access of Tiff images. We allow for `DelayedArray` extensions and
support all operations supported by DelayedArray objects. These
operations can be either delayed or block-processed.

## Installation

You can install the development version of `TiffArray` from
[GitHub](https://github.com/) with:

``` r
# install.packages('remotes')
remotes::install_github("muschellij2/TiffArray")
```

We are working to get a stable version on
[Neuroconductor](www.neuroconductor.org).

## Example

Here we use the example image from `ijtiff`. We use the `writeTiffArray`
function to create a `TiffArray` object:

``` r
library(TiffArray)
nii_fname = system.file("img", "Rlogo.tif", package = "ijtiff")
res = writeTiffArray(nii_fname)
class(res)
#> [1] "TiffArray"
#> attr(,"package")
#> [1] "TiffArray"
dim(res)
#> [1]  76 100   4   1
res
#> <76 x 100 x 4 x 1> TiffArray object of type "double":
#> ,,1,1
#>         [,1]   [,2]   [,3] ...  [,99] [,100]
#>  [1,]      0      0      0   .      0      0
#>  [2,]      0      0      0   .      0      0
#>   ...      .      .      .   .      .      .
#> [75,]      0      0      0   .      0      0
#> [76,]      0      0      0   .      0      0
#> 
#> ...
#> 
#> ,,4,1
#>         [,1]   [,2]   [,3] ...  [,99] [,100]
#>  [1,]      0      0      0   .      0      0
#>  [2,]      0      0      0   .      0      0
#>   ...      .      .      .   .      .      .
#> [75,]      0      0      0   .      0      0
#> [76,]      0      0      0   .      0      0
```

We can see the file on disk that was written out:

``` r
res@seed@filepath
#> [1] "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/RtmpaIqkZy/file43c0400f222c.h5"
```

We see that the object is a low-memory `DelayedArray`:

``` r
object.size(res)
#> 7304 bytes
```

You can also simply use the `TiffArray` function of the tiff filename to
create the array:

``` r
res = TiffArray(nii_fname)
#> Reading Rlogo.tif: an 8-bit, 76x100 pixel image of unsigned
#> integer type. Reading 4 channels and 1 frame . . .
#>  Done.
```

We see the header information is encoded in the `seed` slot of the
object, which can be accessed using the `tiff_header` function:

``` r
tiff_header(res)
#> $width
#> [1] 100
#> 
#> $length
#> [1] 76
#> 
#> $bits_per_sample
#> [1] 8
#> 
#> $samples_per_pixel
#> [1] 4
#> 
#> $sample_format
#> [1] "uint"
#> 
#> $planar_config
#> [1] "contiguous"
#> 
#> $rows_per_strip
#> [1] 76
#> 
#> $compression
#> [1] "LZW"
#> 
#> $x_resolution
#> [1] 299.99
#> 
#> $y_resolution
#> [1] 299.99
#> 
#> $resolution_unit
#> [1] "inch"
#> 
#> $orientation
#> [1] "top_left"
#> 
#> $color_space
#> [1] "RGB"
#> 
#> $dim_
#> [1]  76 100   4   1
#> 
#> attr(,"class")
#> [1] "tiffHeader"
```

### Creating a Matrix

``` r
mat = as(res, "TiffMatrix")
mat
#> <30400 x 1> TiffMatrix object of type "double":
#>          [,1]
#>     [1,]    0
#>     [2,]    0
#>     [3,]    0
#>     [4,]    0
#>     [5,]    0
#>      ...    .
#> [30396,]    0
#> [30397,]    0
#> [30398,]    0
#> [30399,]    0
#> [30400,]    0
```

Now that the image is a matrix, we can bind the columns together,

``` r
mat = DelayedArray::acbind(mat, mat, mat, mat)
testthat::expect_is(mat, "DelayedMatrix")
object.size(mat)
#> 18728 bytes
```

Now that we have the data in a `DelayedMatrix` class, we can use the
package `DelayedMatrixStats` package that calls the `matrixStats`
package for quick operations:

``` r
vec_result = DelayedMatrixStats::rowMedians(mat)
head(vec_result)
#> [1] 0 0 0 0 0 0
```

Turning the output back into a `TiffArray`, we have to pass in the
`header` argument, passing in the correct header information. We can
either create the `TiffArray` output by creating a matrix, then the
`TiffMatrix`, then the `TiffArray`.

``` r
res_mat = matrix(vec_result, ncol = 1)
res_mat = as(res_mat, "TiffMatrix")
hdr = tiff_header(res)
res_mat = writeTiffArray(res_mat, header = hdr)
class(res_mat)
#> [1] "TiffMatrix"
#> attr(,"package")
#> [1] "TiffArray"
res_arr = as(res_mat, "TiffArray")
```

Or we can create an array and then making the `TiffArray`:

``` r
arr = array(vec_result, dim = dim(res) )
hdr = tiff_header(res)
res_arr = writeTiffArray(arr, header = hdr)
res_arr
#> <76 x 100 x 4 x 1> TiffArray object of type "double":
#> ,,1,1
#>         [,1]   [,2]   [,3] ...  [,99] [,100]
#>  [1,]      0      0      0   .      0      0
#>  [2,]      0      0      0   .      0      0
#>   ...      .      .      .   .      .      .
#> [75,]      0      0      0   .      0      0
#> [76,]      0      0      0   .      0      0
#> 
#> ...
#> 
#> ,,4,1
#>         [,1]   [,2]   [,3] ...  [,99] [,100]
#>  [1,]      0      0      0   .      0      0
#>  [2,]      0      0      0   .      0      0
#>   ...      .      .      .   .      .      .
#> [75,]      0      0      0   .      0      0
#> [76,]      0      0      0   .      0      0
tiff_header(res_arr)
#> $width
#> [1] 100
#> 
#> $length
#> [1] 76
#> 
#> $bits_per_sample
#> [1] 8
#> 
#> $samples_per_pixel
#> [1] 4
#> 
#> $sample_format
#> [1] "uint"
#> 
#> $planar_config
#> [1] "contiguous"
#> 
#> $rows_per_strip
#> [1] 76
#> 
#> $compression
#> [1] "LZW"
#> 
#> $x_resolution
#> [1] 299.99
#> 
#> $y_resolution
#> [1] 299.99
#> 
#> $resolution_unit
#> [1] "inch"
#> 
#> $orientation
#> [1] "top_left"
#> 
#> $color_space
#> [1] "RGB"
#> 
#> $dim_
#> [1]  76 100   4   1
#> 
#> attr(,"class")
#> [1] "tiffHeader"
```

### Converting back to ijtiff\_img

We can return a `ijtiff_img` from the `TiffArray` object, as follows:

``` r
nii = as(res_arr, "ijtiff_img")
nii
#> , , 1, 1
#> 
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12] [,13]
#>  [1,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [2,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [3,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [4,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [5,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [6,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [7,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [8,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [9,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#> [10,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>       [,14] [,15] [,16] [,17] [,18] [,19] [,20] [,21] [,22] [,23] [,24]
#>  [1,]     0     0     0     0     0     0     0     0     0     0     0
#>  [2,]     0     0     0     0     0     0     0     0     0     0     0
#>  [3,]     0     0     0     0     0     0     0     0     0     0     0
#>  [4,]     0     0     0     0     0     0     0     0     0     0     0
#>  [5,]     0     0     0     0     0     0     0     0     0     0     0
#>  [6,]     0     0     0     0     0     0     0     0     0   161   143
#>  [7,]     0     0     0     0     0     0     0   152   143   138   135
#>  [8,]     0     0     0     0     0   157   144   138   137   138   141
#>  [9,]     0     0     0   168   147   140   138   140   143   144   146
#> [10,]     0     0   153   143   139   142   144   146   147   148   152
#>       [,25] [,26] [,27] [,28] [,29] [,30] [,31] [,32] [,33] [,34] [,35]
#>  [1,]     0     0     0     0     0     0     0     0     0     0     0
#>  [2,]     0     0     0     0     0     0     0     0     0     0     0
#>  [3,]     0     0     0     0     0     0   192   148   137   135   132
#>  [4,]     0     0     0   172   144   137   134   130   130   131   131
#>  [5,]   181   148   139   135   132   132   134   134   135   136   137
#>  [6,]   139   134   134   136   137   137   139   140   141   142   142
#>  [7,]   136   138   140   141   143   143   145   146   147   150   153
#>  [8,]   143   144   145   146   148   151   156   158   153   145   137
#>  [9,]   147   149   154   160   163   151   135   123   117   117   120
#> [10,]   161   169   159   136   117   110   111   114   119   124   128
#>       [,36] [,37] [,38] [,39] [,40] [,41] [,42] [,43] [,44] [,45] [,46]
#>  [1,]     0     0     0     0     0   198   152   143   135   131   129
#>  [2,]   154   139   133   132   129   128   125   124   123   122   122
#>  [3,]   129   128   128   128   129   129   129   129   129   129   129
#>  [4,]   132   133   133   134   134   134   134   135   134   134   134
#>  [5,]   137   138   138   139   139   139   139   140   140   140   140
#>  [6,]   143   144   145   147   148   148   149   149   149   149   149
#>  [7,]   154   152   150   149   147   147   147   147   148   148   148
#>  [8,]   132   131   133   135   138   142   145   147   148   148   149
#>  [9,]   126   130   134   139   143   148   151   154   155   157   157
#> [10,]   136   145   154   162   168   169   167   163   157   149   141
#>       [,47] [,48] [,49] [,50] [,51] [,52] [,53] [,54] [,55] [,56] [,57]
#>  [1,]   128   126   129   126   126   126   120   128   126   128   129
#>  [2,]   122   122   125   120   120   117   116   116   116   115   114
#>  [3,]   129   128   132   128   128   124   125   124   124   122   121
#>  [4,]   135   134   137   134   134   130   132   131   130   130   128
#>  [5,]   140   139   144   139   139   135   137   136   135   135   134
#>  [6,]   149   148   152   149   149   146   147   146   145   144   142
#>  [7,]   149   150   150   150   151   151   151   151   151   151   151
#>  [8,]   150   150   151   151   151   151   151   150   150   150   149
#>  [9,]   156   154   151   146   142   138   134   131   129   128   126
#> [10,]   134   128   123   119   116   114   113   111   110   110   109
#>       [,58] [,59] [,60] [,61] [,62] [,63] [,64] [,65] [,66] [,67] [,68]
#>  [1,]   136   154   190     0     0     0     0     0     0     0     0
#>  [2,]   114   113   116   117   117   120   124   137   210     0     0
#>  [3,]   119   118   116   114   113   111   109   108   111   113   116
#>  [4,]   128   126   124   122   120   118   116   114   111   109   106
#>  [5,]   133   132   131   129   128   127   125   122   119   117   114
#>  [6,]   140   138   136   135   133   132   131   129   128   125   122
#>  [7,]   151   150   149   148   145   142   139   135   133   131   129
#>  [8,]   149   149   149   149   150   150   150   150   147   143   138
#>  [9,]   126   125   125   126   126   128   130   132   135   139   143
#> [10,]   110   110   110   111   111   112   113   114   115   116   117
#>       [,69] [,70] [,71] [,72] [,73] [,74] [,75] [,76] [,77] [,78] [,79]
#>  [1,]     0     0     0     0     0     0     0     0     0     0     0
#>  [2,]     0     0     0     0     0     0     0     0     0     0     0
#>  [3,]   127   169     0     0     0     0     0     0     0     0     0
#>  [4,]   104   108   109   120   144     0     0     0     0     0     0
#>  [5,]   111   108   104   101   102   107   117   148     0     0     0
#>  [6,]   119   116   113   110   105   101    98   102   107   130     0
#>  [7,]   127   125   121   117   114   110   106   100    96    96   104
#>  [8,]   133   130   129   126   122   118   114   110   105    99    95
#>  [9,]   146   145   141   134   129   127   123   119   114   109   104
#> [10,]   119   123   129   137   142   140   132   127   122   118   113
#>       [,80] [,81] [,82] [,83] [,84] [,85] [,86] [,87] [,88] [,89] [,90]
#>  [1,]     0     0     0     0     0     0     0     0     0     0     0
#>  [2,]     0     0     0     0     0     0     0     0     0     0     0
#>  [3,]     0     0     0     0     0     0     0     0     0     0     0
#>  [4,]     0     0     0     0     0     0     0     0     0     0     0
#>  [5,]     0     0     0     0     0     0     0     0     0     0     0
#>  [6,]     0     0     0     0     0     0     0     0     0     0     0
#>  [7,]   117     0     0     0     0     0     0     0     0     0     0
#>  [8,]    93    99   123     0     0     0     0     0     0     0     0
#>  [9,]    97    91    92   101   130     0     0     0     0     0     0
#> [10,]   107   101    94    89    92   106     0     0     0     0     0
#>       [,91] [,92] [,93] [,94] [,95] [,96] [,97] [,98] [,99] [,100]
#>  [1,]     0     0     0     0     0     0     0     0     0      0
#>  [2,]     0     0     0     0     0     0     0     0     0      0
#>  [3,]     0     0     0     0     0     0     0     0     0      0
#>  [4,]     0     0     0     0     0     0     0     0     0      0
#>  [5,]     0     0     0     0     0     0     0     0     0      0
#>  [6,]     0     0     0     0     0     0     0     0     0      0
#>  [7,]     0     0     0     0     0     0     0     0     0      0
#>  [8,]     0     0     0     0     0     0     0     0     0      0
#>  [9,]     0     0     0     0     0     0     0     0     0      0
#> [10,]     0     0     0     0     0     0     0     0     0      0
#> 
#>  [ reached getOption("max.print") -- omitted 66 row(s) and 3 matrix slice(s) ]
#> attr(,"width")
#> [1] 100
#> attr(,"length")
#> [1] 76
#> attr(,"bits_per_sample")
#> [1] 8
#> attr(,"samples_per_pixel")
#> [1] 4
#> attr(,"sample_format")
#> [1] "uint"
#> attr(,"planar_config")
#> [1] "contiguous"
#> attr(,"rows_per_strip")
#> [1] 76
#> attr(,"compression")
#> [1] "LZW"
#> attr(,"x_resolution")
#> [1] 299.99
#> attr(,"y_resolution")
#> [1] 299.99
#> attr(,"resolution_unit")
#> [1] "inch"
#> attr(,"orientation")
#> [1] "top_left"
#> attr(,"color_space")
#> [1] "RGB"
#> attr(,"dim_")
#> [1]  76 100   4   1
#> attr(,"class")
#> [1] "ijtiff_img" "array"
```
