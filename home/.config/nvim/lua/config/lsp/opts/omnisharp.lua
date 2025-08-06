---@brief
---
--- https://github.com/omnisharp/omnisharp-roslyn
--- OmniSharp server based on Roslyn workspaces
---
--- `omnisharp-roslyn` can be installed by downloading and extracting a release from [here](https://github.com/OmniSharp/omnisharp-roslyn/releases).
--- OmniSharp can also be built from source by following the instructions [here](https://github.com/omnisharp/omnisharp-roslyn#downloading-omnisharp).
---
--- OmniSharp requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.
---
--- **By default, omnisharp-roslyn doesn't have a `cmd` set.** This is because nvim-lspconfig does not make assumptions about your path. You must add the following to your init.vim or init.lua to set `cmd` to the absolute path ($HOME and ~ are not expanded) of the unzipped run script or binary.
---
--- For `go_to_definition` to work fully, extended `textDocument/definition` handler is needed, for example see [omnisharp-extended-lsp.nvim](https://github.com/Hoffs/omnisharp-extended-lsp.nvim)
---
---

vim.env.DOTNET_ROOT="/usr/local/share/dotnet"
local function override_keymap()
  local opts = function(desc)
    return { noremap = true, silent = true, buffer = true, desc = desc }
  end
  -- vim.keymap.set('n', 'gd', function() require('omnisharp_extended').lsp_definition() end, opts("OmniExtend Go To Definition"))
  -- vim.keymap.set('n', 'gr', function() require('omnisharp_extended').telescope_lsp_references() end, opts("OmniExtend Go To Reference"))
  vim.keymap.set('n', 'gD', function() require('omnisharp_extended').lsp_type_definition() end, opts("OmniExtend Go To Type"))
  -- vim.keymap.set('n', 'gi', function() require('omnisharp_extended').telescope_lsp_implementation() end,
  --   opts("OmniExtend Go To Implementation"))
end

local util = require 'lspconfig.util'

return {
  cmd = {
    'OmniSharp',
    '-z', -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
    '--hostPID',
    tostring(vim.fn.getpid()),
    'DotNet:enablePackageRestore=false',
    '--encoding',
    'utf-8',
    '--languageserver',
    'RoslynExtensionsOptions:enableDecompilationSupport=true',
    'RoslynExtensionsOptions:EnableAnalyzersSupport=true',
    'Sdk:IncludePrereleases=true',
    'FormattingOptions:OrganizeImports=true',
    'FormattingOptions:EnableEditorConfigSupport=true'
  },
  filetypes = { 'cs', 'vb' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(
      util.root_pattern '*.sln' (fname)
      or util.root_pattern '*.csproj' (fname)
      or util.root_pattern 'omnisharp.json' (fname)
      or util.root_pattern 'function.json' (fname)
    )
  end,
  init_options = {},
  capabilities = {
    workspace = {
      workspaceFolders = false, -- https://github.com/OmniSharp/omnisharp-roslyn/issues/909
    },
  },
  handlers = {
    ["textDocument/definition"] = require('omnisharp_extended').definition_handler,
    ["textDocument/typeDefinition"] = require('omnisharp_extended').type_definition_handler,
    ["textDocument/references"] = require('omnisharp_extended').references_handler,
    ["textDocument/implementation"] = require('omnisharp_extended').implementation_handler,
  },
  on_attach = function(client, bufnr)
    require('config.lsp.general-opts').general_client_opts.on_attach(client)
    override_keymap()
  end,
  settings = {
    FormattingOptions = {
      -- Enables support for reading code style, naming convention and analyzer
      -- settings from .editorconfig.
      EnableEditorConfigSupport = false,
      -- Specifies whether 'using' directives should be grouped and sorted during
      -- document formatting.
      OrganizeImports = nil,
    },
    MsBuild = {
      -- If true, MSBuild project system will only load projects for files that
      -- were opened in the editor. This setting is useful for big C# codebases
      -- and allows for faster initialization of code navigation features only
      -- for projects that are relevant to code that is being edited. With this
      -- setting enabled OmniSharp may load fewer projects and may thus display
      -- incomplete reference lists for symbols.
      LoadProjectsOnDemand = nil,
    },
    RoslynExtensionsOptions = {
      -- Enables support for roslyn analyzers, code fixes and rulesets.
      EnableAnalyzersSupport = true,
      -- Enables support for showing unimported types and unimported extension
      -- methods in completion lists. When committed, the appropriate using
      -- directive will be added at the top of the current file. This option can
      -- have a negative impact on initial completion responsiveness,
      -- particularly for the first few completion sessions after opening a
      -- solution.
      EnableImportCompletion = nil,
      -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
      -- true
      AnalyzeOpenDocumentsOnly = nil,
      -- Enables the possibility to see the code in external nuget dependencies
      EnableDecompilationSupport = true,
    },
    RenameOptions = {
      RenameInComments = nil,
      RenameOverloads = nil,
      RenameInStrings = nil,
    },
    Sdk = {
      -- Specifies whether to include preview versions of the .NET SDK when
      -- determining which version to use for project loading.
      IncludePrereleases = true,
    },
  },
}
