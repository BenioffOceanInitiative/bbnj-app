shinyUI(fluidPage(
  windowTitle = "BBNJ app",
  theme = bs_theme(
    version = 5,
    bootswatch = "darkly",
    "font-size-base" = "0.8rem",
    "navbar-padding-y" = "0", 
    "navbar-padding-x" = "0",
    "container-padding-x" = "0"),
  
  tags$head(
    includeCSS("styles.css")),
  
  # area, spp, scapes, benthic, fishing, vgpm
  fluidRow(
    id = "pnl_params",
    column(
      2, prettyRadioButtons(
        "rad_area", label = h5("High Seas Protection"),
        choices = list("30%"="0.3", "50%"="0.5"), selected = "0.3",
        thick = T, animation = "pulse", status = "info")),
    column(
      2, prettyRadioButtons(
        "rad_spp", label = h5("Biodiversity"),
        choices = list("Low"="0.1", "Medium"="1", "High"="10"), selected = "1",
        thick = T, animation = "pulse", status = "info")),
    column(
      2, prettyRadioButtons(
        "rad_scapes", label = h5("Seafloor Diversity"),
        choices = list("Low"="0.1", "Medium"="1", "High"="10"), selected = "1",
        thick = T, animation = "pulse", status = "info")),
    column(
      2, prettyRadioButtons(
        "rad_benthic", label = h5("Seafloor Features"),
        choices = list("Low"="0.1", "Medium"="1", "High"="10"), selected = "1",
        thick = T, animation = "pulse", status = "info")),
    column(
      2, prettyRadioButtons(
        "rad_fishing", label = h5("Fishing Pressure"),
        choices = list("Low"="0.1", "Medium"="1", "High"="10"), selected = "1",
        thick = T, animation = "pulse", status = "info")),
    column(
      2, prettyRadioButtons(
        "rad_vgpm", label = h5("Productivity"),
        choices = list("Low"="0.1", "Medium"="1", "High"="10"), selected = "1",
        thick = T, animation = "pulse", status = "info")) ),
  
  rdeckOutput("map", width = "100vw", height = "100vh")
))

