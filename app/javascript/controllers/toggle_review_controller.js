import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-review"
export default class extends Controller {
  static targets = [ "review" ]

  connect() {
    console.log("Hello, Stimulus! review")
  }

  showreview() {
    this.reviewTarget.classList.toggle('d-none')
    this.reviewTarget.scrollIntoView({behavior: "smooth"});
  }
}
