local hop_status_ok, hop = pcall(require, "hop")

if not hop_status_ok then
	return
end

hop.setup({})

-- place this in one of your configuration file(s)
local directions = require("hop.hint").HintDirection

-- replace original f, F
-- vim.keymap.set("", "f", function()
-- 	hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
-- end, { remap = true })
--
-- vim.keymap.set("", "F", function()
-- 	hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
-- end, { remap = true })

-- replace original s, S
vim.keymap.set("", "s", function()
	hop.hint_char2({ direction = directions.AFTER_CURSOR })
end, { remap = true })

vim.keymap.set("", "S", function()
	hop.hint_char2({ direction = directions.BEFORE_CURSOR })
end, { remap = true })
