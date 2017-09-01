'use babel'

import Path from 'path'
import fs from 'fs'
import { BufferedProcess } from 'atom'

const isArray = val => {
  return Object.prototype.toString.call(val) === '[object Array]'
}

export function loadJSON(path) {
  if (isArray(path)) {
    path = Path.join(...path)
  }

  return JSON.parse(fs.readFileSync(path))
}

export function config(key) {
  return atom.config.get(key)
}

export function isFile(path) {
  try {
    if (typeof path !== 'string') {
      path = Path.join.apply(Path, path)
    }
    if (fs.lstatSync(path).isFile()) {
      return path
    }
  } catch (error) {
    return false
  }
}

export function execute(command, args) {
  return new Promise((resolve, reject) => {
    this.output = ''

    new BufferedProcess({
      command,
      args,
      stdout: data => {
        this.output += data
      },
      exit: code => {
        code === 0 ? resolve(this.output, code) : reject(this.output, code)
      }
    })
  })
}

export function unique(array, keyFunc) {
  let i, len
  const result = []
  const seen = []
  for (i = 0, len = array.length; i < len; i++) {
    let item = array[i]
    let computed = keyFunc(item)
    if (seen.indexOf(computed)) {
      seen.push(computed)
      result.push(item)
    }
  }
  return result
}
