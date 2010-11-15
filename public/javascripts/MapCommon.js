var bounds = new GLatLngBounds(new GLatLng(49.245133,-123.262239), new GLatLng(49.280245,-123.223822));
var map, initzoom;

function limitbounds() {
  var center = map.getCenter();
  var change = 0;

  if (center.lat() < bounds.getSouthWest().lat()) {
    center = new GLatLng(bounds.getSouthWest().lat(), center.lng());
    change = 1;
  }
  if (center.lat() > bounds.getNorthEast().lat()) {
    center = new GLatLng(bounds.getNorthEast().lat(), center.lng());
    change = 1;
  }
  if (center.lng() < bounds.getSouthWest().lng()) {
    center = new GLatLng(center.lat(), bounds.getSouthWest().lng());
    change = 1;
  }
  if (center.lng() > bounds.getNorthEast().lng()) {
    center = new GLatLng(center.lat(), bounds.getNorthEast().lng());
    change = 1;
  }

  if (change) map.setCenter(center);
}

function limitzoom() {
  if (map.getZoom() < initzoom) map.setZoom(initzoom);
}

function basic_init() {
  var ii;

  map = new GMap2(document.getElementById("map_canvas"));
  map.setCenter(new GLatLng(49.265629,-123.25043));
  map.setUIToDefault();
  for (ii=0;ii<G_DEFAULT_MAP_TYPES.length;ii++) {
    if (G_DEFAULT_MAP_TYPES[ii] != G_NORMAL_MAP) map.removeMapType(G_DEFAULT_MAP_TYPES[ii]);
  }
  initzoom = map.getBoundsZoomLevel(bounds);
  map.setZoom(initzoom);

  GEvent.addListener(map, "move", limitbounds);
  GEvent.addListener(map, "zoomend", limitzoom);
}