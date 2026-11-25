-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Prefer the git root over LSP roots (helm_ls roots at the chart dir, narrowing <leader>ff)
vim.g.root_spec = { { ".git", "lua" }, "lsp", "cwd" }
