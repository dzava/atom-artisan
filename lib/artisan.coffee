fs = require 'fs'
path = require 'path'
AskView = require './ask-view'
ResultView = require './result-view'
{CompositeDisposable, BufferedProcess} = require 'atom'

module.exports = Artisan =
  subscriptions: null
  command: null
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
    @command = command

    if @command.needsInput
      @askForInput(@command.caption, (input) =>
        @runCommand(input)
      )
    else
      @runCommand(null)

  runCommand: (input) ->
    phpBinary = atom.config.get('artisan.php')
    args = [
      @artisanPath(),
      @command.command,
    ]

    if input
      args = args.concat(input.split(/\s+/))

    @execute(phpBinary, args)
      .then((output, code) => @onCommandSuccess(output, code))
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
    if @command.showInPanel
      return new ResultView(@command.panelHeading, detail)

    return unless atom.config.get('artisan.notifications')

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
    return unless atom.config.get('artisan.notifications')

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

  askForInput: (caption, callback) ->
    new AskView(caption, (input) =>
      callback(input)
    )
