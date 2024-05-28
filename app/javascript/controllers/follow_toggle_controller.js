import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="follow-toggle"
export default class extends Controller {
  static targets = ["button"];

  static values = {
    username: String
  }

  connect() {
    console.log(this.buttonTarget)
  }

  toggle_follow() {
    const root = location.href;
    if (this.buttonTarget.innerText == 'Follow') {
      fetch(`${root}/follow`).then(()=>{
        this.buttonTarget.innerText = "Unfollow";
      })

    } else {
      fetch(`${root}/unfollow`).then(()=>{
        this.buttonTarget.innerText = "Follow";
      })
    }
  }

}
