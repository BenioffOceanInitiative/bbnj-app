fix_dateline <- function(geom){
  # geom = g
  xy <- st_coordinates(geom)
  x <- xy[,'X']
  
  if (max(abs(diff(x))) < 300)
    return(geom)
  
  y <- xy[,'Y']
  
  if (x[1] < 0){
    x[x > 0] <- x[x > 0] - 360    
  } else {
    # browser("TODO:if (x[1] > 0)")
    x[x < 0] <- x[x < 0] + 360
  }
  
  z <- try(suppressWarnings(
    tibble(
      x = x,
      y = y) %>% 
      st_as_sf(coords = c("x", "y"), crs = 4326) %>%
      summarise(geometry = st_combine(geometry)) %>%
      st_cast("POLYGON") %>% 
      st_cast("MULTIPOLYGON") %>% 
      pull(geometry) %>% 
      # st_make_valid() %>% 
      st_wrap_dateline() %>%
      # st_make_valid() %>% 
      st_union() # %>% 
    # st_make_valid() %>% 
  ))
  # mapview(z)
  
  if ("try-error" %in% class(z))
    browser()
  
  z
}

get_hex <- function(hex_res = 1){
  hex_geo <- glue("data/abnj_hex_res{hex_res}.geojson")
  pu_rds  <- glue("data/abnj_hex_res{hex_res}_area.rds")
  
  if (!file.exists(pu_rds)){
    
    make_hex_res(hex_res)
    
    pu <- read_sf(hex_geo)
    
    # calculate area
    pu <- pu %>%
      # st_make_valid() %>%      # dateline issues
      filter(st_is_valid(.)) %>% # 8 hexagons dropped 
      mutate(
        area_km2 = st_area(geometry) %>% 
          set_units(km^2) %>% 
          drop_units(),
        area_pct = area_km2 / sum(area_km2))
    # sum(pu$area_pct) # check adds to 12
    
    saveRDS(pu, file = pu_rds)
  } else {
    pu <- readRDS(pu_rds)
    # paste(names(pu), collapse = ", ")
    # hexid, on_dtln, lon, lat, FID, geometry, area_km2, area_pct
  }
  pu
}

get_pu_v_ks <- function(pu_f, v, ks){
  var <- as_label(enquo(v))
  
  d_v <- pu_f %>% 
    st_drop_geometry() %>% 
    arrange(desc({{v}})) %>% 
    mutate(
      var = var,
      km2 = cumsum(area_km2),
      val = cumsum({{v}})) %>% 
    select(var, km2, val)
  
  val_sum <- d_v %>% pull(val) %>% last()
  
  d_k <- lapply(
    ks,
    function(k){
      i <- max(which(d_v$km2 < d_v$km2[nrow(d_v)]*k))
      tibble(
        var = var, 
        k   = k,
        km2 = d_v$km2[i],
        val = d_v$val[i],
        pct_val = val/val_sum) }) %>% 
    bind_rows()
  
  p <- d_v %>% 
    ggplot(aes(x = km2, y = val)) + 
    geom_area(fill = "gray", color=NA)
  
  add_k_paths <- function(k, d_k){
    
    # https://colorbrewer2.org/#type=sequential&scheme=Blues&n=3
    col <- c(
      `0.3` = "#9ecae1",
      `0.5` = "#3182bd")[as.character(k)]
    
    x <- d_k %>% filter(k == !!k) %>% pull(km2)
    y <- d_k %>% filter(k == !!k) %>% pull(val)
    y_pct <- d_k %>% filter(k == !!k) %>% pull(pct_val)
    z <- tribble(
      ~x, ~y,
      x,  0,
      x,  y,
      0,  y)
    
    list(
      geom_path(data = z, aes(x,y), color=col),
      annotate(
        "text", x = x, y = y,
        label = glue("{k*100}%: {comma(x, 0.1)} ({percent(y_pct, 0.1)})")))
  }
  
  p <- p +
    lapply(
      ks,
      add_k_paths,
      d_k) +
    labs(
      x = "area_km2",
      y = var) +
    theme_minimal()
  
  list(
    k=d_k, p=p)
}

get_scenario <- function(area, benthic, fishing, scapes, spp, vgpm, redo=F, ...){
  
  o_rds <- here(glue(paste0(
    "data/scenarios/",
    "area{area}_",
    "benthic{benthic}_fishing{fishing}_scapes{scapes}_spp{spp}_vgpm{vgpm}",
    ".rds")))
  
  if (file.exists(o_rds) & !redo){
    o <- readRDS(o_rds)
  } else {
    
    # feature weights
    f_w <- c(
      benthic = benthic,
      fishing = fishing,
      scapes  = scapes,
      spp     = spp,
      vgpm    = vgpm)
    f_w <- f_w[sort(names(f_w))]
    
    # feature targets (max proportion given ocean area)
    f_t <- k %>% 
      filter(pct_area == !!area) %>% 
      select(var, pct_val) %>% 
      arrange(var) %>% 
      deframe()
    
    # problem
    p <- pu_f %>% 
      problem(features = names(f_w), cost_column = "area_pct") %>%
      add_min_shortfall_objective(area) %>% 
      add_relative_targets(f_t) %>%
      add_feature_weights(f_w)
    
    # solve
    s <- solve(p, force = T)
    
    hexids <- s %>% filter(solution_1==1) %>% pull(hexid)
    
    # calcuate actual area of solution
    # area_pct <- s %>% filter(solution_1==1) %>% pull(area_pct) %>% sum()
    
    # calculate feature representation statistics based on the prioritization
    coverage <- eval_target_coverage_summary(p, s[, "solution_1"]) %>% 
      select(feature, relative_held)
    
    o <- list(
      area_pct = area,
      weights  = f_w,
      hexids   = hexids,
      coverage = coverage)
    
    saveRDS(o, o_rds)
  }
  
  # quick fixes
  # names(o)[4] = "coverage"
  # saveRDS(o, o_rds)
  
  c(path_rds = o_rds,
    o)
}

