## Laravel Artisan commands for Atom

Inspired by the Laravel artisan plugin for Sublime Text, this package  allows you to run artisan commands from inside Atom.

### Usage

Open the command menu and select the command you want to run, if a command requires additional arguments (like the `make` commands), you will be prompted for additional input.

### Custom commands

Set the `Custom commands` setting to a JSON file containing custom commands. Custom commands will override the default when the names match.

#### Command structure
```json
{
  "name": "the name that will appear in the command menu",
  "command": "the artisan command to run",
  "needsInput": true,
  "caption": "the message that will be displayed when asking for input",
  "showInPanel": true
}
```

### Notes

- The command will run on the first valid Laravel project (a project where artisan exists in the project root).
- Commands that require long running processes are not supported (queue:work, serve).
