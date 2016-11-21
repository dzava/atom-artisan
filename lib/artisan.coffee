AskView = require './ask-view'
ResultView = require './result-view'
{CompositeDisposable} = require 'atom'
{loadJSON, config, isFile, execute, unique} = require './utils'

module.exports = Artisan =
  subscriptions: null
  command: null
  resultView: null
  config:
    php:
      default: 'php'
      type: 'string'
      title: 'PHP executable'
    notifications:
      default: true
      type: 'boolean'
      title: 'Show notifications'
    customCommands:
      default: ''
      type: 'string'
      description: 'A JSON file containing custom commands'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @registerCommands()

  deactivate: ->
    @subscriptions.dispose()
    @resultView?.dispose()

  registerCommands: ->
    commands = @loadCommands()

    commands.forEach (command) =>
      commandName = 'artisan:' + command.name
      @subscriptions.add(
        atom.commands.add(
          'atom-workspace',
          "#{commandName}": => @onCommand(command)
        )
      )

  loadCommands: ->
    commands = loadJSON([
      __dirname, '..', 'data', 'commands.json'
    ])

    if isFile(config('artisan.customCommands'))
      customCommands = loadJSON(config('artisan.customCommands'))
      commands = unique(customCommands.concat(commands), (c) -> c.name )

    return commands

  onCommand: (command) ->
    return unless @itsLaravelProject()
    @command = command

    if @command.needsInput
      @askForInput(@command.caption, (input) =>
        @runCommand(input)
      )
    else
      @runCommand(null)

  runCommand: (input) ->
    phpBinary = config('artisan.php')
    args = [
      @artisanPath(),
      @command.command,
    ]

    if input
      args = args.concat(input.split(/\s+/))

    execute(phpBinary, args)
      .then((output, code) => @onCommandSuccess(output, code))
      .catch(@onCommandError)

  onCommandSuccess: (detail, code) ->
    if @command.showInPanel
      @resultView ?= new ResultView()
      @resultView.update(detail, @command.panelHeading).show()
      return

    return unless config('artisan.notifications')

    if detail.match(/(already exists)|(nothing)|(matches the given)/i)
      atom.notifications.addInfo(
        'Command finished',
        {detail}
      )
    else
      atom.notifications.addSuccess(
        'Command finished',
        {detail}
      )

  onCommandError: (detail, code) ->
    return unless config('artisan.notifications')

    atom.notifications.addError(
      'Command failed',
      {detail}
    )

  artisanPath: ->
    for projectRoot in atom.project.getPaths()
      parts = [projectRoot, 'artisan']
      file = isFile(parts)
      return file if file

    return null

  itsLaravelProject: ->
    return true if @artisanPath()

  askForInput: (caption, callback) ->
    new AskView(caption, (input) =>
      callback(input)
    )
