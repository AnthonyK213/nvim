local lib = require("utility.lib")

describe("Git", function()
  local get_git_branch = lib.get_git_branch

  it("should return current git branch(master)", function()
    assert.equal("master", get_git_branch())
  end)
end)

describe("String", function()
  it("should return number value of the first char", function()
    local test_strs = {
      "ABC", "这acb", "もう　二度と", "ß", "", "\", ""
    }
    for _, str in ipairs(test_strs) do
      assert.equal(vim.fn.char2nr(str), lib.str_char2nr(str))
    end
  end)

  it("should return a slice of string", function()
    local test_str = "\t+g-<ab&&0\n356cdef|#::!{[hjkl\r}"
    for _ = 1, 128 do
      local a = math.random(-42, 42)
      local b = math.random(-42, 42)
      assert.equal(test_str:sub(a, b), lib.str_sub(test_str, a, b))
    end
  end)
end)
