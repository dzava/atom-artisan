fs = require 'fs'
path = require 'path'
AskView = require './ask-view'
{CompositeDisposable, BufferedProcess} = require 'atom'

module.exports = Artisan =
  subscriptions: null
  config:
    php:
      default: 'php'
      type: 'string'
      title: 'PHP executable'
    notifications:
      default: true
      type: 'boolean'
      title: 'Show notifications'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @registerCommands()

  deactivate: ->
    @subscriptions.dispose()

  registerCommands: ->
    commands = JSON.parse(
      fs.readFileSync(
        path.join(__dirname, '..', 'data', 'commands.json')
      )
    )

    commands.forEach (command) =>
      commandName = 'artisan:' + command.name
      @subscriptions.add(
        atom.commands.add(
          'atom-workspace',
          "#{commandName}": => @onCommand(command)
        )
      )

  onCommand: (command) ->
    return unless @itsLaravelProject()

    if command.needsInput
      @askForInput((input) =>
        @runCommand(command, input)
      )
    else
      @runCommand(command, null)

  runCommand: (command, input) ->
    phpBinary = atom.config.get('artisan.php')
    args = [
      @artisanPath(),
      command.command,
    ]

    if input
      args = args.concat(input.split(/\s+/))

    @execute(phpBinary, args)
      .then(@onCommandSuccess)
      .catch(@onCommandError)

  execute: (command, args) ->
    new Promise((resolve, reject) ->
      @output = ''
      new BufferedProcess({
        command,
        args,
        stdout: (data) => @output += data
        exit: (code) => if code == 0 then resolve(@output, code) else reject(@output, code)
      })
    )

  onCommandSuccess: (detail, code) ->
    if atom.config.get('artisan.notifications')
      atom.notifications.addInfo(
        'Command finished',
        {detail}
      )

  onCommandError: (detail, code) ->
    if atom.config.get('artisan.notifications')
      atom.notifications.addError(
        'Command failed',
        {detail}
      )

  artisanPath: ->
    for projectRoot in atom.project.getPaths()
      parts = [projectRoot, 'artisan']
      file = @isFile(parts)
      return file if file

    return null

  isFile: (parts) ->
    try
      p = path.join(parts...)
      return p if fs.lstatSync(p).isFile()
    catch
      return false

  itsLaravelProject: ->
    return true if @artisanPath()

  askForInput: (callback) ->
    new AskView((input) =>
      callback(input)
    )
