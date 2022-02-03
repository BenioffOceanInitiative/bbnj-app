# load packages
if (!require("librarian"))
  install.packages("librarian")
librarian::shelf(
  deckgl, dplyr, here, 
  shiny, shinyBS, shinydashboard)

# h3 hex data
sf_h3_url <- "https://raw.githubusercontent.com/uber-common/deck.gl-data/master/website/sf.h3clusters.json"
# sf_h3 <- jsonlite::fromJSON(sf_h3_url, simplifyDataFrame = FALSE)
# listviewer::jsonedit(sf_h3)

# slider default value
sldr_v <- 5

# run the Shiny app
ui <- dashboardPage(
  dashboardHeader(
    title="BBNJ Prioritizr"),
  dashboardSidebar(
    h4("Ocean Area"),
    sliderInput("sldr_area", "% Total", 0, 100, 30, step=10, post="%"),
    hr(),
    h4("Proportion of Targets"),
    sliderInput("sldr_fish", "Fishing", 1, 10, sldr_v, step=1, ticks=F),
    bsTooltip("sldr_fish", "Inverse of catch potential", "right"),
    h5("Biodiversity"),
    sliderInput("sldr_bioprod", "Primary Productivity", 1, 10, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_bioprod", "Vertically Generalized Production Model"),
    sliderInput("sldr_biospp" , "Species Richness", 1, 10, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_biospp" , "Number of species by taxonomic group from AquaMaps"),
    sliderInput("sldr_bioext" , "Species Extinction", 1, 10, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_bioext" , "Red List sum of extinction risk by taxonomic group from AquaMaps"),
    h5("Physical"),
    sliderInput("sldr_physvents", "Hydrothermal Vents", 1, 10, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_physvents", "Hydrothermal vent count"),
    sliderInput("sldr_physmounts", "Seamounts", 1, 10, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_physmounts", "Seamounts count"),
    sliderInput("sldr_physscapes", "Seafloor", 1, 10, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_physscapes", "Benthic seascapes (11 types)"),
    shiny::actionButton("btn_calc", "Calculate", icon=icon("paper-plane"), width="85%")
  ),
  
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
    # leaflet::leafletOutput("map", height="92vh")
    deckglOutput("map", height="92vh"))
)

server <- function(input, output) {
  
  output$map <- renderDeckgl({ 

    properties <- list(
      stroked = TRUE,
      filled = TRUE,
      extruded = FALSE,
      getHexagons = ~hexIds,
      getFillColor = JS("d => [255, (1 - d.mean / 500) * 255, 0]"),
      getLineColor = c(255, 255, 255),
      lineWidthMinPixels = 2,
      getTooltip = ~mean
    )

    deckgl(zoom = 10.5, pitch = 20) %>%
      add_h3_cluster_layer(data = sf_h3_url, properties = properties) %>%
      add_basemap()
  
    # properties <- list(
    #   stroked = TRUE,
    #   filled = TRUE,
    #   extruded = FALSE,
    #   getHexagons = ~hexIds,
    #   # getFillColor = JS("d => [255, (1 - d.abnj / 500) * 255, 0]"),
    #   getFillColor = JS("d => [255, 255, 0]"),
    #   getLineColor = c(255, 255, 255),
    #   lineWidthMinPixels = 2,
    #   getTooltip = ~abnj
    # )
    # 
    # hexids_url = "https://shiny.ecoquants.com/bbnj-app/abnj_hexids_res2.json"
    # deckgl(zoom = 10.5, pitch = 20) %>%
    #   add_h3_cluster_layer(data = hexids_url, properties = properties) %>%
    #   add_basemap()
    
  })
}

shinyApp(ui, server)