local kbd = vim.keymap.set
local _o = { noremap = true, silent = true }
kbd("n", "<C-A>", require("dial.map").inc_normal(), _o)
kbd("n", "<C-X>", require("dial.map").dec_normal(), _o)
kbd("v", "<C-A>", require("dial.map").inc_visual(), _o)
kbd("v", "<C-X>", require("dial.map").dec_visual(), _o)
kbd("v", "g<C-A>", require("dial.map").inc_gvisual(), _o)
kbd("v", "g<C-X>", require("dial.map").dec_gvisual(), _o)
