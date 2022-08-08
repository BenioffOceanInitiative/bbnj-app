# load packages
if (!require("librarian"))
  install.packages("librarian")
librarian::shelf(
  # deckgl, 
  dplyr, here, 
  shiny, shinyBS, shinydashboard)

dir_data   <- "/share/data/bbnj"
hex_res    <- 2
hex        <- read_sf(glue("{dir_data}/hex_res{hex_res}.geojson"))
sol_hex    <- read_csv(glue("{dir_data}/solution_hexids_res{hex_res}.csv"))
sol_cover  <- read_csv(glue("{dir_data}/solution_coverage.csv"))
sol_params <- read_csv(glue("{dir_data}/solution_params.csv"))

sid <- 1

h <- hex %>% 
  inner_join(
    sol_hex %>% 
      filter(
        hexres == hex_res,
        sid == !!sid),
    by = "hexid")

pal <- colorNumeric(
  palette = "Greens",
  domain = c(0,1))

leaflet() %>% 
  addPolygons(
    data = h,
    stroke = F,
    fillColor = ~pal(hexpct), opacity=1)

# slider default value
sldr_v <- 2

# run the Shiny app
ui <- dashboardPage(
  dashboardHeader(
    title="BBNJ Prioritizr"),
  dashboardSidebar(
    h4("Ocean Area"),
    sliderInput("sldr_area", "% Area", 30, 50, 30, step=20, post="%"),
    hr(),
    h4("Importance of Targets"),
    sliderInput("sldr_fish", "Fishing", 1, 3, sldr_v, step=1, ticks=F),
    bsTooltip("sldr_fish", "Inverse of catch potential", "right"),
    h5("Biodiversity"),
    sliderInput("sldr_vgpm", "Primary Productivity", 1, 3, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_vgpm", "vertically generalized production model"),
    sliderInput("sldr_spp" , "Species", 1, 3, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_spp" , "species importance given by species richness multiplied by species extinction risk"),
    h5("Physical"),
    sliderInput("sldr_benthic", "Benthic features", 1, 3, sldr_v, step=1, ticks=F),
    bsTooltip(  "sldr_physvents", "hydrothermal vents and seamounts"),
    sliderInput("sldr_physscapes", "Seafloor", 1, 3, sldr_v, step=1, ticks=F),
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
  
    hexids_url <- "https://shiny.ecoquants.com/bbnj-app/abnj_hex_res2.json"
    properties <- list(
      stroked = TRUE,
      filled = TRUE,
      extruded = FALSE,
      getHexagons = ~hexIds,
      # getFillColor = JS("d => [255, (1 - d.abnj / 500) * 255, 0]"),
      # getFillColor = JS("d => [255, 255, 0]"),
      getFillColor = c(255, 255, 0),
      getLineColor = c(255, 255, 255),
      lineWidthMinPixels = 2,
      getTooltip = ~abnj,
      wrapLongitude = FALSE)
    deckgl(zoom = 3, pitch = 0) %>%
      add_h3_cluster_layer(data = hexids_url, properties = properties) %>%
      add_basemap()
    
  })
}

shinyApp(ui, server)