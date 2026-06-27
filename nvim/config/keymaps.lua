-- ############################## GENERAL ##############################

local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.keymap.set

-- space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- ############################## NORMAL ##############################

-- Better window navigation
keymap("n", "<S-h>", "<C-w>h", opts)
keymap("n", "<S-j>", "<C-w>j", opts)
keymap("n", "<S-k>", "<C-w>k", opts)
keymap("n", "<S-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", "<cmd>resize +2<CR>", opts)
keymap("n", "<C-Down>", "<cmd>resize -2<CR>", opts)
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)
keymap("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts)

-- Navigate buffers
keymap("n", "<C-l>", "<cmd>bnext<CR>", opts)
keymap("n", "<C-h>", "<cmd>bprevious<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", "<cmd>m .+1<CR>==", opts)
keymap("n", "<A-k>", "<cmd>m .-2<CR>==", opts)

-- Easier save, quit
keymap("n", "<leader>w", "<cmd>w<CR>", opts)
keymap("n", "<leader>q", "<cmd>q<CR>", opts)

-- Pressing esc clears search highlighting
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- Toggle show invisible characters
keymap("n", "<leader>tl", "<cmd>set list!<CR>", opts)

-- ############################## INSERT ##############################


-- ############################## VISUAL ##############################

-- Stay in indent mode (re-select last selected text and move to 1st non-blank char)
keymap("v", "<", "<gv^", opts)
keymap("v", ">", ">gv^", opts)

-- Move text up and down
keymap("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv", opts)

-- Preserve yank register when pasting over selection
-- Does NOT copy the recently replaced text into the register (keeps the originally yanked text in register)
-- "_d: This deletes the selected text and stores it in the black hole register ("_), meaning it will not affect the default or unnamed registers.
-- P: This pastes the previously yanked or deleted text (the last text that was copied) before the cursor position, effectively replacing the selected text with the new paste. 
-- This combination allows you to paste new content without losing the original selection, as it doesn't store the deleted text in the usual registers.
keymap("v", "p", '"_dP', opts)

