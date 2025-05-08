local luasnip = require("luasnip")
local cmp = require("cmp")
local lib = require("utility.lib")

require("luasnip.loaders.from_vscode").lazy_load {
  paths = { vim.fn.stdpath("config") .. "/snippet" }
}

local function feedkeys(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

---comment
---@param chunk string
---@return boolean
local function is_md_list_marker(chunk)
  if not chunk or not lib.has_filetype("markdown") then
    return false
  end
  return vim.regex([[\v^\s*(\+|-|\*|\d+\.|\w\))(\s\[.\])?\s$]]):match_str(chunk) ~= nil
end

local cmp_setup = {
  completion = {
    keyword_length = 2,
  },
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end
  },
  mapping = {
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i" }),
    ["<CR>"] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }
        else
          fallback()
        end
      end,
    }),
    ["<Tab>"] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.select_next_item {
            behavior = cmp.SelectBehavior.Insert
          }
          return
        end

        local context = lib.get_half_line(-1)
        if is_md_list_marker(context.b) then
          feedkeys("<C-\\><C-O>>>", "n")
          vim.api.nvim_feedkeys(string.rep(vim.g._const_dir_r, vim.bo.ts), "n", true)
        elseif luasnip.locally_jumpable(1) then
          luasnip.jump(1)
        elseif luasnip.expandable() then
          luasnip.expand {}
        elseif context.b:match("[%w._:]$")
            and vim.bo.bt ~= "prompt" then
          cmp.complete()
        else
          fallback()
        end
      end,
      s = function(fallback)
        if luasnip.locally_jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end,
      c = function()
        if cmp.visible() then
          cmp.select_next_item {
            behavior = cmp.SelectBehavior.Insert
          }
        else
          cmp.complete()
        end
      end
    }),
    ["<S-Tab>"] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item {
            behavior = cmp.SelectBehavior.Insert
          }
          return
        end

        local context = lib.get_half_line(-1)
        if is_md_list_marker(context.b) then
          local idt = vim.fn.indent(".")
          local pos = vim.api.nvim_win_get_cursor(0)
          if idt ~= 0 then
            feedkeys("<C-\\><C-O><<", "n")
            pos[2] = pos[2] - math.min(idt, vim.bo.ts)
            vim.api.nvim_win_set_cursor(0, pos)
          end
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end,
      s = function(fallback)
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end,
      c = function()
        if cmp.visible() then
          cmp.select_prev_item({
            behavior = cmp.SelectBehavior.Insert
          })
        else
          cmp.complete()
        end
      end
    })
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "nvim_lsp_signature_help" },
  }, {
    { name = "path" },
    { name = "buffer", keyword_length = 4 },
  }),
  experimental = {}
}

local win_opt = { border = _G._my_core_opt.tui.border }
cmp_setup.window = {
  completion = cmp.config.window.bordered(win_opt),
  documentation = cmp.config.window.bordered(win_opt)
}

if _G._my_core_opt.tui.cmp_ghost then
  cmp_setup.experimental.ghost_text = true
end

cmp.setup(cmp_setup)

cmp.setup.cmdline("/", {
  sources = {
    { name = "buffer" }
  }
})

cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path" }
  }, {
    { name = "cmdline" }
  })
})
