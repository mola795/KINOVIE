 import { Controller } from "@hotwired/stimulus"

 export default class extends Controller {
   connect() {
     this.element.setAttribute("data-action", "turbo:submit-end->alerts#showAlert")
   }

   showAlert(event) {
     if (event.detail.success) {
       notice("Title was added to your Watchlist.")
     }
   }
 }
