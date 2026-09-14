-- JetBrains IDE-inspired colorscheme (Darcula-style dark theme), for anyone
-- whose eyes are calibrated to IntelliJ/WebStorm/GoLand/PyCharm.
-- https://github.com/nickkadutskyi/jb.nvim
return {
  {
    "nickkadutskyi/jb.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = "dark"
    end,
  },

  -- Configure LazyVim to load jb.nvim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "jb",
    },
  },
}
