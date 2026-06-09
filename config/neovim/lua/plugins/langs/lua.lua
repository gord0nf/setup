-- lua stuff isn't fully supported on aarch64 yet (but it usually can be installed via pkg manager)
local is_aarch = vim.loop.os_uname().machine == 'aarch64'

return {

  servers = {
    lua_ls = {
      mason = not is_aarch,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
  },

  parsers = {
    'lua',
    'luadoc',
    'luap',
  },

  formatters_by_ft = {
    lua = { 'stylua', mason = not is_aarch },
  },
}
