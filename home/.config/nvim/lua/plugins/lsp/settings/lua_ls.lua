local M = {}

M.setup_condition = true
M.setup_options = {
	settings = {

		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
        checkThirdParty = false,
			},
		},
	},
}

return M
