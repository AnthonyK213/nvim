local lib = require("utility.lib")

describe("Git", function ()
    local get_git_branch = lib.get_git_branch

    it("should return current git branch(dev)", function ()
        assert.equal("dev", get_git_branch())
    end)
end)

describe("String", function ()
    it("should return number value of the first char", function ()
        local test_strs = {
            "ABC", "这acb", "もう　二度と", "ß", "", "\", ""
        }
        for _, str in ipairs(test_strs) do
            assert.equal(vim.fn.char2nr(str), lib.str_char2nr(str))
        end
    end)
end)
