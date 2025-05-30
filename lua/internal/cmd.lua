local cmd = vim.api.nvim_create_user_command

cmd("CodeRun", function(tbl)
  require("utility.run").code_run(tbl.args)
end, {
  nargs = "?",
  complete = function()
    local option_table = {
      c = { "build", "check" },
      cs = { "build", "clean", "test" },
      fsharp = { "build", "clean", "test" },
      lisp = { "build" },
      lua = { "lua", "jit" },
      rust = { "build", "check", "clean", "test" },
      tex = { "biber", "bibtex" },
    }
    if option_table[vim.bo.filetype] then
      return option_table[vim.bo.filetype]
    else
      return {}
    end
  end,
  desc = "Run or compile the code"
})

cmd("BuildCrates", function(tbl)
  local rsmod = require("utility.rsmod")
  local crates = rsmod.find_crates()
  local args = tbl.args
  if args:len() == 0 then
    rsmod.build_crates(crates)
  elseif crates[args] then
    rsmod.build_crates({ [args] = crates[args] })
  else
    vim.notify("Crate not found")
  end
end, {
  nargs = "?",
  complete = function()
    local crates = require("utility.rsmod").find_crates()
    return vim.tbl_keys(crates)
  end,
  desc = "Build crates in this configuration"
})

cmd("CreateProject", function(_)
  require("utility.template"):create_project()
end, { desc = "Create project with templates" })

cmd("GlslViewer", function(tbl)
  require("utility.glsl").start(0, tbl.fargs)
end, { nargs = "*", desc = "Start glslViewer", complete = "file" })

cmd("NvimUpgrade", function(tbl)
  if not _G._my_core_opt.general.upgrade then
    vim.notify("NvimUpgrade is disabled", vim.log.levels.WARN)
    return
  end
  require("utility.upgrade").nvim_upgrade(tbl.args)
end, {
  nargs = "?",
  complete = function() return { "stable", "nightly" } end,
  desc = "Upgrade Neovim by channel"
})

cmd("PushAll", function(tbl)
  local arg_tbl = require("utility.lib").parse_args(tbl.args)
  require("logit").push_all(arg_tbl)
end, { nargs = "?", desc = "Just push everything to the remote" })

cmd("Time", function(_)
  vim.notify(vim.fn.strftime("%Y-%m-%d %a %T"))
end, { desc = "Print current time (May be useful in full screen?)" })
