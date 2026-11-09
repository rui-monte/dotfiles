# AGENTS.md
Agent guide for `/home/rui-monte/dotfiles`.
This repository is a GNU Stow-managed dotfiles repo.
## Repo Layout
- `scripts/` holds the main Bash entry points.
- `shell/` manages `~/.zshenv`.
- `tmux/` manages `~/.tmux.conf`.
- `xdg/` manages most shared `~/.config/*` files.
- `macos/` contains macOS-only config such as Karabiner.
- `xdg/.config/zsh/local.zsh` is ignored and reserved for secrets/local overrides.
- `xdg/.config/opencode/` is tracked, but local runtime artifacts there are ignored.
## External Agent Rules
- No `.cursor/rules/` directory was found.
- No `.cursorrules` file was found.
- No `.github/copilot-instructions.md` file was found.
- Treat this file as the canonical repo guidance unless the user gives newer instructions.
## Core Expectations
- Preserve the GNU Stow package layout; edit repo files, not files under `$HOME`.
- Keep diffs small and targeted.
- Do not commit secrets, tokens, or machine-local paths.
- Assume Linux and macOS are both supported unless a file is clearly platform-specific.
- Favor idempotent shell logic and safe early exits.
- Avoid destructive cleanup of user-managed files or symlinks.
- Keep comments sparse and only where behavior is non-obvious.
## Setup And "Build"
There is no compile step in this repo.
The closest equivalents are install/bootstrap/restow flows.
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rui-monte/dotfiles/main/scripts/install.sh)"
./scripts/bootstrap.sh
./scripts/stow.sh
```
## Homebrew Validation
```sh
brew bundle check --file Brewfile.common
brew bundle check --file Brewfile.linux
brew bundle check --file Brewfile.darwin
```
## Lint And Smoke Checks
There is no unified `make test`, `npm test`, or CI runner.
Use file-type-specific validation.
### Bash
```sh
bash -n scripts/bootstrap.sh
bash -n scripts/install.sh
bash -n scripts/stow.sh
```
### Zsh
```sh
zsh -n xdg/.config/zsh/.zshrc
zsh -n xdg/.config/zsh/rc.d/00-homebrew.zsh
zsh -n xdg/.config/zsh/rc.d/40-fnm.zsh
```
### Lua / Neovim
```sh
stylua --check xdg/.config/nvim/init.lua xdg/.config/nvim/lua
```
- `xdg/.config/nvim/stylua.toml` sets 2-space indentation and 120-column width.
- `stylua` is not installed by the current Brewfiles, so treat it as optional unless the user asks.
- Avoid blind `nvim` startup checks when unnecessary; first launch can bootstrap plugins and mutate local state.
### JSON / Markdown
```sh
prettier --check AGENTS.md
prettier --check xdg/.config/opencode/opencode.json
prettier --check xdg/.config/nvim/.neoconf.json
prettier --check xdg/.config/nvim/lazyvim.json
```
- Use Prettier selectively for ordinary JSON or Markdown.
- Do not run Prettier on `macos/.config/karabiner/karabiner.json` unless the user explicitly wants a full reformat.
## Single-File / Single-Target Checks
When the user asks for a "single test", use the narrowest relevant command.
```sh
bash -n path/to/file.sh
zsh -n path/to/file.zsh
stylua --check path/to/file.lua
prettier --check path/to/file.json
prettier --check path/to/file.md
brew bundle check --file Brewfile.common
```
- There is no repo-level unit test framework.
- In this repo, a "single test" usually means syntax, format, or bundle validation.
## Repo-Specific Notes
- `scripts/bootstrap.sh` installs Homebrew, applies Brewfiles, runs `scripts/stow.sh`, installs TPM, and prepares `~/.config/zsh/local.zsh`.
- `scripts/stow.sh` is the safe restow path after changing package layout.
- `shell/.zshenv` points zsh at `~/.config/zsh`.
- `xdg/.config/zsh/.zshrc` loads modules from `xdg/.config/zsh/rc.d/` by filename order.
- `xdg/.config/nvim/` is a small LazyVim-based config; first startup can install plugins.
- `macos/.config/karabiner/karabiner.json` should be edited surgically.
## Code Style
### General
- Default to ASCII.
- Match the surrounding file's indentation, quoting, and structure.
- Prefer stable, explicit behavior over clever abstractions.
- Keep related entries grouped and, when practical, alphabetized.
- Preserve platform guards and local override hooks.
### Imports And Module Structure
- Lua modules use `require(...)` near the top of the file.
- Neovim plugin files under `xdg/.config/nvim/lua/plugins/` return a Lua table directly.
- Do not add wrapper functions around plugin spec tables unless needed.
- Zsh modules are sourced by numeric filename order from `xdg/.config/zsh/rc.d/`.
- If a new zsh module depends on order, give it a numeric prefix like the existing files.
### Formatting
- Bash scripts use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Bash and Lua both use 2-space indentation in this repo.
- Lua line width is 120 columns via `xdg/.config/nvim/stylua.toml`.
- Multi-line Lua tables keep trailing commas.
- Long tmux commands use backslash continuations instead of unreadable one-liners.
- JSON formatting is file-local; preserve existing indentation rather than normalizing everything.
### Types And Data Shapes
- There are no statically typed languages in this repo.
- In Bash, prefer arrays for list-like data instead of space-delimited strings.
- Keep command output handling explicit in shell.
- In Lua, use plain tables and Neovim APIs directly.
- In JSON config, preserve existing key names and value shapes exactly.
### Naming
- Bash function names use `snake_case`.
- Shell locals are lower_snake_case and declared with `local` inside functions.
- Shell constants are uppercase when effectively immutable, such as `REPO_ROOT`.
- Zsh globals use clear names and `typeset -g` only when intentional.
- Lua plugin filenames are descriptive and map cleanly to module paths.
- Keep Brewfile entries alphabetized within their group unless a file clearly uses another order.
### Error Handling
- Favor early returns over deeply nested shell conditionals.
- Use `command -v tool >/dev/null 2>&1` to gate optional dependencies.
- Print user-facing shell messages with `printf`, not `echo`.
- Exit with non-zero status on unrecoverable shell errors.
- If a platform-specific step can fail safely, log it clearly and continue only when that matches existing behavior.
### Shell Patterns To Follow
- Quote variable expansions unless you explicitly need word splitting.
- Prefer `[[ ... ]]` for tests in Bash and zsh.
- Use `case` for platform branching, as in `scripts/bootstrap.sh` and `scripts/stow.sh`.
- Keep helper functions small and single-purpose.
- Prefer `return` inside helpers and `main "$@"` at the bottom of scripts.
- Use readable guard clauses for optional tools like Homebrew, `fnm`, `zoxide`, and `starship`.
### Neovim Lua Patterns To Follow
- Keep plugin specs declarative.
- Prefer `opts = { ... }` and `keys = { ... }` tables over imperative setup when possible.
- Use built-in APIs like `vim.api.nvim_create_autocmd` directly.
- Keep small config files small; this repo favors tiny focused Lua modules.
- Comment only when overriding or disabling a default is not obvious from the code.
### Config-File Notes
- `tmux/.tmux.conf` follows tmux-native syntax; preserve quoting and escape density carefully.
- `Brewfile.common`, `Brewfile.darwin`, and `Brewfile.linux` are hand-edited and should stay simple.
- `README.md` and agent docs prefer concise prose and short bullet lists.
- Keep secrets and machine-local overrides out of tracked files.
## Files To Avoid Editing By Default
- `xdg/.config/zsh/local.zsh`
- Anything under the user's real `$HOME` instead of the stow package path
- Generated local plugin/runtime state under Neovim or OpenCode directories
## Final Verification Checklist
- If you changed Bash, run `bash -n` on the touched scripts.
- If you changed zsh, run `zsh -n` on the touched files.
- If you changed a Brewfile, run `brew bundle check --file ...` for that file.
- If you changed Lua and `stylua` is available, run `stylua --check` on the touched files.
- If you changed Markdown or standard JSON and `prettier` is available, run `prettier --check` on the touched files.
- If you changed stow package layout, run `./scripts/stow.sh`.
When in doubt, prefer the smallest safe validation command that matches the file type you edited.
