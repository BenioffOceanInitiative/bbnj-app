shinyServer(function(input, output, session) {
  output$map <- renderRdeck({
    
    rdeck(
      map_style = mapbox_dark(),
      initial_bounds = st_bbox(
        c(xmin=-180, ymin=-90, xmax=180, ymax=90),
        crs = st_crs(4326))) %>%
      add_mvt_layer(
        name = "hex",
        data = "https://tile.bbnj.app/public.bbnj/{z}/{x}/{y}.pbf",
        # get_fill_color = "#0000FF") # blue
        get_fill_color = scale_color_linear(
          col = "hexpct",
          palette = viridis(6, alpha=0.5),
          limits = c(0, 1)),
        auto_highlight = TRUE,
        pickable = TRUE,
        tooltip = c("hexpct"))
  })
  
  # observeEvent(input$map_onclick, {
    # browser()
    # rdeck_proxy("map") %>%
    #   set_filter(LAYER_ID, list("==", "injured", input$slider)) %>%
    #   update_mapboxer()
  # })
})
