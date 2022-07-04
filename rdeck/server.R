shinyServer(function(input, output, session) {
  output$map <- renderRdeck({
    
    rdeck(
      map_style = mapbox_dark(),
      initial_bounds = st_bbox(
        c(xmin=-180, ymin=-90, xmax=180, ymax=90),
        crs = st_crs(4326))) %>%
      add_mvt_layer(
        name = "hex",
        data = "https://tile.bbnj.app/public.hexagons/{z}/{x}/{y}.pbf?step=5",
        # get_fill_color = "#0000FF") # blue
        get_fill_color = scale_color_linear(
          col = "i",
          palette = viridis(21, alpha=0.5),
          limits = c(-10, 10)),
        auto_highlight = TRUE,
        pickable = TRUE,
        tooltip = c("i","j"))
  })
  
  # observeEvent(input$map_onclick, {
    # browser()
    # rdeck_proxy("map") %>%
    #   set_filter(LAYER_ID, list("==", "injured", input$slider)) %>%
    #   update_mapboxer()
  # })
})
