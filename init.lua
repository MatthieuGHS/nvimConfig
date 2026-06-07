-- ============================================================================
-- Neovim — Python data-science setup (NeuralForecast, hackathon HAKS)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Options
-- ---------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.scrolloff = 8

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.directory = "/tmp"
vim.opt.undofile = true
vim.opt.swapfile = false

-- Python provider (utilise anaconda, fallback /usr/bin)
vim.g.python3_host_prog = vim.fn.exepath("python3")

-- ---------------------------------------------------------------------------
-- Bootstrap lazy.nvim
-- ---------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
        }, true, {})
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- ---------------------------------------------------------------------------
-- Plugins
-- ---------------------------------------------------------------------------
require("lazy").setup({
    spec = {
        -- Theme & visuals
        { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
        { "sphamba/smear-cursor.nvim", opts = {} },
        { "karb94/neoscroll.nvim", opts = {} },
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
        },
        {
            "akinsho/bufferline.nvim",
            version = "*",
            dependencies = { "nvim-tree/nvim-web-devicons" },
        },
        { "lewis6991/gitsigns.nvim", opts = {} },

        -- File navigation
        {
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons",
                "MunifTanjim/nui.nvim",
            },
        },
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = { "nvim-lua/plenary.nvim" },
        },
        { "nvim-telescope/telescope-ui-select.nvim" },

        -- Discoverability
        { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

        -- Treesitter
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
        },

        -- LSP
        { "mason-org/mason.nvim", opts = {} },
        { "mason-org/mason-lspconfig.nvim" },
        { "neovim/nvim-lspconfig" },

        -- Completion
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "saadparwaiz1/cmp_luasnip",
                {
                    "L3MON4D3/LuaSnip",
                    dependencies = { "rafamadriz/friendly-snippets" },
                },
            },
        },

        -- Formatting
        { "stevearc/conform.nvim" },

        -- Editing helpers
        { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

        -- Python data-science
        {
            "linux-cultist/venv-selector.nvim",
            cmd = "VenvSelect", -- ne charge qu'à la première utilisation (besoin de `fd`)
            dependencies = {
                "neovim/nvim-lspconfig",
                "nvim-telescope/telescope.nvim",
            },
            opts = {
                settings = { options = { notify_user_on_venv_activation = true } },
            },
        },
        {
            "benlubas/molten-nvim",
            build = ":UpdateRemotePlugins",
            init = function()
                vim.g.molten_output_win_max_height = 20
                vim.g.molten_auto_open_output = false
                vim.g.molten_virt_text_output = true
                vim.g.molten_virt_lines_off_by_1 = true
                vim.g.molten_wrap_output = true
            end,
        },
    },
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true, notify = false },
    change_detection = { notify = false },
})

-- ---------------------------------------------------------------------------
-- Catppuccin (avec fond noir)
-- ---------------------------------------------------------------------------
require("catppuccin").setup({
    flavour = "mocha",
    background = { light = "latte", dark = "mocha" },
    transparent_background = false,
    show_end_of_buffer = false,
    styles = {
        comments = { "italic" },
        conditionals = { "italic" },
    },
    integrations = {
        cmp = true,
        gitsigns = true,
        neotree = true,
        treesitter = true,
        which_key = true,
        mason = true,
        telescope = { enabled = true },
        native_lsp = {
            enabled = true,
            virtual_text = { errors = { "italic" }, hints = { "italic" } },
        },
    },
})
vim.cmd.colorscheme("catppuccin")
vim.opt.background = "dark"

-- Fond noir (override catppuccin)
vim.cmd([[hi Normal guibg=#000000 ctermbg=black]])
vim.cmd([[hi NormalNC guibg=#000000 ctermbg=black]])

-- ---------------------------------------------------------------------------
-- Treesitter (Python + essentials)
-- ---------------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "python", "lua", "vim", "vimdoc", "query",
        "markdown", "markdown_inline",
        "json", "yaml", "toml", "bash",
    },
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = true },
})

-- ---------------------------------------------------------------------------
-- Telescope
-- ---------------------------------------------------------------------------
require("telescope").setup({
    defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
    },
    extensions = {
        ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
    },
})
require("telescope").load_extension("ui-select")

-- ---------------------------------------------------------------------------
-- Neo-tree (file explorer)
-- ---------------------------------------------------------------------------
require("neo-tree").setup({
    window = {
        width = 28,
        mappings = {
            ["a"] = { "add", config = { show_path = "relative" } },
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["c"] = "copy",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["H"] = "toggle_hidden",
        },
    },
    filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },
})

