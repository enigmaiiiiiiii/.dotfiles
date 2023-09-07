local luasnip = require("luasnip")
local types = require("luasnip.util.types")

luasnip.setup({
	history = true,
	updatevents = "TextChanged,TextChangedI",
	delete_check_events = "TextChanged",
	ext_opts = { [types.choiceNode] = { active = { virt_text = { { "choiceNode", "Comment" } } } } },
  ft_func = function()
    return vim.split(vim.bo.filetype, ".", true)
  end,
})
