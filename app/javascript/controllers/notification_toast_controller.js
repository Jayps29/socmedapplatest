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

    const isFriendRequest =
      event.detail.type === "friend_request" &&
      event.detail.friendRequestId

    if (!isFriendRequest) {
      content.style.cursor = "pointer"

      if (event.detail.url) {
        content.addEventListener("click", () => {
          window.location.href = event.detail.url
        })
      }

      content.addEventListener("mouseenter", () => {
        content.style.opacity = "0.85"
      })

      content.addEventListener("mouseleave", () => {
        content.style.opacity = "1"
      })

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
    } else {
      content.innerHTML = `
          <div
            style="
              display:flex;
              flex-direction:column;
              gap:12px;
              padding:12px;
            "
          >
            <div
              style="
                display:flex;
                align-items:center;
                gap:12px;
              "
            >
              <div style="font-size:20px;">
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
    
            <div
              style="
                display:flex;
                gap:8px;
              "
            >
              <button
                id="accept-request"
                style="
                  padding:6px 12px;
                  border:none;
                  border-radius:6px;
                  background:#2563eb;
                  color:white;
                  cursor:pointer;
                "
              >
                Accept
              </button>
    
              <button
                id="decline-request"
                style="
                  padding:6px 12px;
                  border:none;
                  border-radius:6px;
                  background:#dc2626;
                  color:white;
                  cursor:pointer;
                "
              >
                Decline
              </button>
            </div>
          </div>
        `

      const acceptButton =
        content.querySelector("#accept-request")

      acceptButton.addEventListener(
        "click",
        async (e) => {
          e.preventDefault()
          e.stopPropagation()

          const token =
            document.querySelector(
              'meta[name="csrf-token"]'
            ).content

          const response = await fetch(
            `/friend_requests/${event.detail.friendRequestId}`,
            {
              method: "PATCH",
              headers: {
                "X-CSRF-Token": token,
                "Accept": "text/vnd.turbo-stream.html"
              }
            }
          )


          if (response.ok) {
            content.innerHTML = `
          <div style="padding:12px;font-weight:500;">
            ✅ Friend request accepted
          </div>
        `
          }
        }
      )

      const declineButton =
        content.querySelector("#decline-request")

      declineButton.addEventListener(
        "click",
        async (e) => {
          e.preventDefault()
          e.stopPropagation()

          const token =
            document.querySelector(
              'meta[name="csrf-token"]'
            ).content

          const response = await fetch(
            `/friend_requests/${event.detail.friendRequestId}`,
            {
              method: "DELETE",
              headers: {
                "X-CSRF-Token": token,
                "Accept": "text/vnd.turbo-stream.html"
              }
            }
          )

          if (response.ok) {
            content.innerHTML = `
              <div
                style="
                  padding:12px;
                  font-weight:500;
                "
              >
                ❌ Friend request declined
              </div>
            `

            setTimeout(() => {
              content.closest(".toastify")?.remove()
            }, 1000)
          }
        }
      )
    }

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