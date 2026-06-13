return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      winopts = { fullscreen = true },
      keymap = {
        builtin = {
          ['<C-j>'] = 'preview-down',
          ['<C-k>'] = 'preview-up',
          ['<C-S-j>'] = 'preview-page-down',
          ['<C-S-k>'] = 'preview-page-up',
          ['<C-l>'] = 'toggle-preview-wrap',
          ['<C-space>'] = 'toggle-preview',
        },
      },
    },
    keys = {
      { '<leader> ', '<cmd>FzfLua global<cr>', desc = 'Fzf find files' },
      { '<leader>/', '<cmd>FzfLua live_grep<cr>', desc = 'Fzf live grep' },
      {
        '<leader>fc',
        function()
          require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })
        end,
        desc = 'Fzf find config files',
      },
      {
        '<leader>fs',
        function()
          require('fzf-lua').files({ cwd = vim.fn.getenv('SOFTWARE') })
        end,
        desc = 'Fzf find software files',
      },
      { '<leader>gs', '<cmd>FzfLua git_status<cr>', desc = 'Fzf git status' },
      { '<leader>gb', '<cmd>FzfLua git_blame<cr>', desc = 'Fzf git blame' },
      { '<leader>gc', '<cmd>FzfLua git_commits<cr>', desc = 'Fzf git commits' },
      { '<leader>z', '<cmd>FzfLua spellcheck<cr>', desc = 'Fzf git commits' },
    },
  },
  {
    'nvim-mini/mini.files',
    version = '*',
    config = function()
      require('mini.files').setup({
        options = { use_as_default_explorer = true },
        mappings = {
          close = '<Esc>',
          reset = '<BS>',
          synchronize = '<CR>',
          go_in_plus = 'L',
        },
      })
    end,
    keys = {
      {
        '<leader>e',
        function()
          MiniFiles.open()
        end,
        desc = 'MiniFiles open',
      },
    },
  },
}
