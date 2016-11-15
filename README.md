## Laravel Artisan commands for Atom

Inspired by the Laravel artisan plugin for Sublime Text, this package  allows you to run artisan commands from inside Atom.

### Usage

Open the command menu and select the command you want to run, if a command requires additional arguments (like the `make` commands), you will be prompted for additional input.

### Notes

- The command will run on the first valid laravel project (a project where artisan exists in the project root).
- Commands that require long running processes are not supported (queue:work, serve).
