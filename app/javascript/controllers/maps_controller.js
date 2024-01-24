import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ 'location' ]

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
}