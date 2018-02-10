'use babel'

import { CompositeDisposable, Disposable } from 'atom'

import AskView from './ask-view'
import ResultView from './result-view'
import { config, execute, isFile, loadJSON, unique } from './utils'

export default {
  config: {
    notifications: {
      default: true,
      type: 'boolean',
      title: 'Show notifications',
      order: 1
    },
    packageCommands: {
      default: true,
      type: 'boolean',
      title: 'Load package provided commands',
      description: 'Make sure you restart Atom.',
      order: 2
    },
    php: {
      default: 'php',
      type: 'string',
      title: 'PHP executable',
      order: 3
    },
    customCommands: {
      default: '',
      type: 'string',
      description: 'Location of a JSON file containing custom commands.',
      order: 4
    },
    subfolder: {
        default: '',
        type: 'string',
        title: 'Subfolder',
        description: 'If artisan is not located in the root folder of your project you can specify it here.',
        order: 5
    }
  },

  subscriptions: null,
  command: null,
  askView: null,

  activate(state) {
    this.subscriptions = new CompositeDisposable(
      atom.workspace.addOpener(uri => {
        if (uri === 'atom://artisan-command-result') {
          return new ResultView()
        }
      }),
      new Disposable(() => {
        atom.workspace.getPaneItems().forEach(item => {
          if (item instanceof ResultView) {
            item.destroy()
          }
        })
      })
    )

    this.registerCommands()
  },

  deactivate() {
    this.subscriptions.dispose()
  },

  deserializeResultView(serialized) {
    return new ResultView()
  },

  registerCommands() {
    const commands = this.loadCommands()

    commands.forEach(command => {
      const name = 'artisan:' + command.name

      this.subscriptions.add(
        atom.commands.add('atom-workspace', {
          [name]: () => this.onCommand(command)
        })
      )
    })
  },

  loadCommands() {
    let commands = []

    if (config('artisan.packageCommands')) {
      commands = loadJSON([__dirname, '..', 'data', 'commands.json'])
    }

    if (isFile(config('artisan.customCommands'))) {
      let customCommands = loadJSON(config('artisan.customCommands'))
      commands = unique(customCommands.concat(commands), c => c.name)
    }

    return commands
  },

  onCommand(command) {
    if (!this.itsLaravelProject()) {
      console.log('Not a laravel project')
      return
    }

    this.command = command

    if (command.needsInput) {
      this.askForInput()
    } else {
      this.runCommand('')
    }
  },

  askForInput() {
    if (this.askView === null) {
      this.askView = new AskView()
    }

    this.askView.ask(this.command.caption, input => {
      this.runCommand(input)
    })
  },

  runCommand(input) {
    const phpBinary = config('artisan.php')

    let args = [this.artisanPath(), this.command.command]

    if (input) {
      args = args.concat(input.split(/\s+/))
    }

    execute(phpBinary, args)
      .then((output, code) => this.onCommandSuccess(output, code))
      .catch(this.onCommandError)
  },

  onCommandSuccess(detail, returnCode) {
    if (this.command.showInPanel) {
      atom.workspace.open('atom://artisan-command-result')
      atom.emitter.emit('artisan-update-result-view', detail)

      return
    }

    if (!config('artisan.notifications')) {
      return
    }

    if (detail.match(/(already exists)|(nothing)|(matches the given)/i)) {
      atom.notifications.addInfo('Command finished', { detail })
    } else {
      atom.notifications.addSuccess('Command finished', { detail })
    }
  },

  onCommandError(detail, returnCode) {
    if (!config('artisan.notifications')) {
      return
    }

    atom.notifications.addError('Command failed', { detail })
  },

  itsLaravelProject() {
    return this.artisanPath() !== undefined
  },

  artisanPath() {
    for (projectRoot of atom.project.getPaths()) {

      const file = isFile([projectRoot, config('artisan.subfolder'), 'artisan'])

      if (file) {
        return file
      }
    }
  }
}
