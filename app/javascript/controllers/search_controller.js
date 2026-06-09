import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      const query = this.inputTarget.value.trim()

      if (query.length < 2) {
        this.resultsTarget.innerHTML = ""
        return
      }

      fetch(`/users/search?query=${encodeURIComponent(query)}`)
        .then(response => response.text())
        .then(html => {
          this.resultsTarget.innerHTML = html
        })
    }, 300)
  }
}