return {
  "mrjones2014/smart-splits.nvim",
  build = "./kitty/install-kittens.bash",
  opts = {
    at_edge = "stop",
  },
  -- only enabled outside of tmux
  -- enabled = (os.getenv("TMUX")) == nil,
}
