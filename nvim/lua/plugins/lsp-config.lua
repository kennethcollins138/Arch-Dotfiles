return {
    -- Mason: installs and manages LSP servers
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    -- Mason LSPconfig: bridges Mason and nvim-lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "clangd", -- C/C++
                    "cmake", -- CMake
                    "cssls", -- CSS
                    "dockerls", -- Dockerfile
                    "eslint", -- ESLint LSP
                    "gopls", -- Go
                    "html", -- HTML
                    "lua_ls", -- Lua
                    "pyright", -- Python
                    "ts_ls", -- TypeScript/JavaScript
                },
            })
        end,
    },
    -- nvim-cmp: the autocompletion engine
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<TAB>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },
    -- cmp-nvim-lsp: bridges nvim-cmp with nvim-lspconfig for better autocomplete
    {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = { "hrsh7th/nvim-cmp" },
    },
    -- nvim-lspconfig: sets up LSP servers with autocomplete support
    {
        "neovim/nvim-lspconfig",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local lspconfig = require("lspconfig")
            local mason_lspconfig = require("mason-lspconfig")

            -- Common on_attach for all LSP servers
            local on_attach = function(client, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            end

            -- Enhance capabilities using cmp-nvim-lsp
            local capabilities = vim.tbl_deep_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                require("cmp_nvim_lsp").default_capabilities()
            )

            -- Automatically set up all installed servers using Mason's handlers
            mason_lspconfig.setup_handlers({
                function(server_name)
                    lspconfig[server_name].setup({
                        on_attach = on_attach,
                        capabilities = capabilities,
                    })
                end,
                -- You can override settings for specific servers here:
                -- ["lua_ls"] = function()
                --   lspconfig.lua_ls.setup({
                --     on_attach = on_attach,
                --     capabilities = capabilities,
                --     settings = {
                --       Lua = { diagnostics = { globals = { "vim" } } },
                --     },
                --   })
                -- end,
            })
        end,
    },
    {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua",
        },
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", 'gomod' },
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function()
            local null_ls = require("null-ls")
            return {
                sources = {
                    -- Use Prettier for JS, TS, CSS, HTML, Markdown, etc.
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = { "javascript", "typescript", "css", "html", "json", "markdown" },
                    }),
                    -- You can also add other formatters like Black for Python, etc.
                    null_ls.builtins.formatting.black,
                },
                on_attach = function(client, bufnr)
                    if client.server_capabilities.documentFormattingProvider then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ async = false })
                            end,
                        })
                    end
                end,
            }
        end,
    },

}
