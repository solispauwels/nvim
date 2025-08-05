vim.opt.background = "dark"

-- Bootstrap Lazy.nvim
require("config.lazy")

-- Clipboard & mouse behavior
--vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.selection = "exclusive"
vim.opt.selectmode = { "mouse", "key" }
vim.opt.mousemodel = "popup"
vim.opt.keymodel = { "startsel", "stopsel" }
vim.opt.whichwrap = [[b,s,<,>h,l]]
vim.o.title = true

-- Swap, backup, search, UI tweaks
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.ignorecase = true
--vim.opt.incsearch = true
--vim.opt.hlsearch = true
--vim.opt.cursorline = false
vim.opt.colorcolumn = "120"
--vim.opt.modelines = 0
--vim.opt.modeline = false
vim.opt.number = true
--vim.opt.autochdir = true
--vim.opt.formatoptions:append("r")
--vim.opt.breakindent = true
--vim.opt.paste = true
vim.opt.tabstop = 4
vim.opt.wildignore:append({ "*/generated/*", "*/node_modules/*", "*/dist/*", "*/private/*", "*/.git/*" })
vim.opt.comments:remove("://")
--vim.cmd.colorscheme("wombat")
vim.opt.wrap = false 

-- Optionally set tab/indent preferences
vim.opt.tabstop = 2         -- Number of visual spaces per TAB
vim.opt.softtabstop = 0     -- Number of spaces inserted for a <Tab> (0 = use shiftwidth)
vim.opt.expandtab = true    -- Use spaces instead of tabs
vim.opt.shiftwidth = 2      -- Number of spaces to use for autoindent
vim.opt.smarttab = true     -- Use shiftwidth when pressing <Tab> at beginning of line

-- Keymaps
local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function move_left()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 and row > 1 then
    -- At start of line (not first line) → wrap left
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-O>h", true, false, true), "n", false)
  else
    -- Normal move left
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), "n", false)
  end
end

local function move_right()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  if col == #line then
    -- On last character of the line: simulate <Right> that wraps
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-O>l", true, false, true), "n", false)
  else
    -- Standard insert-mode <Right>
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", false)
  end
end

--[[
local function clean_paste()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>"+pa', true, false, true), "n", false)
end
]]

local function command_paste()
  local clip = vim.fn.getreg("+")
  vim.api.nvim_feedkeys(clip, "t", false)
end

-- Right-click context menu (noop in terminal, skip)
-- You can implement a custom menu if you use a GUI frontend

map("n", "Y", "Y")
map("n", "P", "P")

map("i", "<Left>", move_left)
map("i", "<Right>", move_right)

-- Copy/Cut/Paste
map("n", "<C-C>", '"+y')
map("v", "<C-C>", '"+y')
map("n", "<C-X>", '"+d')
map("v", "<C-X>", '"+d')
map("n", "<C-V>", '"+gP')
--map("v", "<C-V>", '"+gP')
map("v", "<C-V>", '<MiddleMouse>')
--map("i", "<C-V>", '<C-R>+')
--map("i", "<C-V>", clean_paste)
map("i", "<C-V>", "<MiddleMouse>")
map("c", "<C-V>", command_paste)

-- Undo/Redo
map("n", "<C-Z>", "u")
map("v", "<C-Z>", "u")
map("n", "<C-Y>", "<C-R>")
map("v", "<C-Y>", "<C-R>")
map("i", "<C-Z>", "<C-O>u")
map("i", "<C-Y>", "<C-O><C-R>")
map("c", "<C-Z>", "<C-C><C-Z>")
map("c", "<C-Y>", "<C-C><C-R>")

-- Select all
map("i", "<C-A>", "<Esc>ggVG")
map("n", "<C-A>", "ggVG")
map("v", "<C-A>", "ggVG")
map("c", "<C-A>", "<C-B>ggVG<C-E>")

-- Delete
map("v", "<BS>", '"_d')

-- Save
map("n", "<C-S>", ":w<CR>")
map("i", "<C-S>", "<Esc>:w<CR>a")
map("c", "<C-S>", "<C-C>:w<CR>")

-- Search
map("n", "<C-F>", "/")
map("i", "<C-F>", "<C-O>/")
map("c", "<C-F>", "<C-C>/")

-- Prompt replacement (if implemented)
map("n", "<C-H>", ":promptrepl<CR>")
map("i", "<C-H>", "<C-O>:promptrepl<CR>")
map("c", "<C-H>", "<C-C>:promptrepl<CR>")

-- F-key functionality
map("i", "<F2>", "<Esc>:cpf<CR>")
map("n", "<F2>", ":cpf<CR>")
map("i", "<F3>", "<Esc>:cnf<CR>")
map("n", "<F3>", ":cnf<CR>")
map("i", "<F4>", "<Esc>:tabmove -<CR>i")
map("n", "<F4>", ":tabmove -<CR>")
map("i", "<F5>", "<Esc>:tabmove +<CR>i")
map("n", "<F5>", ":tabmove +<CR>")
map("i", "<F6>", "<Esc>:set wrap!<CR>i")
map("n", "<F6>", ":set wrap!<CR>")

-- Window navigation
map("n", "<A-Up>", ":wincmd k<CR>")
map("n", "<A-Down>", ":wincmd j<CR>")
map("n", "<A-Left>", ":wincmd h<CR>")
map("n", "<A-Right>", ":wincmd l<CR>")

map("n", "<C-PageDown>", "<Cmd>BufferNext<CR>")
map("n", "<C-PageUp>", "<Cmd>BufferPrevious<CR>")
map("i", "<C-PageDown>", "<Cmd>BufferNext<CR>")
map("i", "<C-PageUp>", "<Cmd>BufferPrevious<CR>")

-- LSP configuration
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_set_current_dir("Z:\\home\\jorge\\mywaypro\\trade-engine-core")
