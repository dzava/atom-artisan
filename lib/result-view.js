'use babel'

export default class ResultView {
  constructor(serializedState) {
    this.element = document.createElement('div')
    this.element.classList.add('artisan-result-view')

    this.message = document.createElement('pre')
    this.element.appendChild(this.message)

    this.updateDisposable = atom.emitter.on(
      'artisan-update-result-view',
      content => {
        this.message.textContent = content
      }
    )
  }

  getTitle() {
    return 'Artisan'
  }

  getDefaultLocation() {
    return 'bottom'
  }

  getAllowedLocations() {
    return ['left', 'right', 'bottom', 'center']
  }

  getURI() {
    return 'atom://artisan-command-result'
  }

  serialize() {
    return {
      deserializer: 'artisan/ResultView'
    }
  }

  destroy() {
    this.updateDisposable.dispose()
    this.element.remove()
  }

  getElement() {
    return this.element
  }
}
