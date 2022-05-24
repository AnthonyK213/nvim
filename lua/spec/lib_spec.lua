local lib = require("utility.lib")

describe("Git", function ()
    local get_git_branch = lib.get_git_branch

    it("should return current git branch(dev)", function ()
        assert.equal("dev", get_git_branch())
    end)
end)
