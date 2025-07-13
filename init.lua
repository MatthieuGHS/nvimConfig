-- config

vim.g.mapleader = " "
vim.opt.number = true        -- Affiche le numéro de ligne actuel
vim.opt.relativenumber = true -- Affiche les numéros relatifs pour les autres lignes
vim.opt.cursorline = true
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.directory = '/tmp'  -- déplacer les swapfiles dans /tmp


vim.cmd('autocmd BufRead,BufNewFile *.hbs set filetype=html') -- Parse les .hbs comme des .html

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)


-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
        {
         'nvim-telescope/telescope.nvim', tag = '0.1.8',
         dependencies = { 'nvim-lua/plenary.nvim' }
        },
	{
	    "nvim-telescope/telescope-ui-select.nvim",
	    config = function()
		    require("telescope").setup({
			    extensions = {
				["ui-select"] = {
				    require("telescope.themes").get_dropdown {
					-- even more opts
				    }
				}
			    }
		    })
		    require("telescope").load_extension("ui-select")
	    end,
	},
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
	    
            config = function () 
            local configs = require("nvim-treesitter.configs")

            configs.setup({
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "java", "python", "css" },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },  
            })
            end
        },

        {
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
            },
            lazy = false, -- neo-tree will lazily load itself
            ---@module "neo-tree"
            ---@type neotree.Config?
            opts = {
                -- fill any relevant options here
            },
         },
         {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" }, -- pour les icônes
            config = function()
                require("lualine").setup({
                    options = {
                        theme = "catppuccin",
                        section_separators = "",
                        component_separators = "",
                    },
                })
            end,
        },
	{
	    "sphamba/smear-cursor.nvim",
	    opts = {},
	},
	{
	     "karb94/neoscroll.nvim",
	      opts = {},
	},
	-- LSP
	{
	  "mason-org/mason.nvim",
	  config = function()
	    require("mason").setup()
	  end,
	},
	{
          "williamboman/mason-lspconfig.nvim",
	  config = function()
	    require("mason-lspconfig").setup({
	      ensure_installed = { "lua_ls", "pyright", "ts_ls", "html" },
	    })
    	end,
	},
	{
	    "neovim/nvim-lspconfig",
	    config = function()
		local lspconfig = require("lspconfig")
		local capabilities = require('cmp_nvim_lsp').default_capabilities()

		lspconfig.ts_ls.setup({
		    capabilities = capabilities
		})
		lspconfig.lua_ls.setup({
		    capabilities = capabilities
		})

		lspconfig.html.setup({
		    capabilities = capabilities
		})

		vim.keymap.set("n", "K", vim.lsp.buf.hover, {}) 
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {}) 
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {}) 

	    end,
	},
	{
	    "hrsh7th/cmp-nvim-lsp"
	},
	{
	    "L3MON4D3/LuaSnip",
	    dependencies = {
		"hrsh7th/nvim-cmp",
		"rafamadriz/friendly-snippets"
	    }
	},
	{
	    "hrsh7th/nvim-cmp",
	    config = function()
		local cmp = require'cmp'
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
		    snippet = {
			-- REQUIRED - you must specify a snippet engine
			expand = function(args)
			    --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			    require('luasnip').lsp_expand(args.body)
			end,
		    },
		    window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		    },
		    mapping = cmp.mapping.preset.insert({
			['<C-b>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete(),
			['<C-e>'] = cmp.mapping.abort(),
			['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		    }),
		    sources = cmp.config.sources({
			{ name = 'nvim_lsp' },
			--{ name = 'vsnip' }, -- For vsnip users.
			{ name = 'luasnip' }, -- For luasnip users.
			-- { name = 'ultisnips' }, -- For ultisnips users.
			-- { name = 'snippy' }, -- For snippy users.
		    }, {
			    { name = 'buffer' },
			})
		})

	    end,
	},
	{
	    "echasnovski/mini.hipatterns",
	    event = "BufReadPre",
	    opts = {},
	},
	{
	    "steelsojka/pears.nvim",
	    config = function()
		require('pears').setup()
	    end
	},

	{'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'}
    },
    
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

local builtin = require('telescope.builtin')

require("neo-tree").setup({
  window = {
    width = 20, 
  }
})


require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

require("bufferline").setup({
    options = {
        diagnostics = "nvim_lsp",
        offsets = {
            {
                filetype = "neo-tree",
                text = "File Explorer",
                highlight = "Directory",
                separator = true
            }
        }
    }
})


-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"
vim.opt.background = "dark"

-- BLACK bg
vim.cmd [[hi Normal guibg=#000000 ctermbg=black]]
vim.cmd [[hi NormalNC guibg=#000000 ctermbg=black]]


-- Bindings
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>e', ':Neotree filesystem reveal left<CR>', {})
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>', {})
vim.keymap.set('n', '<leader>to', ':tabnew %<CR>', {})
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', {})
vim.keymap.set('n', '<leader>tl', ':tabnext<CR>', {})
vim.keymap.set('n', '<leader>th', ':tabprevious<CR>', {})
vim.keymap.set('n', '<C-x>', ':botright 5split | terminal<CR>', {})
vim.keymap.set('n', '<C-:>', ':nohlsearch<CR>', {})

vim.keymap.set('n', "<leader>n", ':bn<CR>', {})
vim.keymap.set('n', "<leader>p", ':bp<CR>', {})
vim.keymap.set('n', "<leader>c", ':bd<CR>', {})



