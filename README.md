# Dotfiles.

Feel free to use, ask any questions, etc. Suggestions for obvious improvements welcome.

## Dotfiles management

I use chezmoi.

### Why chezmoi?

It offers a nice middle-ground in terms of being feature rich but lightweight - you can do a lot more than you can easily with something like `git stow`.

### Why not nix?

Nix offers a lot of power for reproducible builds, and I find the language very enjoyable to read and use. However, I am of the opinion that both nix and home-manager as applied to dotfiles are overkill and personally found imposing a monolithic approach onto something where quick iteration is desirable to be quite frustrating. I frequently make rapid changes to configuration files, and having to wait for a minute or two each time for `home-manager switch` to evaluate is a workflow I simply did not enjoy.

### Why not NixOS?

The above detraction does not apply to NixOS as an operating system. So, why do I use a regular distribution and not NixOS? The long and the short of it is that I do not have a personal usecase for reproducible builds. I am not installing large systems on new hardware regularly, and most situations where I am likely to install a new system these days are systems where I will explicitly prioritize leanness and minimalism over a 900MB NixOS install.

I personally feel that it is somewhat of a shame that I don't have any immediate use-cases for it, as I find working with the language to be very enjoyable. I will possibly use the nix package manager on arch in addition to pacman for managing short-lived and ephemeral environments where having something like stack or cargo polluting my home directory is undesirable. I am not a developer, however, and the main language I use (simply because a lot of useful tools are written in it) is python (despite not loving the language), and I find that `uv` is mostly adequate and unintrusive for ephemeral environments. (I am *very* grateful I no longer have to touch `pip` or `pipx`.)
