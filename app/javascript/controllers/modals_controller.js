import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  show_post_modal(){
    let modal_cnt = document.getElementById('showPostModal');
    let modal = new bootstrap.Modal(modal_cnt, {});
    let spinner = document.createElement('i');
    let modal_body = modal_cnt.querySelector('.modal-body')
    spinner.className = 'show-post-modal-spinner fa fa-spinner fa-spin';
    modal_body.innerHTML = '';
    modal_body.append(spinner);
    modal.show();
  }

  show_likes_modal(e){
    let modal_cnt = document.getElementById(e.target.getAttribute('data-bs-target'));
    let modal = new bootstrap.Modal(modal_cnt, {});
    modal.show();
  }

}