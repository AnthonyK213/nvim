local lib = require("utility.lib")

---Add a new mapping.
---@param desc string To give a description to the mapping.
---@param mode string|table Mode short-name.
---@param lhs string Left-hand side {lhs} of the mapping.
---@param rhs string|function Right-hand side {rhs} of the mapping.
---@param opts? table Optional parameters map.
local kbd = function(desc, mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend("force", options, opts) end
  if desc then options.desc = desc end
  vim.keymap.set(mode, lhs, rhs, options)
end

---Normal mode or Visual mode?
---@return string?
local get_mode = function()
  local m = vim.api.nvim_get_mode().mode
  if m == "n" then
    return m
  elseif vim.list_contains({ "v", "V", "" }, m) then
    return "v"
  else
    return nil
  end
end

---Switch to normal mode.
local to_normal = function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-N>", false, true, true), "nx", false)
end

kbd("Adjust window size up", "n", "<C-UP>", "<C-W>-")
kbd("Adjust window size down", "n", "<C-DOWN>", "<C-W>+")
kbd("Adjust window size left", "n", "<C-LEFT>", "<C-W>>")
kbd("Adjust window size right", "n", "<C-RIGHT>", "<C-W><")
kbd("Switch to normal mode in terminal", "t", "<ESC>", "<C-\\><C-N>")
kbd("Close terminal", "t", "<M-d>", "<C-\\><C-N><Cmd>bd!<CR>")
kbd("Echo git status", "n", "<leader>gs", "<Cmd>!git status<CR>")
kbd("Find and replace", "n", "<M-g>", ":%s/", { silent = false })
kbd("Find and replace", "v", "<M-g>", ":s/", { silent = false })
kbd("Stop the search highlighting", "n", "<leader>bh", "<Cmd>noh<CR>")
kbd("Next buffer", "n", "<leader>bn", "<Cmd>bn<CR>")
kbd("Previous buffer", "n", "<leader>bp", "<Cmd>bp<CR>")
kbd("Toggle spell check", "n", "<leader>cs", "<Cmd>setlocal spell! spelllang=en_us<CR>")
kbd("Cursor to beginning of command-line", "c", "<C-A>", "<C-B>", { silent = false })
kbd("Cursor left", "c", "<C-B>", "<LEFT>", { silent = false })
kbd("Cursor right", "c", "<C-F>", "<RIGHT>", { silent = false })
kbd("Open the command-line window", "c", "<C-H>", "<C-F>", { silent = false })
kbd("Cursor one WORD left", "c", "<M-b>", "<C-LEFT>", { silent = false })
kbd("Cursor one WORD right", "c", "<M-f>", "<C-RIGHT>", { silent = false })
kbd("Delete the word before the cursor", "c", "<M-BS>", "<C-W>", { silent = false })
kbd("Write the whole buffer to the current file", { "n", "i" }, "<C-S>",
  function() if vim.bo.bt == "" then vim.cmd.write() end end, { silent = false })
kbd("Copy to system clipboard", "v", "<M-c>", '"+y')
kbd("Cut to system clipboard", "v", "<M-x>", '"+x')
kbd("Paste from system clipboard", { "n", "v" }, "<M-v>", '"+p')
kbd("Paste from system clipboard", "i", "<M-v>", "<C-R>=@+<CR>")
kbd("Select all lines in buffer", "n", "<M-a>", "ggVG")
kbd("Command-line mode", "n", "<M-x>", ":", { silent = false })
kbd("Command-line mode", "i", "<M-x>", "<C-\\><C-O>:", { silent = false })
kbd("Cursor one word left", "i", "<M-b>", "<C-\\><C-O>b")
kbd("Cursor one word right", "i", "<M-f>", "<C-\\><C-O>e<Right>")
kbd("Cursor one word left", "n", "<M-b>", "b")
kbd("Cursor one word right", "n", "<M-f>", "e")
kbd("To the first character of the screen line", "i", "<C-A>", "<C-\\><C-O>g0")
kbd("To the last character of the screen line", "i", "<C-E>", "<C-\\><C-O>g$")
kbd("Kill text until the end of the line", "i", "<C-K>", "<C-\\><C-O>D")
kbd("Cursor left", "i", "<C-B>", [[col(".") == 1 ? "<C-\><C-O>-<C-\><C-O>$" : g:_const_dir_l]],
  { expr = true, replace_keycodes = false })
kbd("Cursor right", "i", "<C-F>", [[col(".") >= col("$") ? "<C-\><C-O>+" : g:_const_dir_r]],
  { expr = true, replace_keycodes = false })
kbd("Kill text until the end of the word", "i", "<M-d>", "<C-\\><C-O>dw")
kbd("Move line up", "n", "<M-p>", [[<Cmd>exe "move" max([line(".") - 2, 0])<CR>]])
kbd("Move line down", "n", "<M-n>", [[<Cmd>exe "move" min([line(".") + 1, line("$")])<CR>]])
kbd("Move block up", "v", "<M-p>", [[:<C-U>exe "'<,'>move" max([line("'<") - 2, 0])<CR>gv]])
kbd("Move block down", "v", "<M-n>", [[:<C-U>exe "'<,'>move" min([line("'>") + 1, line("$")])<CR>gv]])
kbd("Cursor down", { "n", "v", "i" }, "<C-N>", function() vim.cmd.normal("gj") end)
kbd("Cursor up", { "n", "v", "i" }, "<C-P>", function() vim.cmd.normal("gk") end)
for direct, desc in pairs { h = "left", j = "down", k = "up", l = "right", w = "toggle" } do
  kbd("Navigate window: " .. desc, "n", "<M-" .. direct .. ">", function()
    lib.feedkeys("<C-W>" .. direct, "nx", false)
  end)
end
for i = 1, 10, 1 do
  kbd("Goto tab " .. tostring(i), { "n", "i", "t" }, "<M-" .. tostring(i % 10) .. ">", function()
    local tabs = vim.api.nvim_list_tabpages()
    if i > #tabs then
      lib.warn("Tab " .. i .. " is not valid.")
      return
    end
    vim.api.nvim_set_current_tabpage(tabs[i])
  end)
end
for key, val in pairs {
  Baidu      = { "b", "https://www.baidu.com/s?wd=" },
  DuckDuckGo = { "d", "https://duckduckgo.com/?q=" },
  Google     = { "g", "https://www.google.com/search?q=" },
  Youdao     = { "y", "https://dict.youdao.com/w/eng/" }
} do
  kbd("Search cword with " .. key, { "n", "x" }, "<leader>h" .. val[1], function()
    local txt
    local mode = get_mode()
    if mode == "n" then
      local word = require("utility.util").get_word()
      txt = lib.url_encode(word)
    elseif mode == "v" then
      txt = lib.url_encode(lib.get_gv())
    else
      return
    end
    require("utility.util").sys_open(val[2] .. txt)
  end)
end
kbd("Look up the word in the dictionary", { "n", "x" }, "<leader>hh", function()
  local word
  local mode = get_mode()
  if mode == "n" then
    word = require("utility.util").get_word()
  elseif mode == "v" then
    word = lib.get_gv()
  else
    return
  end
  require("utility.stardict").stardict(word)
end)
kbd("Mouse toggle", { "n", "v", "i", "t" }, "<F8>", function()
  if #(vim.o.mouse) == 0 then
    vim.o.mouse = "nvi"
    vim.notify("Mouse enabled")
  else
    vim.o.mouse = ""
    vim.notify("Mouse disabled")
  end
end)
kbd("Run code", "n", "<F17>", function() require("utility.run").code_run() end)
kbd("Run code", "n", "<S-F5>", function() require("utility.run").code_run() end)
kbd("Run test", "n", "<F41>", function() require("utility.run").code_run("test") end)
kbd("Run test", "n", "<C-S-F5>", function() require("utility.run").code_run("test") end)
kbd("Show document", "n", "K", function()
  local word, _, _ = require("utility.util").get_word()
  if not pcall(vim.cmd.help, word) then
    vim.notify(string.format("E149: Sorry, no help for %s", word), vim.log.levels.ERROR)
  end
end)
kbd("Search visual selection forward", "x", "*", function()
  local pat = lib.get_gv()
      :gsub("([/\\])", function(x)
        return "\\" .. x
      end):gsub("\n", [[\n]])
  vim.cmd([[/\V]] .. pat)
end)
kbd("Search visual selection backward", "x", "#", function()
  local pat = lib.get_gv():gsub("([?\\])", function(x)
    return "\\" .. x
  end):gsub("\n", [[\n]])
  vim.cmd([[?\V]] .. pat)
end)
kbd("Change cwd to current buffer", "n", "<leader>bc", function()
  vim.api.nvim_set_current_dir(lib.get_buf_dir())
  vim.cmd.pwd()
end, { silent = false })
kbd("Delete current buffer", "n", "<leader>bd", function()
  local bufs = lib.get_listed_bufs()
  local sp = vim.list_contains({
    "help", "terminal", "quickfix", "nofile"
  }, vim.bo.bt)
  local handle = vim.api.nvim_get_current_buf()
  if (#bufs == 1 and vim.bo[handle].buflisted)
      or (#bufs == 0 and not vim.bo[handle].buflisted) then
    table.insert(bufs, vim.api.nvim_create_buf(true, true))
  end
  if #bufs >= 2 and not sp then
    local index = lib.tbl_find_first(bufs, handle)
    vim.api.nvim_set_current_buf(bufs[index + (index == 1 and 1 or -1)])
  end
  vim.bo[handle].buflisted = false
  local ok = pcall(vim.api.nvim_buf_delete, handle, {
    force = false,
    unload = vim.o.hidden
  })
  if not ok then
    lib.warn("Failed to delete buffer")
  end
end)
kbd("Toggle background theme", "n", "<leader>bg", function()
  local bg = vim.o.bg == "dark" and "light" or "dark"
  require("utility.theme").set_theme(bg)
end)
kbd("Open nvimrc", "n", "<M-,>", vim.fn["my#compat#open_nvimrc"])
kbd("Open system file manager", "n", "<leader>oe", function()
  require("utility.util").sys_open(lib.get_buf_dir())
end)
kbd("Open terminal", "n", "<leader>ot", function()
  local ok = require("utility.util").terminal()
  if ok then
    vim.api.nvim_feedkeys("i", "n", true)
  end
end)
kbd("Open current file with the system default application", "n", "<leader>ob", function()
  require("utility.util").sys_open(vim.api.nvim_buf_get_name(0))
end)
kbd("Open path or url under the cursor", "n", "<leader>ou", function()
  local util = require("utility.util")
  util.sys_open(util.match_path_or_url_at_point(), true)
end)
kbd("Evaluate lua math expression surrounded by `", "n", "<leader>ev", function()
  require("utility.eval").lua_eval()
end)
kbd("Evaluate lisp math expression surrounded by `", "n", "<leader>el", function()
  require("utility.eval").lisp_eval()
end)
kbd("Insert a timestamp after cursor", "n", "<leader>ns", function()
  vim.paste({ vim.fn.strftime("<%Y-%m-%d %a %H:%M>") }, -1)
end)
kbd("Append day of week after a date (yyyy-mm-dd)", "n", "<leader>nd", function()
  require("utility.gtd").append_day_from_date()
end)
kbd("Print TODO list", "n", "<leader>nt", function()
  require("utility.gtd").print_todo_list()
end)
kbd("Hanzi count", { "n", "x" }, "<leader>cc", function()
  local mode = get_mode()
  local txt
  if mode == "n" then
    txt = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  elseif mode == "v" then
    txt = lib.get_gv()
  else
    return
  end
  require("utility.note").hanzi_count(txt)
end)
kbd("Insert list bullets", "i", "<M-CR>", function()
  require("utility.note").md_insert_bullet()
end)
kbd("Regenerate list bullets", "n", "<leader>ml", function()
  require("utility.note").md_sort_num_bullet()
end)
kbd("Create a new email", "n", "<leader>mn", function()
  require("utility.mail").Mail.new_file()
end)
kbd("Send the mail from current buffer.", "n", "<leader>ms", function()
  require("utility.mail").Mail.from_buf():send()
end)
kbd("Fetch recent mail from imap server.", "n", "<leader>mf", function()
  require("utility.mail").Mailbox:fetch()
end)
kbd("Surrounding add", { "n", "x" }, "<leader>sa", function()
  if not vim.bo.modifiable then return end
  local mode = get_mode()
  if mode then
    to_normal()
    require("utility.srd").srd_add(mode)
  end
end)
kbd("Surrounding delete", "n", "<leader>sd", function()
  if not vim.bo.modifiable then return end
  require("utility.srd").srd_sub("")
end)
kbd("Surrounding change", "n", "<leader>sc", function()
  if not vim.bo.modifiable then return end
  require("utility.srd").srd_sub()
end)
kbd("Comment current/selected line(s)", { "n", "x" }, "<leader>kc", function()
  local mode = get_mode()
  if mode == "n" then
    require("utility.cmt").cmt_add_n()
  elseif mode == "v" then
    to_normal()
    require("utility.cmt").cmt_add_v()
  else
    return
  end
end)
kbd("Uncomment current/selected line(s)", { "n", "x" }, "<leader>ku", function()
  local mode = get_mode()
  if mode == "n" then
    require("utility.cmt").cmt_del_n()
  elseif mode == "v" then
    to_normal()
    require("utility.cmt").cmt_del_v()
  else
    return
  end
end)
kbd("Show highlight information", "n", "<leader>vs", function() vim.show_pos() end)
kbd("Decode selected base64 code.", "x", "<leader>zbd", function()
  to_normal()
  local futures = require("futures")
  local bufnr = vim.api.nvim_get_current_buf()
  futures.spawn(function()
    local sr, sc, er, ec = require("utility.lib").get_gv_mark()
    local base64_code = table.concat(vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})):gsub("[^A-Za-z0-9+/]", "")
    vim.notify("Decoding...")
    local code = futures.Task.new(require("utility.base64").decode, base64_code):await()
    if not code then
      lib.warn("Decode failed")
      return
    end
    vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, vim.split(code, "[\r\n]", {
      trimempty = true,
    }))
    vim.notify("Decode finished")
  end)
end)
kbd("Encode selection to base64 code.", "x", "<leader>zbe", function()
  to_normal()
  local futures = require("futures")
  local bufnr = vim.api.nvim_get_current_buf()
  local width = vim.bo.textwidth
  if width == 0 then width = 80 end
  futures.spawn(function()
    local sr, sc, er, ec = require("utility.lib").get_gv_mark()
    local code = table.concat(vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {}), "\n")
    vim.notify("Encoding...")
    local base64_code = futures.Task.new(require("utility.base64").encode, code):await()
    if not base64_code then
      lib.warn("Encode failed")
      return
    end
    local replacement = {}
    local half = vim.api.nvim_buf_get_text(bufnr, sr, 0, sr, sc, {})[1]
    local half_len = vim.api.nvim_strwidth(half)
    local start = 1
    if half_len >= width then
      table.insert(replacement, "")
    else
      start = width - half_len
      table.insert(replacement, base64_code:sub(1, start))
      start = start + 1
    end
    while start < #base64_code do
      table.insert(replacement, base64_code:sub(start, start + width - 1))
      start = start + width
    end
    vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, replacement)
    vim.notify("Encode finished")
  end)
end)
kbd("Toggle jieba-mode.", "n", "<leader>jm", function()
  local jieba = require("utility.jieba")
  if jieba.is_enabled() then
    jieba:disable()
    vim.notify("Jieba is disabled")
  else
    if jieba:enable() then
      vim.notify("Jieba is enabled")
    end
  end
end)
