window.photon_geocoder = L.Control.Geocoder.photon();
window.location_geocoder = L.Control.geocoder({ collapsed: false, showUniqueResults: false, geocoder: window.photon_geocoder });
window.loadMap = function(container) {
  if(!document.getElementById(container).classList.contains('leaflet-container')) {
    window.location_map = L.map(container).setView([51.9189046, 19.1343786], 2); //starting position
    L.tileLayer("https://{s}.tile.osm.org/{z}/{x}/{y}.png",{ //style URL
      tileSize: 512,
      zoomOffset: -1,
      minZoom: 1,
      crossOrigin: true
    }).addTo(location_map);
    window.location_geocoder.addTo(location_map);
  }
  window.location_geocoder._input.focus();
}