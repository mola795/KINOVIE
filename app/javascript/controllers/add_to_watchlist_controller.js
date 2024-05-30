import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-to-watchlist"
export default class extends Controller {
  static targets = ["watchListBtn"];

  static values = {
    titleId: String
  }

  connect() {
    // console.log(this.titleIdValue)
  }

  addToWatchlist(event) {
    console.log(this.titleIdValue)
    fetch(`/add_to_watchlist?title_id=${this.titleIdValue}`, {
    method: 'POST'})
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        alert('Title was added to your Watchlist.');
        // this.watchListBtnTarget.classList.remove("fa-plus");
        // this.watchListBtnTarget.classList.add("fa-check");
      } else {
        alert('There was an error adding the title to your Watchlist.');
      }
    });
  }
}
