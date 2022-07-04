librarian::shelf(
  bslib, mapboxer, shiny)

mapbox_token_txt <- '~/My Drive/private/mapbox_token_bdbest.txt'
# mapbox_token_txt <- '/share/data/bbnj/mapbox_token_bdbest.txt'
Sys.setenv("MAPBOX_API_TOKEN" = readLines(mapbox_token_txt))
