return {
  parsers = {
    'diff',
    'html',
    'json',
    'markdown',
    'markdown_inline',
    'printf',
    'query',
    'regex',
    'toml',
    'vim',
    'vimdoc',
    'xml',
    'yaml',
  },
  servers = { jsonls = {} },
  plugins = {
    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = function(_, opts)
        local npairs = require('nvim-autopairs')
        npairs.setup(opts)

        -- Custom rules
        local Rule = require('nvim-autopairs.rule')
        local cond = require('nvim-autopairs.conds')
        npairs.add_rules({
          Rule('<', '>'):with_pair(cond.not_before_regex('[<%s=]')),
        })
      end,
    },
  },
}
