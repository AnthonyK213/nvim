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
  desc = "Run or compile"
})

cmd("BuildDylibs", function(tbl)
  local crates = require("utility.crates")
  local crate_list = crates.find_crates()
  local args = tbl.args
  if args:len() == 0 then
    crates.build_crates(crate_list)
  elseif crate_list[args] then
    crates.build_crates({ [args] = crate_list[args] })
  else
    vim.notify("Crate not found")
  end
end, {
  nargs = "?",
  complete = function()
    local crate_list = require("utility.crates").find_crates()
    return vim.tbl_keys(crate_list)
  end,
  desc = "Build crates in this configuration"
})

cmd("CreateProject", function(tbl)
  require("utility.template"):create_project(tbl.args)
end, {
  nargs = "?",
  complete = function()
    local template = require("utility.template")
    template:init()
    return vim.tbl_keys(template.templates)
  end
  ,
  desc = "Create project"
})

cmd("GlslViewer", function(tbl)
  require("utility.glsl").start(0, tbl.fargs)
end, { nargs = "*", desc = "Start glslViewer", complete = "file" })

cmd("NvimUpgrade", function(tbl)
  require("utility.upgrade").nvim_upgrade(tbl.args)
end, {
  nargs = "?",
  complete = function() return { "stable", "nightly" } end,
  desc = "Neovim upgrade"
})

cmd("PushAll", function(tbl)
  local arg_tbl = require("utility.lib").parse_args(tbl.args)
  require("logit").push_all(arg_tbl)
end, { nargs = "?", desc = "Git push all" })

cmd("Time", function(_)
  vim.notify(vim.fn.strftime("%Y-%m-%d %a %T"))
end, { desc = "Print current time (May be useful in full screen?)" })
