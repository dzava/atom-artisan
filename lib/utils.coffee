fs = require('fs')
Path = require('path')
{BufferedProcess} = require 'atom'

module.exports =
class Utils
  @config: (key) ->
    return atom.config.get(key)

  @execute: (command, args) ->
    new Promise((resolve, reject) ->
      @output = ''
      new BufferedProcess({
        command,
        args,
        stdout: (data) => @output += data
        exit: (code) => if code == 0 then resolve(@output, code) else reject(@output, code)
      })
    )

  @isFile: (path) ->
    try
      if typeof path != 'string'
        path = Path.join(path...)
      return path if fs.lstatSync(path).isFile()
    catch
      return false

  @loadJSON: (path) ->
    if typeof path != 'string'
      path = Path.join(path...)

    return JSON.parse(fs.readFileSync(path))

  @unique: (array, test) ->
    result = []
    seen = []
    for item in array
      computed = test(item)
      if seen.indexOf(computed)
        seen.push(computed)
        result.push(item)

    return result
