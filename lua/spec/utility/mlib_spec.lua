local mlib = require("utility.mlib")

describe("Fibonacci", function()
    local fibonacci = mlib.fibonacci
    local fib = function(n)
        local a, b = 0, 1
        for _ = 0, n - 1 do
            a, b = a + b, a
        end
        return a
    end

    it("should calculate the nth fibonacci number", function()
        for i = 1, 42 do
            assert.equal(fib(i), fibonacci(i))
        end
    end)

    it("should throw exceptions", function()
        assert.has_error(function()
            fibonacci(-1)
        end, "Input number must be positive.")
        assert.has_error(function()
            fibonacci(4.2)
        end, "Input number must be a integer.")
    end)
end)

describe("Gamma function", function()
    local gamma = mlib.gamma

    it("should calculate gamma(0.5)", function()
        assert(math.sqrt(math.pi) - gamma(0.5) < 1e-8)
    end)

    it("should throw exceptions", function()
        assert.has_error(function()
            gamma(-3)
        end, "Input number must be positive.")
    end)
end)
