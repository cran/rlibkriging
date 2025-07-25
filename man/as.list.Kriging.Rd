% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/KrigingClass.R
\name{as.list.Kriging}
\alias{as.list.Kriging}
\alias{as.list,Kriging,Kriging-method}
\title{Coerce a \code{Kriging} Object into a List}
\usage{
\method{as.list}{Kriging}(x, ...)
}
\arguments{
\item{x}{An object with class \code{"Kriging"}.}

\item{...}{Ignored}
}
\value{
A list with its elements copying the content of the
    \code{Kriging} object fields: \code{kernel}, \code{optim},
    \code{objective}, \code{theta} (vector of ranges),
    \code{sigma2} (variance), \code{X}, \code{centerX},
    \code{scaleX}, \code{y}, \code{centerY}, \code{scaleY},
    \code{regmodel}, \code{F}, \code{T}, \code{M}, \code{z},
    \code{beta}.
}
\description{
Coerce a \code{Kriging} Object into a List
}
\examples{
f <- function(x) 1 - 1 / 2 * (sin(12 * x) / (1 + x ) + 2 * cos(7 * x) * x^5 + 0.7)
set.seed(123)
X <- as.matrix(runif(10))
y <- f(X)

k <- Kriging(y, X, kernel = "matern3_2")

l <- as.list(k)
cat(paste0(names(l), " =" , l, collapse = "\n"))
}
\author{
Yann Richet \email{yann.richet@asnr.fr}
}
