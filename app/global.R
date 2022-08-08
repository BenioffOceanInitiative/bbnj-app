# remotes::install_github("qfes/rdeck")
if (!require("librarian")){
  install.packages("librarian")
  library(librarian)
}
librarian::shelf(
  bslib, dplyr, httr2, qfes/rdeck, sf, shinyWidgets, viridis)

# mb_token <- readLines("~/My Drive/private/mapbox_token_bdbest.txt")
mb_token <- readLines("/share/data/mapbox_token_bdbest.txt")
options(rdeck.mapbox_access_token = mb_token)
# rdeck::mapbox_access_token()