return {
  servers = {
    powershell_es = function()
      return {
        bundle_path = vim.fs.joinpath(os.getenv('MASON'), '/packages/powershell-editor-services'),
        shell = vim.fn.executable('pwsh') and 'pwsh' or 'powershell.exe',
        on_attach = function(_, bufnr)
          vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
        end,
        settings = { powershell = { codeFormatting = { Preset = 'OTBS' } } },
      }
    end,
  },
  parsers = { 'powershell' },
}
