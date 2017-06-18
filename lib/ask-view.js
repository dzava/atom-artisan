'use babel'

import { CompositeDisposable, Disposable, TextEditor } from 'atom'

export default class AskView {
  constructor() {
    this.disposables = new CompositeDisposable()

    this.element = document.createElement('div')

    this.caption = document.createElement('label')
    this.caption.classList.add('settings-name')
    this.element.appendChild(this.caption)

    this.editor = new TextEditor({ mini: true })
    const onBlur = () => {
      if (document.hasFocus()) {
        this.close()
      }
    }
    this.editor.element.addEventListener('blur', onBlur)
    this.disposables.add(
      new Disposable(() => {
        this.editor.element.removeEventListener('blur', onBlur)
      })
    )

    this.editor.element.addEventListener('blur', this.onBlur)
    this.element.appendChild(this.editor.element)

    this.panel = atom.workspace.addModalPanel({
      item: this.element,
      visible: false
    })

    this.subscriptions = atom.commands.add(this.element, {
      'core:confirm': evt => {
        this.confirm()
        evt.stopPropagation()
      },
      'core:cancel': evt => {
        this.cancel()
        evt.stopPropagation()
      }
    })
  }

  ask(caption, callback) {
    this.caption.textContent = caption
    this.callback = callback
    this.panel.show()
    this.editor.element.focus()
  }

  cancel() {
    this.close()
  }

  confirm() {
    this.callback(this.editor.getText())

    this.close()
  }

  close() {
    this.editor.setText('')
    this.panel.hide()
  }

  destroy() {
    this.disposables.dispose()
    this.panel.destroy()
    this.element.delete()
    this.subscriptions.destroy()
  }
}
