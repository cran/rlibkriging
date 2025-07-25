% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NoiseKMClass.R
\name{simulate,NoiseKM-method}
\alias{simulate,NoiseKM-method}
\title{Simulation from a \code{NoiseKM} Object}
\usage{
\S4method{simulate}{NoiseKM}(
  object,
  nsim = 1,
  seed = NULL,
  newdata,
  cond = TRUE,
  nugget.sim = 0,
  checkNames = FALSE,
  ...
)
}
\arguments{
\item{object}{A \code{NoiseKM} object.}

\item{nsim}{Integer: number of response vectors to simulate.}

\item{seed}{Random seed.}

\item{newdata}{Numeric matrix with it rows giving the points where
the simulation is to be performed.}

\item{cond}{Logical telling wether the simulation is conditional
or not. Only \code{TRUE} is accepted for now.}

\item{nugget.sim}{Numeric. A postive nugget effect used to avoid
numerical instability.}

\item{checkNames}{Check consistency between the design data
\code{X} within \code{object} and \code{newdata}. The default
is \code{FALSE}. XXXY Not used!!!}

\item{...}{Ignored.}
}
\value{
A numeric matrix with \code{nrow(newdata)} rows and
    \code{nsim} columns containing as its columns the simulated
    paths at the input points given in \code{newdata}.

XXX method simulate NoiseKM
}
\description{
The \code{simulate} method is used to simulate paths from the
kriging model described in \code{object}.
}
\details{
Without a dedicated \code{simulate} method for the class
\code{"NoiseKM"}, this method would have been inherited from the
\code{"km"} class. The dedicated method is expected to run faster.
A comparison can be made by coercing a \code{NoiseKM} object to a
\code{km} object with \code{\link{as.km}} before calling
\code{simulate}.
}
\examples{
f <-  function(x) 1 - 1 / 2 * (sin(12 * x) / (1 + x) + 2 * cos(7 * x) * x^5 + 0.7)
plot(f)
set.seed(123)
X <- as.matrix(runif(5))
y <- f(X) + 0.01*rnorm(nrow(X))
points(X, y, col = 'blue')
k <- NoiseKM(design = X, response = y, covtype = "gauss", noise=rep(0.01^2,nrow(X)))
x <- seq(from = 0, to = 1, length.out = 101)
s_x <- simulate(k, nsim = 3, newdata = x)
lines(x, s_x[ , 1], col = 'blue')
lines(x, s_x[ , 2], col = 'blue')
lines(x, s_x[ , 3], col = 'blue')

}
\author{
Yann Richet \email{yann.richet@asnr.fr}
}
