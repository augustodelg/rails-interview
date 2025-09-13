import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  
  connect() {
  }

  removeNotification(event) {
    const notification = event.target.closest('[data-turbo-temporary]')
    if (notification) {
      setTimeout(() => {
        notification.remove()
      }, 3000)
    }
  }
}