gmap <- function(
    grid, column = "shannon", label = "Shannon index", trans = "identity",
    crs="+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"){
  
  # grid = s; column = "solution_1"; label = "equal weights"; trans = "identity"
  # crs="+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
  
  librarian::shelf(
    ggplot2, rnaturalearth, sf, viridis)
  
  label = str_replace_all(label, "; ", "\n")
  
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

make_hex_res <- function(hex_res = 1, overwrite=F){
  # hex_res = 2
  
  # paths
  hex     <- glue("abnj_hex_res{hex_res}")
  hex_geo <- glue(here("data/{hex}.geojson"))
  # hex_shp <- glue(here("data/{hex}_shp/{hex}.shp"))
  # dir.create(dirname(hex_shp), showWarnings = F)
  
  if (file.exists(hex_geo) | overwrite){
    message(glue("hex_geo exists ('data/{hex}.geojson'), skip creating"))
    return(T)
  } else{
    message(glue("hex_geo missing ('data/{hex}.geojson'), creating..."))
  }
  
  wrld <- make_wrld()
  
  # get hexagon ids for whole world (have to do by hemisphere)
  hexids <- c(
    h3::polyfill(wrld[1,], res = hex_res),
    h3::polyfill(wrld[2,], res = hex_res))
  # test area
  # hexids <- h3::polyfill(wrld[4,], res = hex_res)
  
  # convert hexagon ids to spatial features
  hex_sf <- map_df(hexids, h3_to_geo_boundary_sf) %>% 
    mutate(
      hexid = hexids)
  
  # fix hexagons crossing dateline
  hex_sf <- hex_sf %>% 
    mutate(
      on_dtln = map_lgl(geometry, function(g){ 
        max(diff(st_coordinates(g)[,'X'])) > 300 } )) %>% 
    rowwise() %>% 
    mutate(
      geometry = fix_dateline(geometry))
  # mapview(abnj) + mapview(hex_sf)
  
  # get intersection with Areas Beyond National Jurisdiction
  x      <- st_intersects(hex_sf, abnj, sparse = F)[,1]
  hex_sf <- hex_sf[x,]
  # mapview(abnj) + mapview(hex_sf)
  
  # add centroid lon, lat
  hex_sf <- hex_sf %>% 
    mutate(
      geometry = st_cast(geometry, "MULTIPOLYGON"),
      # ctr = map(geometry, st_centroid),
      lon = map_dbl(geometry, function(g){
        st_centroid(g) %>% st_coordinates() %>% 
          .[,'X'] }),
      lat = map_dbl(geometry, function(g){
        st_centroid(g) %>% st_coordinates() %>%
          .[,'Y'] })) # %>% 
  # mapview(abnj) + mapview(hex_sf)
  
  # clip hexagons to abnj
  # hex_sf_0 <- hex_sf
  # hex_sf <- hex_sf_0
  hex_sf <- hex_sf %>% 
    # st_wrap_dateline() %>% 
    st_intersection(
      # st_wrap_dateline(
      abnj
      # )
    ) %>% 
    filter(
      st_geometry_type(geometry) %in% c("POLYGON", "MULTIPOLYGON")) %>% 
    mutate(
      geometry = st_cast(geometry, "MULTIPOLYGON")) %>% 
    st_wrap_dateline()
  
  # st_geometry_type(hex_sf$geometry) %>% table()
  # mapview(abnj) + mapview(hex_sf)
  # leaflet(
  #  hex_sf, 
  #  options = leafletOptions(worldCopyJump = T)) %>% 
  #  addProviderTiles(providers$Esri.OceanBasemap) %>% 
  #  addPolygons()
  
  # write out geojson and shapefile outputs
  write_sf(hex_sf, hex_geo, delete_dsn=T)
  # write_sf(hex_sf, hex_shp, delete_dsn=T)
  return(T)
}

make_wrld <- function(){
  wrld <- bind_rows(
  st_sf(
    hemisphere = "west", 
    geom = st_as_sfc(
      st_bbox(
        c(xmin = -180, xmax = 0, ymin = -86, ymax = 90), 
        crs = st_crs(4326)))),
  st_sf(
    hemisphere = "east", 
    geom = st_as_sfc(
      st_bbox(
        c(xmin = 0, xmax = 180, ymin = -86, ymax = 90), 
        crs = st_crs(4326)))) )
}