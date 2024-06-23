import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  static targets = ["toast"]

  connect() {
    setTimeout(() => this.toastTarget.remove(), 4000)
  }

  close(event) {
    event.preventDefault()

    this.toastTarget.remove()
  }
}
