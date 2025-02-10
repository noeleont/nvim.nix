-- Function to get parent directory
local function get_parent_directory(path)
  return vim.fn.fnamemodify(path, ':h')
end

-- Function to get git root directory
local function get_git_root()
  local git_dir = vim.fn.FugitiveGitDir()
  if git_dir then
    -- Remove the '.git' from the end to get the root
    return get_parent_directory(git_dir)
  end
  return vim.fn.getcwd() -- Fallback to current directory if not in git repo
end

-- Function to check if directory is valid for a vault
local function is_valid_vault_directory(dir)
  -- Add your own validation criteria here
  -- For example, check if certain folders or files exist
  local notes_dir = dir .. '/notes'
  return vim.fn.isdirectory(notes_dir) == 1
end

-- Function to setup telekasten with dynamic vault
local function setup_telekasten()
  local current_dir = get_git_root()

  -- Validate the directory
  if not is_valid_vault_directory(current_dir) then
    current_dir = get_parent_directory(current_dir)
  end

  -- Check the parent directory
  if not is_valid_vault_directory(current_dir) then
    current_dir = "~"
  end

  -- Configure telekasten with the current directory
  require('telekasten').setup({
    home = current_dir .. '/notes',
  })
end


-- Launch panel if nothing is typed after <leader>z
vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")

-- Most used functions
vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>")
vim.keymap.set("n", "<leader>zv", "<cmd>Telekasten switch_vault<CR>")

-- Call insert link automatically when we start typing a link
vim.keymap.set("i", "[[", "<cmd>Telekasten insert_link<CR>")

-- Create an autocommand to update telekasten when directory changes
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    setup_telekasten()
  end,
})

setup_telekasten()
