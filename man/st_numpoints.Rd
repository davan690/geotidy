% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/st_numpoints.R
\name{st_numpoints}
\alias{st_numpoints}
\alias{st_npoints}
\title{Count the number of points in a geometry}
\usage{
st_numpoints(.geom)

st_npoints(.geom)
}
\arguments{
\item{.geom}{A geometry object.}
}
\description{
Count the number of points in a geometry
}
\examples{
library(tibble)
library(dplyr)

tibble(x = 1:2, y = 3:4) \%>\%
  mutate(geom = st_makepoint(x, y), n = st_npoints(geom)) \%>\%
  summarise(line = st_makeline(geom), n = st_numpoints(line))
}
\seealso{
Other make: \code{\link{st_makeline}},
  \code{\link{st_makepoint}}, \code{\link{st_multi}}
}
\concept{make}
