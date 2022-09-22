This repository is just a wrapper to emulate a "standard" R package
from https://github.com/libKriging/bindings/R/rlibkriging content,
so you can install it just using:

```r
install.packages('devtools')
devtools::install_github("libKriging/rlibkriging")
```

## Requirements

`c++`, `cmake` and `gfortran`, should be installed using:

* Linux: `apt/yum/... install cpp cmake gfortran`

* OSX: `brew install cpp cmake gfortran`

* Windows: install Rtools
  using https://cran.r-project.org/bin/windows/Rtools/rtools42/files/rtools42-5253-5107-signed.exe (or check any update at https://cran.r-project.org/bin/windows/Rtools/rtools42/rtools.html)

  Note:
    * R>=4.2 & Rtools>=42 are required for this 'devtools::install_github'
    * for older R/Rtools, refer to manual
      install: https://github.com/libKriging/libKriging#compilation-for-linuxmacwindows-using-r-toolchain

Note: this repository mainly contains modified Makefiles, inspired by https://github.com/astamm/nloptr wrapper for
NLOpt.

## CRAN

When submitting to CRAN, `./tools/setup.sh` should be run before `R CMD build rlibkriging` to suite CRAN policy.