import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel"];

  connect() {
    this.boundClose = this.close.bind(this);
    document.addEventListener("click", this.boundClose);
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose);
  }

  toggle(event) {
    event.preventDefault();
    this.panelTarget.classList.toggle("hidden");
  }

  close(event) {
    if (!this.element.contains(event.target) || event.target instanceof SVGElement) {
      this.panelTarget.classList.add("hidden");
    }
  }
}
