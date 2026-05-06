return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional, for file icons
	cmd = "NvimTreeToggle", -- Lazy load on command
	opts = {
		git = {
			timeout = 5000,
		},
		sort = {
			sorter = "case_sensitive",
		},
		view = {
			width = 60,
			side = "right",
		},
		renderer = {
			group_empty = true,
		},
		filters = {
			 dotfiles = true,
		},
		renderer = {
			highlight_git = true,
			highlight_opened_files = "all",
			highlight_modified = "all",
			icons = {
				git_placement = "after",
				modified_placement = "after",
				glyphs = {
					default = "",
					symlink = "",
					bookmark = "",
					git = {
						unstaged = "✗",
						staged = "✓",
						unmerged = "",
						renamed = "➜",
						deleted = "",
						untracked = "★",
						ignored = "◌",
					},
				},
			}
		},
		update_focused_file = {
            enable = true,
            update_root = {
                enable = false,
                ignore_list = {},
            },
        exclude = false,
      },
	},


	keys = {
		{
            "<leader>tt",
            function()
                vim.cmd([[NvimTreeToggle]])
            end,
        },
        {
            "<leader>tf",
            function()
                vim.cmd([[NvimTreeFocus]])
            end,
        },
	}
}
