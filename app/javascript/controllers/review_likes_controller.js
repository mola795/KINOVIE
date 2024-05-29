import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="follow-toggle"
export default class extends Controller {
  static targets = ["heart", "counter"];

  static values = {
    reviewId: String,
    likesCount: Number
  }

  connect() {
    console.log(this.heartTarget)
    console.log(this.reviewIdValue)
  }

  toggle_likes() {
    const root = `/reviews/${this.reviewIdValue}`;
    if (this.heartTarget.classList.contains("fa-regular")) {
      fetch(`${root}/like_review`).then(()=>{
        this.heartTarget.classList.remove("fa-regular");
        this.heartTarget.classList.add("fa-solid");
        this.counterTarget.innerText = parseInt(this.counterTarget.innerText, 10) + 1
      })

    } else {
      fetch(`${root}/unlike_review`).then(()=>{
        this.heartTarget.classList.remove("fa-solid");
        this.heartTarget.classList.add("fa-regular");
        this.counterTarget.innerText = parseInt(this.counterTarget.innerText, 10) - 1
      })
    }
  }

}
