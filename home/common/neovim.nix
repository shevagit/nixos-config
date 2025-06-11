{ pkgs, ... }:{

    home.packages = with pkgs; [
        nodejs # Required for Copilot + some LSP tools
        nodePackages.bash-language-server
    ];

    home.file.".config/nvim/init.lua".text = ''
        require("options")

        -- Lazy.nvim bootstrap
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
            vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
            })
        end
        vim.opt.rtp:prepend(lazypath)
        require("lazy").setup("plugins")
    '';

    home.file.".config/nvim/lua/options.lua".text = ''
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.smartindent = true
        vim.opt.cursorline = true
        vim.opt.clipboard = "unnamedplus"
        vim.opt.mouse = "a"
        vim.opt.termguicolors = true
        vim.opt.wrap = false
        vim.opt.splitbelow = true
        vim.opt.splitright = true
    '';

    home.file.".config/nvim/lua/plugins.lua".text = ''
    return {
        { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

        {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
        },

        { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

        {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" }
        },

        "lewis6991/gitsigns.nvim",
        "neovim/nvim-lspconfig",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

        -- LSP setup
        "neovim/nvim-lspconfig",

        {
            "neovim/nvim-lspconfig",
            config = function()
            require("lsp") -- this line moves from init.lua into here
            end,
        },

        -- Completion plugins
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",

        -- Optional UI
        "onsails/lspkind-nvim",         -- Adds icons to completion
        "folke/neodev.nvim",            -- Lua dev support for plugins

        -- GitHub Copilot
        {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            event = "InsertEnter",
            config = function()
            require("copilot").setup({
                suggestion = { enabled = true },
                panel = { enabled = false },
            })
            end,
        },
        {
            "zbirenbaum/copilot-cmp",
            dependencies = { "zbirenbaum/copilot.lua" },
            config = function()
            require("copilot_cmp").setup()
            end,
        },
    }
    '';

    home.file.".config/nvim/lua/lsp.lua".text = ''
        -- ~/.config/nvim/lua/lsp.lua
        local lspconfig = require("lspconfig")

        -- Enable gopls (Go)
        lspconfig.gopls.setup({})

        -- Enable bash-language-server
        lspconfig.bashls.setup({})

        -- Completion setup
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        require("copilot").setup({})
        require("copilot_cmp").setup({})

        cmp.setup({
        snippet = {
            expand = function(args)
            luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "copilot" },
            { name = "luasnip" },
        }),
        })
    '';
}