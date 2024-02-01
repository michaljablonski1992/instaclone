import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ 'image' ]

  showImg(e){
    let frame = e.target;
    if (frame.complete) {
      frame.querySelector('.lazy-image').src = frame.src
    } else {
      frame.loaded.then(() => function(){
        frame.querySelector('.lazy-image').src = frame.src
      })
    }
  }

}