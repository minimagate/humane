import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { closeUrl: String, open: Boolean }

  connect() {
    if (this.openValue) this.element.showModal()
  }

  close() {
    this.element.close()
  }

  restoreUrl() {
    if (this.hasCloseUrlValue) window.history.replaceState({}, "", this.closeUrlValue)
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) this.close()
  }
}
