return {
  {
    "sheerun/vim-wombat-scheme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      --vim.cmd([[colorscheme tokyonight]])
      vim.cmd([[colorscheme wombat]])

      -- Line number highlight
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#857b6f", bg = "#242424" })

      -- Popup menu selection highlight
      vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#242424", bg = "#cae982" })
      
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#444444", bg = "NONE" })

      -- Tab background and separators
      vim.api.nvim_set_hl(0, "BufferTabpageFill", { bg = "#333333" })
      vim.api.nvim_set_hl(0, "BufferOffset", { bg = "#333333" })

      -- Active tab
      --[[vim.api.nvim_set_hl(0, "BufferCurrent", { fg = "#cae965", bg = "#242424", bold = true })
      vim.api.nvim_set_hl(0, "BufferVisible", { fg = "#cae965", bg = "#242424", bold = true })
      vim.api.nvim_set_hl(0, "BufferCurrentSign", { fg = "#cae965", bg = "#242424" })
      vim.api.nvim_set_hl(0, "BufferVisibleSign", { fg = "#cae965", bg = "#242424" })
      
      vim.api.nvim_set_hl(0, "BufferInactive", { fg = "#aaaaaa", bg = "#333333" })
      vim.api.nvim_set_hl(0, "BufferInactiveSign", { fg = "#444444", bg = "#333333" })
      
      vim.api.nvim_set_hl(0, "BufferCurrentMod", { fg = "#c85032", bg = "#242424", bold = true })
      vim.api.nvim_set_hl(0, "BufferInactiveMod", { fg = "#da826c", bg = "#333333" })
      vim.api.nvim_set_hl(0, "BufferVisibleMod", { fg = "#c85032", bg = "#242424" })
      --]]

      -- vim.api.nvim_set_hl(0, "Todo", { fg = "#8f8f8f", bg = "#ffff00" })
    end,
  },
  --[[
  {
    "akinsho/bufferline.nvim",
    version = "*",
    opts = {
      options = {
        mode = "tabs",
        show_buffer_close_icons = false,
        show_close_icon = false,
        --always_show_bufferline = false,
        --separator_style = "thick", 
        separator_style = {"", ""}, 
        tab_size = 10,             
        max_name_length = 20,      
        diagnostics = "nvim_lsp",
        -- padding is controlled by these two:
        --indicator = { style = "underline" },
        numbers = "none",
      },
      highlights = {
        fill = {
          bg = "#2e2e2e"
        },
        -[
        background = {
          fg = "#5c6370",
          bg = "#1e222a",
        },
        tab = {
          fg = "#5c6370",
          bg = "#1e222a",
        },
        tab_selected = {
          fg = "#ffffff",
          bg = "#282c34",
        },
        tab_close = {
          fg = "#ff6c6b",
          bg = "#1e222a",
        },
        separator = {
          fg = "#1e222a",
          bg = "#1e222a",
        },
        separator_selected = {
          fg = "#282c34",
          bg = "#282c34",
        },
        indicator_selected = {
          fg = "#61afef",
          bg = "#282c34",
        },
        -]
      },
    },
  },
  --]]
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false, -- neo-tree will lazily load itself
    config = function()
      local function open_in_new_terminal(state)
        local node = state.tree:get_node()
        local path = node.path or node.id
    
        local cmd = {
          "wt.exe",
          "new-tab",
          "ubuntu",
          "run",
          "nvim", path,
        }

        vim.system(cmd, { detach = true })
      end
      require("neo-tree").setup({
        -- close_if_last_window = true,
        commands = {
          open_in_new_terminal = open_in_new_terminal,
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          filtered_items = {
            visible = true,  -- Show hidden files (dotfiles)
            -- hide_dotfiles = false,  -- Do not hide dotfiles
            -- hide_gitignored = false,  -- Optional: also show gitignored files
          }
        },
        window = {
          position = "left",
          width = 40,
          mappings = {
            --["<CR>"] = "open_replace",
            ["/"] = "none",
            ["t"] = "open_tabnew",
            ["w"] = "open_in_new_terminal"
          },
        },
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("neo-tree.command").execute({
            action = "show",
            source = "filesystem",
            position = "left",
            reveal = true,  -- reveal current file
          })
        end,
      })
      --[[
      function CloseSmart()
        local buffers = vim.fn.getbufinfo({ buflisted = 1 })
        if #buffers > 1 then
          vim.cmd("BufferClose")  -- or ":bdelete"
        else
          vim.cmd("quit")
        end
      end
      vim.cmd(--[[
        cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'lua CloseSmart()' : 'q'
      ]]--)
      --]]
      vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
          vim.schedule(function()
            -- Only show if Neo-tree isn't already open in this tab
            local found = false
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local buf = vim.api.nvim_win_get_buf(win)
              local bufname = vim.api.nvim_buf_get_name(buf)
              if bufname:match("neo%-tree") then
                found = true
                break
              end
            end
            if not found then
              require("neo-tree.command").execute({
                action = "show",
                source = "filesystem",
                position = "left",
                reveal = true,  -- reveal current file
              })
            end
          end)
        end,
      })
      -- Close neo-tree iff it's the only remaining window in the *current tab*
      local function close_neotree_if_last_in_tab()
        local tab  = vim.api.nvim_get_current_tabpage()
        local wins = vim.api.nvim_tabpage_list_wins(tab)

        local non_neotree = 0
        local neotree_wins = {}

        for _, w in ipairs(wins) do
          local cfg = vim.api.nvim_win_get_config(w)
          if cfg.relative == "" then               -- ignore floating windows
            local buf = vim.api.nvim_win_get_buf(w)
            local ft  = vim.bo[buf].filetype
            if ft == "neo-tree" then
              table.insert(neotree_wins, w)
            else
              non_neotree = non_neotree + 1
            end
          end
        end

        -- Only neo-tree left in *this* tab
        if non_neotree == 0 and #neotree_wins > 0 then
          if vim.fn.tabpagenr("$") == 1 then
            -- Last tab: don't try to close the last window; just quit cleanly
            pcall(vim.cmd, "quit")
            return
          end
          -- Otherwise, close neotree windows in this tab
          for _, w in ipairs(neotree_wins) do
            if vim.api.nvim_win_is_valid(w) then
              pcall(vim.api.nvim_win_close, w, true) -- force close just in case
            end
          end
        end
      end

      -- Trigger only when windows/buffers actually close; defer to let layout settle
      vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" }, {
        callback = function()
          vim.defer_fn(close_neotree_if_last_in_tab, 0)
        end,
      })

      vim.cmd([[
        highlight NeoTreeGitModified guifg=#e6db74
      ]])
    end,
  },
  {
    "nanozuki/tabby.nvim",
    event = "VeryLazy",
    config = function()
   
    -- nvim-tree/nvim-web-devicons
    local devicons = require("nvim-web-devicons")
    local SEP = "▎"
    local theme = {
      -- fill = 'Wombat',
      fill = { fg='#e3e0d7', bg='#2e2e2e' },
      -- current_tab = 'TabLineSel',
      current_tab = { fg='#e3e0d7', bg='#242424' },
      current_sep = { fg='#e3e0d7', bg='#8cf8f7' },
      --tab = 'TabLine',
      tab = { fg='#626262', bg='#2e2e2e' },
      tab_sep = { fg='#2e2e2e', bg='#3d3d3d' },
      win = 'TabLine',
      tail = 'TabLine',
      modified = { fg = "#ff4d4f" },
    }

    local function get_main_buf_in_tab(tabid)
      -- look at all windows in this tab
      local wins = vim.api.nvim_tabpage_list_wins(tabid)
      for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        if ft ~= "neo-tree" and ft ~= "neo-tree-popup" then
          return buf
        end
      end

      -- fallback: current window in tab (if all are neo-tree)
      local ok, win = pcall(vim.api.nvim_tabpage_get_win, tabid)
      if ok then
        return vim.api.nvim_win_get_buf(win)
      end
      return vim.api.nvim_get_current_buf()
    end

    local function buf_icon(tab)
      local buf = get_main_buf_in_tab(tab.id)
      local full_name = vim.api.nvim_buf_get_name(buf)
      local name = full_name ~= "" and full_name or "[No Name]"
      local filename = vim.fn.fnamemodify(name, ":t")
      local ext = vim.fn.fnamemodify(filename, ":e")
      
      local icon, icon_hl = devicons.get_icon(filename, ext, { default = true })

      local hl_def = vim.api.nvim_get_hl(0, { name = icon_hl, link = false })
      local fg = hl_def.fg and string.format("#%06x", hl_def.fg) or nil
      local bg = tab.is_current() and "#242424" or "#2e2e2e"

      return icon or "", { fg = fg, bg = bg }
    end

    local function tab_modified(tab)
      local ok_win, win = pcall(vim.api.nvim_tabpage_get_win, tab.id)
      if not ok_win then return false end
      local buf = vim.api.nvim_win_get_buf(win)
      return vim.bo[buf].modified
    end
      
    require('tabby').setup({
      line = function(line)
        return {
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            local hls = tab.is_current() and theme.current_sep or theme.tab_sep
            local icon, icon_hl = buf_icon(tab)
            
            return {
              line.sep(SEP, hls, hl),
              { icon .. " ", hl = icon_hl },
              tab.name(),
              tab_modified(tab) and { " ●", hl = { fg = theme.modified.fg, bg = icon_hl.bg }  } or "",
              " ",
              hl = hl,
            }
          end),
          line.spacer(),
          hl = theme.fill,
        }
      end,
      option = {
        tab_name = {
          override = function(tabid)
            local buf = get_main_buf_in_tab(tabid)
            local name = vim.api.nvim_buf_get_name(buf)
            if name == "" then return "[No Name]" end
            return vim.fn.fnamemodify(name, ":t:r") -- tail, then remove extension
          end,
          name_fallback = function(_) return "[No Name]" end,
        },

        -- (Optional) how window/buffer names are shown by win.buf_name()/buf.name()
        buf_name = {
          mode = "unique", -- or 'relative' | 'tail' | 'shorten'
        },
      },
    }) 
    end,
  },
  --[[
  {
    'romgrk/barbar.nvim',
    dependencies = {
      -- 'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    config = function()
      require("barbar").setup({
        icons = {
          buffer_index = false,    -- turn off buffer numbers
          buffer_number = false,
          button = '',             -- this removes the X close icon
          filetype = { enabled = true },
          separator = { left = '▎', right = ' ' },
          --pinned = {separator = { right = '', left = ''} },
          inactive = { separator = {left = '▎', right = ' '} },
          separator_at_end = false,
          modified = { button = ' ●' }, -- keep this or remove
          --preset = 'slanted',
        },
        hide = { extensions = true },
        tabpages = false,         -- <--- disables the 2/2 indicator
        maximum_padding = 0,      -- reduce padding between tabs
        minimum_padding = 0,
      })
    end,
  },
  --]]
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          disabled_filetypes = {
            statusline = { "neo-tree" },
            winbar = { "neo-tree" },
          },
        },
        sections = {
          lualine_c = {
          {
              'filename',
              path = 2  -- Show full absolute path
            }
          }
        }
      })
    end
  },
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    config = function()
      require("scrollbar").setup({
        handle = {
          color = "#555555", -- Customize color
        },
        excluded_filetypes = { "neo-tree", "neo-tree-popup", "NvimTree" },
      })
    end
  },
  --[[
  {
    "github/copilot.vim",
    event = "BufReadPost", -- Lazy load on insert
    opts = {
    },
    config = function(_, opts)
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_idle_delay = 1000  -- Delay suggestions by 800ms of inactivity
      vim.cmd([
        imap <silent><script><nowait><expr> <S-Tab> copilot#Accept("\<CR>")
      ])
    end,
  },
  --]]
  {
    "prisma/vim-prisma",
    ft = "prisma",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.install").prefer_git = false -- force downloading binaries

      require("nvim-treesitter.configs").setup {
        ensure_installed = { "typescript", "tsx", "javascript", "lua", "vim" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { 
          enable = true 
        },
      }
    end,
  },
  {
    "echasnovski/mini.indentscope",
    version = false, -- latest version from Git
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Highlight color (adjust as needed)
      vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#333333", nocombine = true })

      require("mini.indentscope").setup({
        draw = {
          delay = 0,
          animation = require("mini.indentscope").gen_animation.none(), -- disable animation
        },
        symbol = "│", -- You can also use "▏", "┆", etc.
        options = {
          border = "both", -- default: only draw inside the scope
          try_as_border = true,
        },
      })
    end,
  },
  --[[
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "eslint",
        },
      })

      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      lspconfig.ts_ls.setup({
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.definitionProvider = false
        end,
        root_dir = util.root_pattern("tsconfig.json", "package.json", ".git"),
      })

      lspconfig.eslint.setup({
        on_attach = function(client, bufnr)
          client.handlers["textDocument/publishDiagnostics"] = function() end

          vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = bufnr,
            callback = function()
              -- manually request diagnostics from ESLint
              vim.lsp.buf.notify(bufnr, "textDocument/didSave", {
                textDocument = { uri = vim.uri_from_bufnr(bufnr) }
              })
            end,
          })
        end,
        settings = {
          format = false,
        },
      })
    end,
  },--]]
  {
    "dense-analysis/ale",
    -- tag = "v3.3.0",
    init = function()
      vim.g.ale_linters_explicit = 1

      vim.g.ale_linters = {
        javascript        = { "eslint" },
        typescript        = { "tsserver", "eslint" },
        javascriptreact   = { "eslint" },
        typescriptreact   = { "eslint" },
      }

      vim.g.ale_lint_on_save = 1
      vim.g.ale_completion_autoimport = 1
      vim.g.ale_lint_on_text_changed = "never"
      vim.g.ale_lint_on_insert_leave = 0
      vim.g.ale_lint_on_enter = 0
      vim.g.ale_echo_cursor = 1
      vim.g.ale_jump_on_error = 0
      vim.g.ale_use_neovim_diagnostics_api = 1
      vim.g.ale_sign_error = '>>'
      vim.g.ale_sign_warning = '--'

      vim.g.ale_javascript_eslint_executable = "eslint"
      vim.g.ale_typescript_eslint_executable = "eslint"

      vim.g.ale_fix_on_save = 0

      -- Debugging ALE:
      vim.g.ale_verbose = 1
      vim.g.ale_echo_msg_format = '[ALE] %s'
      vim.g.ale_statusline_format = {'%s'}
      vim.g.ale_set_highlights = 1
      vim.g.ale_sign_offset = 1000 -- To avoid conflicts with LSP signs
    end,
    config = function()
      -- --- Lua version of ALELSPMappings
      local function ALELSPMappings()
        local ft = vim.bo.filetype
        local linters = vim.fn["ale#linter#Get"](ft) or {}
        local lsp_found = false

        for _, l in ipairs(linters) do
          local v = l.lsp
          if v ~= nil and ((type(v) == "table" and next(v) ~= nil) or v == 1 or v == true or (type(v) == "string" and v ~= "")) then
            lsp_found = true
            break
          end
        end

        if not lsp_found then return end

        -- Context menu entries
        vim.cmd("noremenu PopUp.Documentation :ALEDocumentation<CR>")
        vim.cmd("noremenu PopUp.Find\\ references :ALEFindReferences<CR>")
        vim.cmd("noremenu PopUp.Go\\ to\\ definition :ALEGoToDefinition -split<CR>")
        vim.cmd("noremenu PopUp.Go\\ to\\ type\\ definition :ALEGoToTypeDefinition -split<CR>")
        vim.cmd("noremenu PopUp.ALE\\ Hover :ALEHover<CR>")

        -- Mouse mappings (normal + insert) — needs :set mouse=a if you want clicks
        vim.keymap.set("n", "<MiddleMouse>", function() vim.cmd("ALEGoToDefinition -split") end, { silent = true, desc = "ALE Go to definition (split)" })
        vim.keymap.set("i", "<MiddleMouse>", function() vim.cmd("stopinsert | ALEGoToDefinition -split | startinsert") end, { silent = true, desc = "ALE Go to definition (split)" })

        vim.keymap.set("n", "<2-MiddleMouse>", function() vim.cmd("ALEGoToTypeDefinition -split") end, { silent = true, desc = "ALE Go to type definition (split)" })
        vim.keymap.set("i", "<2-MiddleMouse>", function() vim.cmd("stopinsert | ALEGoToTypeDefinition -split | startinsert") end, { silent = true, desc = "ALE Go to type definition (split)" })
      end

      -- Autocmds to wire it up
      local grp = vim.api.nvim_create_augroup("ALE_LSP_MAPPINGS", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = grp,
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        callback = ALELSPMappings,
        desc = "Setup ALE LSP mappings for JS/TS buffers",
      })
      vim.api.nvim_create_autocmd("User", {
        group = grp,
        pattern = "ALELintPost",
        callback = ALELSPMappings,
        desc = "Re-run mapping setup when ALE finishes linting",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 5000,
        },
        formatters_by_ft = {
          typescript = { "eslint_d", "prettier" },
          typescriptreact = { "eslint_d", "prettier" },
          javascript = { "eslint_d", "prettier" },
          javascriptreact = { "eslint_d", "prettier" },
        },
      })
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        TODO = { icon = "", color = "warning" },
      },
      highlight = {
        keyword = "bg",
        pattern = [[.*<(TODO)>]],
      },
      search = {
        pattern = [[\b(TODO)\b]],
      },
    }
  }
}
