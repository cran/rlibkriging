% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NuggetKrigingClass.R
\name{save.NuggetKriging}
\alias{save.NuggetKriging}
\alias{save,NuggetKriging,NuggetKriging-method}
\title{Save a NuggetKriging Model to a file storage}
\usage{
\method{save}{NuggetKriging}(object, filename, ...)
}
\arguments{
\item{object}{An S3 NuggetKriging object.}

\item{filename}{File name to save in.}

\item{...}{Not used.}
}
\value{
The loaded NuggetKriging object.
}
\description{
Save a NuggetKriging Model to a file storage
}
\examples{
f <- function(x) 1- 1 / 2 * (sin(12 * x) / (1 + x) + 2 * cos(7 * x)*x^5 + 0.7)
set.seed(123)
X <- as.matrix(runif(10))
y <- f(X) + 0.1 * rnorm(nrow(X))
points(X, y, col = "blue")

k <- NuggetKriging(y, X, "matern3_2")
print(k)

outfile = tempfile("k.json") 
save(k,outfile)
}
\author{
Yann Richet \email{yann.richet@asnr.fr}
}
