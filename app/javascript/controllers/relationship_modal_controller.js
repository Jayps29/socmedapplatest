import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "title", "content"]

  connect() {
    this.escapeHandler = (event) => {
      if (
        event.key === "Escape" &&
        !this.modalTarget.classList.contains("hidden")
      ) {
        this.close()
      }
    }

    document.addEventListener("keydown", this.escapeHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.escapeHandler)
  }

  open(event) {
    const type = event.params.type

    this.titleTarget.innerText =
      type.charAt(0).toUpperCase() + type.slice(1)

    this.contentTarget.innerHTML =
      document.getElementById(`${type}-data`).innerHTML

    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  backdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}