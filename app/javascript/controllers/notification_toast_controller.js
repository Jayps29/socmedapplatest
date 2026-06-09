import { Controller } from "@hotwired/stimulus"
import Toastify from "toastify-js"

export default class extends Controller {
  connect() {
    this.showToast = this.showToast.bind(this)

    document.addEventListener(
      "notification:received",
      this.showToast
    )
  }

  disconnect() {
    document.removeEventListener(
      "notification:received",
      this.showToast
    )
  }

  showToast(event) {
    const icons = {
      follow: "👤",
      like: "❤️",
      comment: "💬",
      friend_request: "🤝",
      friend_accepted: "✅"
    }

    const icon =
      icons[event.detail.type] || "🔔"

    const content = document.createElement("div")

    content.innerHTML = `
    <div
      style="
      display:flex;
      align-items:center;
      gap:12px;
      height:100%;
      padding:12px;
      "
    >
      <div
        style="
          font-size:20px;
          line-height:1;
          margin-top:2px;
        "
      >
        ${icon}
      </div>
  
      <div
        style="
          font-size:14px;
          font-weight:500;
          line-height:1.4;
          color:#111827;
        "
      >
        ${event.detail.message}
      </div>
    </div>
  `

    Toastify({
      node: content,
      duration: 10000,
      gravity: "bottom",
      position: "right",
      close: false,
      stopOnFocus: true,
      className: "social-toast"
    }).showToast()
  }
}