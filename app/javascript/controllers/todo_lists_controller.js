import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="todo-lists" 
// This controller is now minimal since Hotwire handles most interactions
export default class extends Controller {
  
  connect() {
    console.log("TodoLists controller connected - Using pure Hotwire approach!")
  }

  // Auto-remove temporary notifications (backup to CSS animation)
  removeNotification(event) {
    const notification = event.target.closest('[data-turbo-temporary]')
    if (notification) {
      setTimeout(() => {
        notification.remove()
      }, 3000)
    }
  }
}