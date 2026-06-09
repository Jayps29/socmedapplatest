import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")

    if (!this.loaded) {
      fetch("/notifications/dropdown")
        .then(response => response.text())
        .then(html => {
          this.menuTarget.innerHTML = html

          fetch("/notifications/mark_read", {
            method: "PATCH",
            headers: {
              "X-CSRF-Token": document.querySelector(
                'meta[name="csrf-token"]'
              ).content
            }
          })
        })

      this.loaded = true
    }
  }
}