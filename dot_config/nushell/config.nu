# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.
use '/home/hearth/.config/broot/launcher/nushell/br' *

$env.config.buffer_editor = "helix"

$env.config.show_banner = false

$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 100_000_000
$env.config.history.isolation = true

# I literally cannot think of anything worse than getting
# yourself in the habit of thinking 'rm' will send stuff
# to trash, in case you ever remote into something and forget
$env.config.rm.always_trash = false

alias task = task rc:/home/hearth/.task/.taskrc

use utils *

source ~/.config/zoxide/zoxide.nu
