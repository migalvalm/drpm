# Templates

New project copies a folder from here into `projects/`. Put any DragonRuby project here (a folder with
`app/main.rb` and `metadata/game_metadata.txt`) and it shows up in the New project form.

The launcher doesn't ship any: the folders here stay yours and out of the launcher's repo. With none, New project
uses the SDK's own `mygame/`, which every SDK has.

On copy, the launcher leaves out `.git` and `.github`, sets `gameid` and `gametitle` in the metadata, and runs `git init`.
