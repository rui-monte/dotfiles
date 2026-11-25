-- tmux-style keys: ctrl+b prefix plus prefix-free ctrl+h/j/k/l pane moves that defer to vim.

local function in_vim(ctx)
  local ok, proc = pcall(
    rex.call,
    "com.superlogical.terminal.process",
    { session_id = ctx.session_id, block_id = ctx.block_id }
  )
  local name = ok and proc and proc.foreground and proc.foreground.name or ""
  return name:match("^g?n?vim?x?$") ~= nil or name == "view"
end

-- Key handlers can't queue client actions, so these call the session API directly.
local function unless_vim(method, args)
  return function(ctx)
    if in_vim(ctx) then
      return false
    end
    rex.session[method](args or {})
    return true
  end
end

rex.bind("ctrl+h", unless_vim("focus_direction", { direction = "left" }))
rex.bind("ctrl+j", unless_vim("focus_direction", { direction = "down" }))
rex.bind("ctrl+k", unless_vim("focus_direction", { direction = "up" }))
rex.bind("ctrl+l", unless_vim("focus_direction", { direction = "right" }))
rex.bind("ctrl+space", unless_vim("focus_next_pane"))

rex.bind("ctrl+b>shift+5", "pane.split.right")
rex.bind("ctrl+b>shift+'", "pane.split.down")
rex.bind("ctrl+b>x", "pane.close")
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("ctrl+b>o", "pane.focus_next")
rex.bind("ctrl+b>space", "pane.balance")
rex.bind("ctrl+b>shift+1", "pane.move_to_new_tab")
rex.bind("ctrl+b>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+b>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+b>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+b>l", "pane.focus", { direction = "right" })
rex.bind("ctrl+b>shift+h", "pane.resize", { direction = "left" })
rex.bind("ctrl+b>shift+j", "pane.resize", { direction = "down" })
rex.bind("ctrl+b>shift+k", "pane.resize", { direction = "up" })
rex.bind("ctrl+b>shift+l", "pane.resize", { direction = "right" })

rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>n", "client.tab.next")
rex.bind("ctrl+b>p", "client.tab.previous")
rex.bind("ctrl+b>,", "client.tab.rename")
rex.bind("ctrl+b>shift+7", "client.tab.close")
for i = 1, 9 do
  rex.bind("ctrl+b>" .. i, "client.tab.goto", { index = i })
end

rex.bind("ctrl+b>s", "session.switch")
rex.bind("ctrl+b>shift+4", "session.rename")
rex.bind("ctrl+b>shift+9", "session.previous")
rex.bind("ctrl+b>shift+0", "session.next")
rex.bind("ctrl+b>[", "client.find.open")
