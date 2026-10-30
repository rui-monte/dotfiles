-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })

-- Move across splits; at the edge, hand off to the surrounding tmux or Rex pane.
local function navigate(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(({ left = "h", down = "j", up = "k", right = "l" })[dir])
  if vim.api.nvim_get_current_win() ~= win then
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
