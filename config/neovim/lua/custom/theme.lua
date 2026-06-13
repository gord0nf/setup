-- Table of themes and whether background should be transparent
local THEMES = {
  default = false,
  habamax = true,
  vscode = true,
  slate = false,
  sorbet = false,
  torte = false,
  unokai = true,
}

local colorschemes = {}
for colorscheme, _ in pairs(THEMES) do
  table.insert(colorschemes, colorscheme)
end

local function set_theme(colorscheme)
  vim.cmd.colorscheme(colorscheme)
  if THEMES[colorscheme] then
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
  end
end

set_theme(Settings.theme or 'habamax')
