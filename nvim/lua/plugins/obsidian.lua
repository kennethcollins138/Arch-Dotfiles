return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/my-vault/*.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/my-vault/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/mindmap/personal",
      },
      {
        name = "work",
        path = "~/mindmap/work",
      },
    },
  },
}
