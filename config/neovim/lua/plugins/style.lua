return {
  {
    'Mofiqul/vscode.nvim',
    config = function()
      vim.o.background = 'dark'

      local c = require('vscode.colors').get_colors()
      require('vscode').setup({
        transparent = true,
        italic_comments = true,
        italic_inlayhints = true,
        underline_links = true,
        disable_nvimtree_bg = true,
        color_overrides = {
          vscLineNumber = '#FFFFFF',
        },
        group_overrides = {
          Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        },
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        globalstatus = true,
      },
      sections = {
        lualine_c = {
          {
            'filename',
            file_status = false,
            path = 1,
          },
        },
        lualine_x = {
          'import',
        },
        lualine_y = {
          {
            function()
              local lsps = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() })
              local icon = require('nvim-web-devicons').get_icon_by_filetype(
                vim.api.nvim_get_option_value('filetype', { buf = 0 })
              )
              if lsps and #lsps > 0 then
                local names = {}
                for _, lsp in ipairs(lsps) do
                  table.insert(names, lsp.name)
                end
                return string.format('%s %s', table.concat(names, ', '), icon)
              else
                return icon or ''
              end
            end,
            on_click = function()
              vim.api.nvim_command('LspInfo')
            end,
            color = function()
              local _, color = require('nvim-web-devicons').get_icon_cterm_color_by_filetype(
                vim.api.nvim_get_option_value('filetype', { buf = 0 })
              )
              return { fg = color }
            end,
          },
          'encoding',
          'progress',
        },
      },
    },
  },
  { 'brenoprata10/nvim-highlight-colors' },
  {
    'saghen/blink.cmp',
    opts = function(_, opts)
      vim.tbl_deep_extend('force', opts, {
        completion = {
          menu = {
            draw = {
              components = {
                -- customize the drawing of kind icons
                kind_icon = {
                  text = function(ctx)
                    -- default kind icon
                    local icon = ctx.kind_icon
                    -- if LSP source, check for color derived from documentation
                    if ctx.item.source_name == 'LSP' then
                      local color_item =
                        require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                      if color_item and color_item.abbr ~= '' then
                        icon = color_item.abbr
                      end
                    end
                    return icon .. ctx.icon_gap
                  end,
                  highlight = function(ctx)
                    -- default highlight group
                    local highlight = 'BlinkCmpKind' .. ctx.kind
                    -- if LSP source, check for color derived from documentation
                    if ctx.item.source_name == 'LSP' then
                      local color_item =
                        require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                      if color_item and color_item.abbr_hl_group then
                        highlight = color_item.abbr_hl_group
                      end
                    end
                    return highlight
                  end,
                },
              },
            },
          },
        },
      })
    end,
  },
}
