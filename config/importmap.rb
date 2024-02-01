# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'bootstrap', to: 'bootstrap.min.js', preload: true
pin 'popper', to: 'popper.js', preload: true
pin 'filepond', to: 'https://ga.jspm.io/npm:filepond@4.30.4/dist/filepond.js', preload: true
pin_all_from 'app/javascript/custom', under: 'custom'
pin 'filepond-plugin-image-preview', to: 'https://ga.jspm.io/npm:filepond-plugin-image-preview@4.6.11/dist/filepond-plugin-image-preview.js', preload: true
pin 'filepond-plugin-file-validate-type', to: 'https://ga.jspm.io/npm:filepond-plugin-file-validate-type@1.2.8/dist/filepond-plugin-file-validate-type.js', preload: true
pin 'filepond-plugin-file-validate-size', to: 'https://ga.jspm.io/npm:filepond-plugin-file-validate-size@2.2.8/dist/filepond-plugin-file-validate-size.js', preload: true
pin 'leaflet', to: 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js', preload: true
pin 'leaflet-geocoder', to: 'https://unpkg.com/leaflet-control-geocoder/dist/Control.Geocoder.js', preload: true
pin 'sweetalert2', to: 'https://ga.jspm.io/npm:sweetalert2@11.10.4/dist/sweetalert2.all.js', preload: true