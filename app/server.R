shinyServer(function(input, output, session) {
  
  output$map <- renderRdeck({
    rdeck(
      map_style = mapbox_dark(),
      initial_bounds = st_bbox(
        c(xmin=-180, ymin=-90, xmax=180, ymax=90),
        crs = st_crs(4326)))
  })
  
  observe({

    u <- url_parse("https://tile.bbnj.app/public.bbnj/{z}/{x}/{y}.pbf")
    u$query <- list(
      area    = input$rad_area,
      spp     = input$rad_spp,
      scapes  = input$rad_scapes,
      benthic = input$rad_benthic,
      fishing = input$rad_fishing,
      vgpm    = input$rad_vgpm)
    mvt <- url_build(u)
    
    rdeck_proxy("map") %>%
      add_mvt_layer(
        id   = "h3_hex",
        name = "Hexagons",
        data = mvt,
        get_fill_color = scale_color_linear(
          col = "hexpct",
          palette = viridis(6, alpha=0.5),
          limits = c(0, 1)),
        auto_highlight = TRUE,
        pickable = TRUE,
        tooltip = c("hexpct"))
  })
    
})
