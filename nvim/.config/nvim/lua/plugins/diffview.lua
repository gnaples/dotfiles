-- Side-by-side git diff view, closest neovim analog to IntelliJ's diff viewer.
-- https://github.com/sindrets/diffview.nvim
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View (working tree)" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (all files)" },
      { "<leader>ghh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        -- Side-by-side (2-way) diff by default, like IntelliJ's diff viewer.
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal" },
      },
    },
  },
}
