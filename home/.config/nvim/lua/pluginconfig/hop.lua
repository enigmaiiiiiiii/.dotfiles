local hop = require("hop")

hop.setup({})

vim.keymap.set("n", "s", function()
	hop.hint_char2()
end, { remap = true })

