-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })

-- Move across splits; at the edge, hand off to the surrounding tmux or Rex pane.
local function navigate(dir)
  local win = vim.api.nvim_get_current_win()
  -- Floats (e.g. the snacks explorer) live outside the split layout; navigate from the split they're anchored to.
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative == "win" and cfg.win then
    win = cfg.win
  end
  local key = ({ left = "h", down = "j", up = "k", right = "l" })[dir]
  local target = vim.api.nvim_win_call(win, function()
    return vim.fn.win_getid(vim.fn.winnr(key))
  end)
  if target ~= win then
    vim.api.nvim_set_current_win(target)
    return
  end
  if vim.env.TMUX then
    vim.system({ "tmux", "select-pane", "-" .. dir:sub(1, 1):upper() })
  elseif vim.env.REX_SESSION and vim.fn.executable("rex") == 1 then
    vim.system({ "rex", "focus", "-s", vim.env.REX_SESSION, dir })
  end
end

for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  vim.keymap.set("n", "<C-" .. key .. ">", function()
    navigate(dir)
  end, { desc = "Navigate " .. dir })
end
