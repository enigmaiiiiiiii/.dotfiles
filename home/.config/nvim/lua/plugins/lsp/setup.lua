local servers = require("plugins.lsp.servers")

local keymap_opts = function(desc)
  if desc then
    return { noremap = true, silent = true, desc = desc }
  end
  return { noremap = true, silent = true }
end
local goto_opts = {
  border = "rounded",
  severity = {
    min = vim.diagnostic.severity.WARN,
  }
}

vim.g.diagnostic_virtual_text_enabled = true
function _G.toggle_diagnostic_virtual_text()
  vim.g.diagnostic_virtual_text_enabled = not vim.g.diagnostic_virtual_text_enabled
  vim.diagnostic.config({
    virtual_text = vim.g.diagnostic_virtual_text_enabled,
  })
end

local function goto_definition_in_split()
  local function is_normal_window(win)
    local available = false
    local config = vim.api.nvim_win_get_config(win)
    if not config.relative or config.relative == "" then
      available = true
    end
    return available
  end

  local wins = vim.api.nvim_tabpage_list_wins(0)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win_id = vim.api.nvim_get_current_win()
  local split_win_id = nil

  -- search for opened normal split window
  for _, win_id in pairs(wins) do
    if win_id ~= current_win_id and is_normal_window(win_id) then
      split_win_id = win_id
      break
    end
  end

  if split_win_id then
    vim.api.nvim_set_current_win(split_win_id)
    vim.api.nvim_win_set_buf(split_win_id, current_buf)
    vim.api.nvim_win_set_cursor(split_win_id, cursor_pos)
  else
    vim.api.nvim_open_win(0, true, { split = 'right', win = 0, })
  end

  vim.lsp.buf.definition()
end

local function default_keymaps()
  vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end,
    keymap_opts("Go To Definition"))
  vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references({ include_declaration = false }) end,
    keymap_opts("Go To Reference"))

  vim.keymap.set('n', 'gh', function() vim.lsp.buf.hover() end, keymap_opts("Hover"))
  vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end, keymap_opts("Declaration"))
  vim.keymap.set('n', 'gv', goto_definition_in_split, keymap_opts("Goto definition in split"))
  -- vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end, opts)
  -- vim.keymap.set('n', '<leader>k', function() vim.lsp.buf.signature_help() end, opts)
  -- vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set('n', 'gp', function() vim.diagnostic.goto_prev(goto_opts) end, keymap_opts())
  vim.keymap.set('n', 'gn', function() vim.diagnostic.goto_next(goto_opts) end, keymap_opts())
  vim.keymap.set('n', 'gl', function() vim.diagnostic.open_float() end, keymap_opts())
  vim.keymap.set('n', '<leader>d', function() toggle_diagnostic_virtual_text() end,
    { noremap = true, silent = true, desc = "Toggle disgnostic virtual text" })
  vim.keymap.set('n', '<leader>q', function() vim.diagnostic.setloclist() end, keymap_opts())
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

local function lsp_highlight_document(client)
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlight then
    local group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      buffer = 0,
      callback = function()
        vim.lsp.buf.document_hightlight()
      end
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = 0,
      callback = function()
        vim.lsp.buf.clear_references()
      end
    })
  end
end

---@diagnostic disable-next-line: unused-local
local lsp_overloads_opts = {
  -- UI options are mostly the same as those passed to vim.lsp.util.open_floating_preview
  ui = {
    border = "single", -- The border to use for the signature popup window. Accepts same border values as |nvim_open_win()|.
    height = nil,      -- Height of the signature popup window (nil allows dynamic sizing based on content of the help)
    width = nil,       -- Width of the signature popup window (nil allows dynamic sizing based on content of the help)
    wrap = true,       -- Wrap long lines
    wrap_at = nil,     -- Character to wrap at for computing height when wrap enabled
    max_width = nil,   -- Maximum signature popup width
    max_height = nil,  -- Maximum signature popup height
    -- Events that will close the signature popup window: use {"CursorMoved", "CursorMovedI", "InsertCharPre"} to hide the window when typing
    close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
    focusable = true,                       -- Make the popup float focusable
    focus = false,                          -- If focusable is also true, and this is set to true, navigating through overloads will focus into the popup window (probably not what you want)
    offset_x = 0,                           -- Horizontal offset of the floating window relative to the cursor position
    offset_y = 0,                           -- Vertical offset of the floating window relative to the cursor position
    floating_window_above_cur_line = false, -- Attempt to float the popup above the cursor position
    -- (note, if the height of the float would be greater than the space left above the cursor, it will default
    -- to placing the float below the cursor. The max_height option allows for finer tuning of this)
    silent = true, -- Prevents noisy notifications (make false to help debug why signature isn't working)
    -- Highlight options is null by default, but this just shows an example of how it can be used to modify the LspSignatureActiveParameter highlight property
    highlight = {
      italic = true,
      bold = true,
      fg = "#ffffff",
      ... -- Other options accepted by the `val` parameter of vim.api.nvim_set_hl()
    }
  },
  keymaps = {
    next_signature = "<C-j>",
    previous_signature = "<C-k>",
    next_parameter = "<C-l>",
    previous_parameter = "<C-h>",
    close_signature = "<A-s>"
  },
  display_automatically = true -- Uses trigger characters to automatically display the signature overloads when typing a method signature
}

local function base_attach(client)
  default_keymaps()
  lsp_highlight_document(client)
  if (client.server_capabilities.signatureHelpProvider) then
    require("lsp-overloads").setup(client, {})
  end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.workspace = {
  didChangeWatchedFiles = {
    dynamicRegistration = true,
  }
}

for _, server_name in pairs(servers) do
  server_name = vim.split(server_name, "@")[1]
  local lsp_opts = {
    on_attach = base_attach,
    capabilities = capabilities,
  }

  local require_ok, server_opts = pcall(require, "plugins.lsp.settings." .. server_name)

  if (require_ok) then
    if (server_opts.on_attach) then
      local extra_attach = server_opts.on_attach
      server_opts.on_attach = function(client)
        base_attach(client)
        extra_attach(client)
      end
    end
    lsp_opts = vim.tbl_deep_extend("force", lsp_opts, server_opts)
  end
  require("lspconfig")[server_name].setup(lsp_opts)
end