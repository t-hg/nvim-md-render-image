print("Hello from nvim-md-render-image")

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

  --local to_sixel_command = string.format("img2sixel -w 800 -- '%s'", uri)
  --local handle = io.popen(to_sixel_command)

  --if not handle then
  --  return
  --end

  --local data = handle:read("*a")
  --handle:close()

  local namespace = vim.api.nvim_create_namespace('nvim_md_render_image_extmark')
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_extmark(0, namespace, row-1, 0, {
    virt_lines = {{{"", ""}}}
  })

  local stdout = vim.loop.new_tty(1, false)
  stdout:write("\x1b[2;0H")
  stdout:write("\x1b[31mHI THERE")
end

local function setup()
  vim.api.nvim_create_user_command("RenderImage", render_image, { nargs = 0, desc = "Render image" })
end

return {
  setup = setup
}
