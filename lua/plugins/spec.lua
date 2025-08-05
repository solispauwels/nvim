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
      vim.api.nvim_set_hl(0, "BufferCurrent", { fg = "#cae965", bg = "#242424", bold = true })
      vim.api.nvim_set_hl(0, "BufferVisible", { fg = "#cae965", bg = "#242424", bold = true })
      vim.api.nvim_set_hl(0, "BufferCurrentSign", { fg = "#cae965", bg = "#242424" })
      vim.api.nvim_set_hl(0, "BufferVisibleSign", { fg = "#cae965", bg = "#242424" })
      
      -- Inactive tabs
      vim.api.nvim_set_hl(0, "BufferInactive", { fg = "#aaaaaa", bg = "#333333" })
      vim.api.nvim_set_hl(0, "BufferInactiveSign", { fg = "#444444", bg = "#333333" })
      
      --Icon
      --vim.api.nvim_set_hl(0, "BufferInactiveIcon", { bg = "#333333" })
      --vim.api.nvim_set_hl(0, "BufferVisibleIcon", { bg = "#242424" })
      --vim.api.nvim_set_hl(0, "BufferCurrentIcon", { bg = "#242424" })

      -- Modified
      vim.api.nvim_set_hl(0, "BufferCurrentMod", { fg = "#c85032", bg = "#242424", bold = true })
      vim.api.nvim_set_hl(0, "BufferInactiveMod", { fg = "#da826c", bg = "#333333" })
      vim.api.nvim_set_hl(0, "BufferVisibleMod", { fg = "#c85032", bg = "#242424" })
      
      vim.api.nvim_set_hl(0, "Todo", { fg = "#8f8f8f", bg = "#ffff00" })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- Optional image support for file preview: See `# Preview Mode` for more information.
      -- {"3rd/image.nvim", opts = {}},
      -- OR use snacks.nvim's image module:
      -- "folke/snacks.nvim",
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    config = function()
      local function open_in_new_terminal(state)
        local node = state.tree:get_node()
        local path = node.path or node.id
    
        -- Launch new Windows Terminal window with Neovim opening the file
        -- You could use "start wt nvim path"
        os.execute('start wt nvim "' .. path .. '"')
      end
      require("neo-tree").setup({
        close_if_last_window = true,
        commands = {
          open_in_new_terminal = open_in_new_terminal, -- hijack the command name
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
          width = 30,
          mappings = {
            ["t"] = "open",
            ["/"] = "none",
            ["w"] = "open_in_new_terminal"
          },
        }
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
      function CloseSmart()
        local buffers = vim.fn.getbufinfo({ buflisted = 1 })
        if #buffers > 1 then
          vim.cmd("BufferClose")  -- or ":bdelete"
        else
          vim.cmd("quit")
        end
      end
      vim.cmd([[
        cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'lua CloseSmart()' : 'q'
      ]])
      --[[
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
      --]]
    end,
  },
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
  {
    "github/copilot.vim",
    event = "BufReadPost", -- Lazy load on insert
    opts = {
    },
    config = function(_, opts)
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_idle_delay = 1000  -- Delay suggestions by 800ms of inactivity
      vim.cmd([[
        imap <silent><script><nowait><expr> <S-Tab> copilot#Accept("\<CR>")
      ]])
    end,
  },
  --[[
  {
    -- Add ALE plugin
    'dense-analysis/ale',
    tag = 'v3.3.0',
    config = function()
      -- Global ALE settings
      vim.g.ale_lint_on_text_changed = 'never' -- Only lint on save
      vim.g.ale_lint_on_insert_leave = 0     -- Don't lint when leaving insert mode
      vim.g.ale_lint_on_filetype_changed = 0

      -- Set the linter for specific filetypes
      vim.g.ale_linters = {
          ['typescript'] = {'eslint'},
          ['javascript'] = {'eslint'},
          ['typescriptreact'] = {'eslint'},
          ['javascriptreact'] = {'eslint'},
      }

      vim.opt.shell = "powershell"
      vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
      vim.opt.shellquote = ""
      vim.opt.shellxquote = ""

      --vim.g.ale_set_project_root = 0

      vim.g.ale_filename_mappings = {
        -- Key: what ALE sees from the linter
        -- Value: what it should be converted to (your actual buffer path)
        ["\\\\wsl$\\Ubuntu\\home\\jorge\\mywaypro\\trade-engine-core"] = "Z:\\home\\jorge\\mywaypro\\trade-engine-core"
      }

      vim.env.ESLINT_D_PPID = tostring(vim.fn.getpid())

      -- Configure ESLint specifically
      vim.g.ale_javascript_eslint_use_global = 1 -- Crucial: Tell ALE to use global ESLint
      vim.g.ale_typescript_eslint_use_global = 1 -- Crucial: Tell ALE to use global ESLint
      
      vim.g.ale_javascript_eslint_executable = 'C:/Users/solis/AppData/Roaming/npm/eslint_d.cmd' -- Path to eslint_d
      vim.g.ale_typecript_eslint_executable = 'C:/Users/solis/AppData/Roaming/npm/eslint_d.cmd' -- Path to eslint_d
      -- You can also try just 'eslint_d' if it's in your PATH

      -- IMPORTANT: Tell ESLint where to find the config on Z:
      --vim.g.ale_javascript_eslint_options = '--config Z:/home/jorge/mywaypro/trade-engine-core/.eslintrc.js --resolve-plugins-relative-to Z:/home/jorge/mywaypro/trade-engine-core'
      vim.g.ale_javascript_eslint_options = '--resolve-plugins-relative-to C:/Users/solis/AppData/Roaming/npm/node_modules'
      --vim.g.ale_typescript_eslint_options = '--config Z:/home/jorge/mywaypro/trade-engine-core/.eslintrc.js --resolve-plugins-relative-to Z:/home/jorge/mywaypro/trade-engine-core'
      vim.g.ale_typescript_eslint_options = '--resolve-plugins-relative-to C:/Users/solis/AppData/Roaming/npm/node_modules'

      -- Debugging ALE:
      vim.g.ale_verbose = 1
      vim.g.ale_echo_msg_format = '[ALE] %s'
      vim.g.ale_statusline_format = {'%s'}
      vim.g.ale_set_highlights = 1
      vim.g.ale_sign_offset = 1000 -- To avoid conflicts with LSP signs
    end
  }
  ]]
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
  }
  --[[,
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Windows-specific command handling
      local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
      local ts_cmd = is_windows
        and { "typescript-language-server.cmd", "--stdio" }
        or { "typescript-language-server", "--stdio" }

      -- Basic diagnostic-only setup
      lspconfig.tsserver.setup({
        cmd = ts_cmd,
        filetypes = {
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "javascript",
          "javascriptreact",
          "javascript.jsx",
        },
        root_dir = lspconfig.util.root_pattern("tsconfig.json", "package.json", ".git"),
        -- Disable everything except diagnostics
        handlers = {
          ["textDocument/publishDiagnostics"] = vim.lsp.handlers["textDocument/publishDiagnostics"],
        },
        on_attach = function(client, bufnr)
          -- Turn off unnecessary capabilities (we don't want completion)
          client.server_capabilities.completionProvider = false
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.signatureHelpProvider = false
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.codeActionProvider = false
          client.server_capabilities.definitionProvider = false
        end,
      })
    end,
  }
  --]]
}
