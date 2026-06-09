return {
  parsers = { 'bash' },
  servers = { bashls = {} },
  formatters_by_ft = {
    bash = { 'shfmt' },
    sh = { 'shfmt' },
  },
}
