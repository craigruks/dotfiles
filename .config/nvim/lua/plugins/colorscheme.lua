-- Carry over the catppuccin theme from the previous (NvChad) setup.
-- Adds the plugin and tells LazyVim to use it as the default colorscheme.
return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
