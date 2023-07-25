-- workaround to satisfy linter who doesn't know
-- about the vim global
vim = vim

local function render_image()
  local line = tostring(vim.api.nvim_get_current_line())
  local inline_link = line:match('!%[.-%]%(.-%)')

  if not inline_link then
    return
  end

  local uri = inline_link:match('%((.+)%)')

  -- sanitize uri otherwise vulnerable against
  -- os command injection, e.g.:
  -- [image](" || touch pwned && echo "pwnd)
  uri = uri:gsub("'", "\\'")
  uri = uri:gsub("\\", "\\\\")

  local to_sixel_command = string.format("img2sixel -- '%s'", uri)
  local handle = io.popen(to_sixel_command)

  if not handle then
    return
  end

  local data = handle:read("*a")
  handle:close()

  local stdout = vim.loop.new_tty(1, false)
  stdout:write(data)
end

local function setup()
  vim.api.nvim_create_user_command("RenderImage", render_image, { nargs = 0, desc = "Render image" })
end

return {
  setup = setup
}
