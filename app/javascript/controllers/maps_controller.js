import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ 'location', 'modal' ]

  confirm_location(){
    if(window.location_geocoder._geocodeMarker !== undefined) {
      let latlng = window.location_geocoder._geocodeMarker._latlng;
      let post_modal = document.getElementById('postModal');
      let location_human = location_geocoder._geocodeMarker._popup._content;
      post_modal.querySelector('.location').innerHTML = location_human;
      post_modal.querySelector('#post_latitude').value = latlng.lat;
      post_modal.querySelector('#post_longitude').value = latlng.lng;
    }
  }

  locationTargetConnected(el) {
    let location_provided = el.dataset.locationProvided;
    if (location_provided == 'true') {
      let lat = el.dataset.lat;
      let lng = el.dataset.lng;
      window.photon_geocoder.reverse({ lat: lat, lng: lng }, 0, function(results) {
        el.innerHTML = results[0]['name']
        el.classList.add('location-loaded');
      });
    }
  }

  show_location(e) {
    let el = e.currentTarget;
    if(el.classList.contains('location-loaded')) {
      let modal_cnt = document.getElementById('mapModal');
      let modal = new bootstrap.Modal(document.getElementById('mapModal'), {});
      modal_cnt.querySelector('.modal-footer').classList.add('d-none');
      modal_cnt.querySelector('.btn-close').classList.remove('d-none');
      modal.show(el);
    }
  }

  modalTargetConnected(el) {
    el.addEventListener('show.bs.modal', function (event) {
      if(!event.relatedTarget.classList.contains('location')) {
        el.querySelector('.modal-footer').classList.remove('d-none');
        el.querySelector('.btn-close').classList.add('d-none');
      }
    })
    el.addEventListener('shown.bs.modal', function (event) {
      // load map on modal shown - preload not needed
      window.loadMap('map');

      // if shown as 'Show location'
      if(event.relatedTarget.classList.contains('location')) {
        window.location_geocoder._container.classList.add('d-none');
        let lat = event.relatedTarget.dataset.lat;
        let lng = event.relatedTarget.dataset.lng;
        window.map_markers.clearLayers();
        let marker = L.marker([lat, lng])
        marker.addTo(window.map_markers);
        marker.bindPopup(event.relatedTarget.innerHTML, {closeButton: false, closeOnClick: false}).openPopup();
        window.location_map.setView([lat, lng], 15);
      } else { // else - shown as 'Set location' on post's creation
        window.location_geocoder._container.classList.remove('d-none');
      }
    })
  }


}