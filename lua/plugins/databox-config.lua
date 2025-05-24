return {
  "chrisgve/databox.nvim",
  config = function()
    local databox_module = require("databox")

    local success, err = databox_module.setup({
      private_key = "~/.secret/nvim.txt",
      public_key = "age13nh09fsyzuxp6utcupqle9c66ylacqwckzqum3672ax27rr4sejs2dyk06",
      encryption_cmd = "rage -e -a -r %s",
      decryption_cmd = "rage -d -i %s",
    })

    if not success then
      vim.notify("Databox setup failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
    end
  end,
}
