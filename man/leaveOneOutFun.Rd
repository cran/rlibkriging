% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/allGenerics.R
\name{leaveOneOutFun}
\alias{leaveOneOutFun}
\title{Leave-One-Out function}
\usage{
leaveOneOutFun(object, ...)
}
\arguments{
\item{object}{An object representing a fitted model.}

\item{...}{Further arguments of function (eg. range).}
}
\value{
The Leave-One-Out sum of squares.
}
\description{
Compute the leave-One-Out error of a model given in \code{object},
at a different value of the parameters.
}
