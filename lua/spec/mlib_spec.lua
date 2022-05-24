local mlib = require("utility.mlib")

describe("Fibonacci", function()
    local fibonacci = mlib.fibonacci

    it("should calculate the nth fibonacci number", function()
        assert.equals(55, fibonacci(10))
    end)

    it("should throw exceptions", function ()
        assert.has_error(function ()
            fibonacci(-1)
        end, "Input number must be positive.")
        assert.has_error(function ()
            fibonacci(4.2)
        end, "Input number must be a integer.")
    end)
end)

describe("Gamma function", function ()
    local gamma = mlib.gamma

    it("should calculate gamma(0.5)", function ()
        assert(math.sqrt(math.pi) - gamma(0.5) < 1e-8)
    end)

    it("should throw exceptions", function ()
        assert.has_error(function ()
            gamma(-3)
        end, "Invalid input")
    end)
end)
