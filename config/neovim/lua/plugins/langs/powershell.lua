local mason = os.getenv('MASON')
if not mason or #mason == 0 then
  error('cannot get mason path')
end

return {
  servers = {
    powershell_es = {
      bundle_path = vim.fs.joinpath(mason, '/packages/powershell-editor-services'),
      shell = vim.fn.executable('pwsh') and 'pwsh' or 'powershell.exe',
    },
  },
  parsers = { 'powershell' },
}
