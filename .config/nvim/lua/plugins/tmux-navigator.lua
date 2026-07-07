-- Seamless <ctrl>+hjkl navigation between Neovim splits and tmux panes.
-- The tmux side lives in ~/.config/tmux/tmux.conf (@plugin christoomey/vim-tmux-navigator);
-- this is the Neovim half - without it, ctrl+hjkl only moves between tmux panes, not nvim splits.
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
  },
}
