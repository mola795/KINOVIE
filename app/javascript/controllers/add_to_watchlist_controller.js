import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-to-watchlist"
export default class extends Controller {
  static targets = ["watchListBtn", "counter"];

  connect() {
    // console.log(this.titleIdValue)
    console.log(this.counterTarget)
  }

  addToWatchlist(event) {
    const target = event.currentTarget
    console.log(target);
    event.preventDefault()
    const titleId = event.currentTarget.dataset.id
    console.log(titleId);
    fetch(`/add_to_watchlist?title_id=${titleId}`, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': document.querySelector('[name=csrf-token]').content,
      "Accept": "application/json"
    }
  })
    .then(response => response.json())
    .then(data => {
      console.log(data);
      if (data) {
        console.log(target);
        // alert('Title was added to your Watchlist.');
        target.classList.remove("fa-plus");
        target.classList.add("fa-check");
        this.counterTarget.innerText = parseInt(this.counterTarget.innerText, 10) + 1
      } else {
        alert('There was an error adding the title to your Watchlist.');
      }
    });
  }
}
