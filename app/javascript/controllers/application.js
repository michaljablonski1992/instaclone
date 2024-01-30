import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// configure swal
import Swal from 'sweetalert2';
window.Swal = Swal;

export { application }
