local options = {
  backup = false,                          -- Don't create backup files
  swapfile = false,                        -- Don't create swap files
  writebackup = false,                     -- Disable temporary write backups (e.g.: when another program is writing to the same file)
  termguicolors = true,                    -- Enable 24-bit colors (most terminals support this)
  clipboard = "unnamedplus",               -- Use the system clipboard
  ignorecase = true,                       -- Ignore case in search
  smartcase = true,                        -- Uppercase letters make searches case-sensitive
  smartindent = true,                      -- Automatic indentation
  splitbelow = true,                       -- Horizontal splits open below
  splitright = true,                       -- Vertical splits open below.
  expandtab = true,                        -- Convert tabs to spaces
  shiftwidth = 2,                          -- Indentation width
  tabstop = 2,                             -- Tab display width
  number = true,                           -- Set numbered lines
  undofile = true,                         -- Enable persistent undo
  signcolumn = "yes",                      -- Always show the sign column, otherwise it would shift the text each time
  textwidth = 120,                         -- Text width
  wrap = false,                            -- don't visually wrap lines
  virtualedit = "all"                      -- whitespace navigation
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.opt.iskeyword:append("-")     	   -- Hyphenated words recognized by searches

-- Set listchars to customize whitespace visualization
-- Use `:set list!` to toggle
vim.opt.listchars = {
  tab = '▸▸',  				   -- Representation for tab characters
  trail = '·', 				   -- Representation for trailing spaces
  space = '·', 				   -- Representation for spaces
  eol = '↵',   				   -- Representation for end-of-line
}

