

gmap <- function(
    grid, column = "shannon", label = "Shannon index", trans = "identity",
    crs="+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"){
  
  # grid = s; column = "solution_1"; label = "equal weights"; trans = "identity"
  # crs="+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
  
  librarian::shelf(
    ggplot2, rnaturalearth, sf, viridis)
  
  world <- ne_countries(scale = "medium", returnclass = "sf")
  bb <- st_bbox(
    st_transform(grid, crs))
  
  ggplot() +
    geom_sf(
      data = grid, aes_string(
        fill = column, geometry = "geometry"), lwd = 0) +
    scale_color_viridis(
      option = "inferno", na.value = "white",
      name = label, trans = trans) +
    scale_fill_viridis(
      option = "inferno", na.value = "white",
      name = label, trans = trans) +
    geom_sf(
      data = world, fill = "#dddddd", color = NA) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.background = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank()) +
    xlab("") + ylab("") +
    coord_sf(
      crs  = crs,
      xlim = bb[c("xmin","xmax")],
      ylim = bb[c("ymin","ymax")])
}
