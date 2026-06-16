local plugins = {
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '*',

    ---@module 'blink.cmp'
    opts = {
      fuzzy = { implementation = 'lua' }, -- should be 'prefer_rust' but Windows doesn't like it...
      signature = { enabled = true },
      keymap = {
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'normal',
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
      cmdline = { completion = { ghost_text = { enabled = true } } },
      sources = {
        default = { 'lsp', 'snippets', 'path', 'buffer' },
      },
    },
    opts_extend = { 'sources.default' },
  },
  { 'tpope/vim-surround' },
}

if Settings.flash then
  table.insert(plugins, {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      jump = { inclusive = true },
      modes = {
        char = { jump_labels = true },
      },
    },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  })
end

if Settings.tmux ~= false then
  table.insert(plugins, {
    'preservim/vimux',
    keys = {
      { '<leader>vp', '<cmd>VimuxPromptCommand<cr>', desc = 'Vimux prompt cmd' },
      { '<leader>vl', '<cmd>VimuxRunLastCommand<cr>', desc = 'Vimux run last' },
      { '<leader>vi', '<cmd>VimuxInspectRunner<cr>', desc = 'Vimux inspect runner' },
      { '<leader>vz', '<cmd>VimuxZoomRunner<cr>', desc = 'Vimux zoom runner' },
    },
  })
end

return plugins
