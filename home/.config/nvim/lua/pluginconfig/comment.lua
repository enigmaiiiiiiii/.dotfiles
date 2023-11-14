require('Comment').setup({
  ignore = '^$',
  mappings = {
    basic = true,
    extra = true,
    extended = true,
  },
  toggler = {
    line = 'gcc',
    block = 'gbc',
  },
  opleader = {
    line = 'gc',
    block = 'gb',
  },
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  post_hook = nil,
})