-- ---------------------------------------------------------------------------
-- Bufferline (onglets de buffers en haut, façon VSCode)
-- ---------------------------------------------------------------------------
require("bufferline").setup({
    options = {
        diagnostics = "nvim_lsp",
        offsets = {
            { filetype = "neo-tree", text = "Files", highlight = "Directory", separator = true },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
    },
})

-- ---------------------------------------------------------------------------
-- Lualine
-- ---------------------------------------------------------------------------
require("lualine").setup({
    options = {
        theme = "auto", -- résout automatiquement vers catppuccin-mocha
        section_separators = "",
        component_separators = "",
        globalstatus = true,
    },
    sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "encoding", "filetype" },
    },
})

-- ---------------------------------------------------------------------------
-- LSP — nouvelle API Neovim 0.11+ (plus de deprecation)
-- ---------------------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright", "ruff" },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Capabilities globales pour tous les serveurs
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            },
        },
    },
})

-- ruff: laisse la config par défaut, ajouter init_options.settings si besoin

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

-- Active les serveurs (mason-lspconfig le fait déjà, mais explicite > implicite)
vim.lsp.enable({ "pyright", "ruff", "lua_ls" })

-- Désactive le hover de ruff (laisse pyright le gérer, pas de doublon)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end,
})

-- Keymaps LSP (déclenchés à l'attach)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover doc" }))
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Definition" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Implementation" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
    end,
})

vim.diagnostic.config({
    virtual_text = { prefix = "●" },
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
})

-- ---------------------------------------------------------------------------
-- Completion (nvim-cmp)
-- ---------------------------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }, {
        { name = "buffer" },
        { name = "path" },
    }),
})

-- Autopairs + cmp
local autopairs_cmp = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", autopairs_cmp.on_confirm_done())

-- ---------------------------------------------------------------------------
-- Conform (formatter — format on save)
-- ---------------------------------------------------------------------------
require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        lua = { "stylua" },
    },
    format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
    },
})

-- ---------------------------------------------------------------------------
-- Filetypes
-- ---------------------------------------------------------------------------
vim.filetype.add({ extension = { hbs = "html" } })

-- ---------------------------------------------------------------------------
-- Keymaps
-- ---------------------------------------------------------------------------
local map = vim.keymap.set
local builtin = require("telescope.builtin")

-- Groupes which-key
require("which-key").add({
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>l", group = "lsp / format" },
    { "<leader>t", group = "tabs" },
    { "<leader>m", group = "molten (cells)" },
    { "<leader>v", group = "venv" },
    { "<leader>b", group = "buffers" },
})

-- Find / Telescope (style VSCode Ctrl+P / Ctrl+Shift+F)
map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Grep" })
map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>fr", builtin.resume, { desc = "Resume last search" })
map("n", "<C-p>", builtin.find_files, { desc = "Find files" })

-- File explorer (VSCode-like Ctrl+B)
map("n", "<leader>e", ":Neotree filesystem reveal left toggle<CR>", { desc = "Explorer" })
map("n", "<C-b>", ":Neotree filesystem reveal left toggle<CR>", { desc = "Explorer toggle" })

-- Buffers
map("n", "<leader>n", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>p", ":bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>c", ":bdelete<CR>", { desc = "Close buffer" })
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>bn", function()
    vim.ui.input({ prompt = "Nouveau fichier: " }, function(name)
        if name and name ~= "" then vim.cmd("edit " .. name) end
    end)
end, { desc = "New file (path)" })

-- Tabs (gardés)
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>to", ":tabnew %<CR>", { desc = "Tab here" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tl", ":tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>th", ":tabprevious<CR>", { desc = "Prev tab" })

-- Terminal
map("n", "<C-x>", ":botright 12split | terminal<CR>", { desc = "Terminal split" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Term → Normal" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Save / quit / search
map("n", "<leader>w", ":w<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search" })

-- Format manuel
map({ "n", "v" }, "<leader>lf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })

-- Venv
map("n", "<leader>vs", ":VenvSelect<CR>", { desc = "Select venv" })

-- Molten (cellules Jupyter-like — utilise `# %%` pour découper)
map("n", "<leader>mi", ":MoltenInit<CR>", { desc = "Init kernel" })
map("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { desc = "Eval line" })
map("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Eval visual" })
map("n", "<leader>mc", ":MoltenReevaluateCell<CR>", { desc = "Re-eval cell" })
map("n", "<leader>mo", ":noautocmd MoltenEnterOutput<CR>", { desc = "Open output" })
map("n", "<leader>mh", ":MoltenHideOutput<CR>", { desc = "Hide output" })
map("n", "<leader>md", ":MoltenDelete<CR>", { desc = "Delete cell" })

-- Indentation visuelle (garde la sélection après >/<)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Déplacer une ligne (Alt+j / Alt+k façon VSCode)
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
