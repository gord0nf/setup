return {
  servers = {
    powershell_es = function()
      return {
        bundle_path = vim.fs.joinpath(os.getenv('MASON'), '/packages/powershell-editor-services'),
        shell = vim.fn.executable('pwsh') and 'pwsh' or 'powershell.exe',
      }
    end,
  },
  parsers = { 'powershell' },
}
