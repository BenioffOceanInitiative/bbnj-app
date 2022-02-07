/*
* https://deck.gl/docs/api-reference/geo-layers/h3-cluster-layer
*/
const {DeckGL, H3ClusterLayer} = deck;

const layer = new H3ClusterLayer({
  id: 'H3ClusterLayer',
  data: 'https://shiny.ecoquants.com/bbnj-app/abnj_hex_res2.json',
  
  /* props from H3ClusterLayer class */
  
  // elevationScale: 1,
  extruded: false,
  filled: true,
  // getElevation: 1000,
  // getFillColor: d => [255, (1 - d.mean / 500) * 255, 0],
  getFillColor: d => [255, 255, 0],
  getHexagons: d => d.hexIds,
  getLineColor: [255, 255, 255],
  // getLineWidth: 1,
  // lineJointRounded: false,
  // lineMiterLimit: 4,
  // lineWidthMaxPixels: Number.MAX_SAFE_INTEGER,
  lineWidthMinPixels: 2,
  // lineWidthScale: 1,
  // lineWidthUnits: 'meters',
  // material: true,
  stroked: true,
  // wireframe: false,
  
  /* props inherited from Layer class */
  
  // autoHighlight: false,
  // coordinateOrigin: [0, 0, 0],
  // coordinateSystem: COORDINATE_SYSTEM.LNGLAT,
  // highlightColor: [0, 0, 128, 128],
  // modelMatrix: null,
  // opacity: 1,
  pickable: true,
  // visible: true,
  // wrapLongitude: false,
});

new DeckGL({
  container: 'map',
  mapStyle: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
  initialViewState: {
    longitude: -122.4,
    latitude: 37.74,
    zoom: 11,
    maxZoom: 20,
    pitch: 30,
    bearing: 0
  },
  controller: true,
  getTooltip: ({object}) => object && `abnj: ${object.abnj}`,
  layers: [layer]
});
  