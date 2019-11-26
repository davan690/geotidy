
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geotidy

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/etiennebr/geotidy.svg?branch=master)](https://travis-ci.org/etiennebr/geotidy)
[![Codecov test
coverage](https://codecov.io/gh/etiennebr/geotidy/branch/master/graph/badge.svg)](https://codecov.io/gh/etiennebr/geotidy?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Manipulate spatial data tidily. `Geotidy` provides a selection of
spatial functions from the `sf` package that are adapted to a tidy
workflow. It relies on tibbles and `dplyr` verbs, and forces you to be
explicit about the spatial operations you desire. The package is
experimental. If you want to learn more about the motivations behind it,
see the [Motivation](#motivation) section.

## Installation

You can install the experimental version of geotidy from github :

``` r
# install.packages("remotes")
remotes::install_github("etiennebr/geotidy")
```

## Example

Here’s how you can create spatial data.

``` r
library(tidyverse)
library(geotidy)

tibble(place = "Sunset Room", longitude = -97.7404985, latitude = 30.2645315) %>% 
  mutate(geometry = st_point(longitude, latitude))
#> # A tibble: 1 x 4
#>   place       longitude latitude            geometry
#>   <chr>           <dbl>    <dbl>             <POINT>
#> 1 Sunset Room     -97.7     30.3 (-97.7405 30.26453)
```

``` r
library(tidyverse)
library(sf)
library(geotidy)  # note: load geotidy last, because it replaces some sf functions

giza <- tribble(
  ~what,         ~longitude, ~latitude,
  "Giza",        31.1342,   29.9792,
  "Khafre",      31.130833, 29.976111,
  "Menkaure",    31.128333, 29.9725,
  "Khentkaus I", 31.135608, 29.973406,
  "Sphynx",      31.137778, 29.975278
) %>% 
  # add a geometry column
  mutate(geometry = st_point(longitude, latitude) %>% st_set_crs(4326))
giza
#> # A tibble: 5 x 4
#>   what        longitude latitude            geometry
#>   <chr>           <dbl>    <dbl>         <POINT [°]>
#> 1 Giza             31.1     30.0   (31.1342 29.9792)
#> 2 Khafre           31.1     30.0 (31.13083 29.97611)
#> 3 Menkaure         31.1     30.0  (31.12833 29.9725)
#> 4 Khentkaus I      31.1     30.0 (31.13561 29.97341)
#> 5 Sphynx           31.1     30.0 (31.13778 29.97528)

giza %>% 
  ggplot(aes(geometry = geometry, label = what)) + 
  geom_sf(size = 10, alpha = 0.1) +
  geom_sf_text()
#> Warning in st_point_on_surface.sfc(sf::st_zm(x)): st_point_on_surface may not
#> give correct results for longitude/latitude data
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

``` r

# create a buffer around the points and union in a single geometry
giza %>% 
  mutate(
    projected = st_transform(geometry, 32636),
    buffer = st_buffer(projected, units::as_units(250, "m"))
  ) %>% 
  summarise(
    geometry = st_union(projected),
    buffer = st_union(buffer)
  ) %>% 
  ggplot(aes(geometry = buffer)) + 
  geom_sf()
```

<img src="man/figures/README-unnamed-chunk-2-2.png" width="100%" />

## Motivation

Many spatial formats use a model where a geometry can have many
attributes. This model can be very useful in many applications, but it
sometimes conflicts with the principles of tidy data, where one
observation is one row. To keep spatial data and operations tidy,
`geotidy` does less than `sf`. It makes manipulations explicit by
forcing the use of a function on the geometry column. It doesn’t try to
guess which is the geometry column that should receive the operation. It
also makes it clear by reading the code, which geometry is impacted.
This is done by treating geometry columns just like other tibble
columns. `sf` often hides the geometry column, `geotidy` treats it just
like a regular columns. This also makes it easier to interact with other
OGC compliant tools, such as `postgis` or `spark+geomesa`.

If you already use `dplyr` with `sf`, `geotidy` should fell natural and
remove some of the casting operations. `geotidy` guarantees that your
data will stay tidy from start to finish. By having explicit management
of geometry columns, it is also easy to track multiple columns.

`geotidy` also guarantees that the returned values are either scalar, a
vector or a list with the same length than the original geometry and not
drop any data without the user explicit consent (looking at you
`st_cast`\!). We also make it clear which functions aggregate the data
by using `group_by`.

`geotidy` is not a fork or a separation from `sf`. It just adds a
constrained layer on top of `sf` to facilitate a tidy workflow. It is an
experiment that could be integrated in `sf` and is likely to change.
