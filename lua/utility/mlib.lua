local M = {}

---Factorial
---@param x integer
---@return integer result
function M.factorial(x)
    local result = 1
    if x == 0 then
        return result
    end
    for i = 1, x, 1 do
        result = result * i
    end
    return result
end

---nth Fibonacci number
---@param x integer
---@return integer result
function M.fibonacci(x)
    if x < 0 then
        error("Input number must be positive.")
    end
    assert(math.floor(x) == x, "Input number must be a integer.")
    local memo = { 1, 1, 2, 3, 5, 8, 13 }
    local fib
    fib = function (n)
        if memo[n] then return memo[n] end
        local f
        if n % 2 == 0 then
            local m = n / 2
            f = fib(m) * (fib(m) + 2 * fib(m - 1))
        else
            local m = (n - 1) / 2
            f = fib(m + 1) ^ 2 + fib(m) ^ 2
        end
        memo[n] = f
        return f
    end
    return fib(x)
end

---Gamma function
---@param x number
---@return number result
function M.gamma(x)
    assert(x > 0, "Invalid input")

    -- Split the function domain into three intervals:
    -- (0, 0.001), [0.001, 12), and (12, infinity)

    -- First interval: (0, 0.001)
    --
    -- For small x, 1/Gamma(x) has power series x + gamma x^2  - ...
    -- So in this range, 1/Gamma(x) = x + gamma x^2 with error on the
    -- order of x^3.
    -- The relative error over this interval is less than 6e-7.

    -- Euler's gamma constant
    local gamma_const = 0.577215664901532860606512090

    if x < 0.001 then
        return 1.0 / (x * (1.0 + gamma_const * x))
    end

    -- Second interval: [0.001, 12)

    if x < 12.0 then
        -- The algorithm directly approximates gamma over (1,2) and uses
        -- reduction identities to reduce other arguments to this interval.

        local y = x
        local n = 0
        local arg_was_less_than_one = (y < 1.0)

        -- Add or subtract integers as necessary to bring y into (1,2)
        -- Will correct for this below
        if arg_was_less_than_one then
            y = y + 1.0
        else
            n = math.floor(y) - 1  -- will use n later
            y = y - n
        end

        -- numerator coefficients for approximation over the interval (1,2)
        local p = {
            -1.71618513886549492533811E+0,
            2.47656508055759199108314E+1,
            -3.79804256470945635097577E+2,
            6.29331155312818442661052E+2,
            8.66966202790413211295064E+2,
            -3.14512729688483675254357E+4,
            -3.61444134186911729807069E+4,
            6.64561438202405440627855E+4
        }

        -- denominator coefficients for approximation over the interval (1,2)
        local q = {
            -3.08402300119738975254353E+1,
            3.15350626979604161529144E+2,
            -1.01515636749021914166146E+3,
            -3.10777167157231109440444E+3,
            2.25381184209801510330112E+4,
            4.75584627752788110767815E+3,
            -1.34659959864969306392456E+5,
            -1.15132259675553483497211E+5
        }

        local num = 0.0
        local den = 1.0

        local z = y - 1
        for i = 1, 8 do
            num = (num + p[i]) * z
            den = den * z + q[i]
        end
        local result = num / den + 1.0

        -- Apply correction if argument was not initially in (1,2)
        if arg_was_less_than_one then
            -- Use identity gamma(z) = gamma(z+1)/z
            -- The variable "result" now holds gamma of the original y + 1
            -- Thus we use y-1 to get back the orginal y.
            result = result / (y - 1.0)
        else
            -- Use the identity gamma(z+n) = z*(z+1)* ... *(z+n-1)*gamma(z)
            for _ = 1, n do
                result = result * y
                y = y + 1
            end
        end

        return result
    end

    -- Third interval: [12, infinity)

    if x > 171.624 then
        -- Correct answer too large to display.
        return 1.0 / 0 -- float infinity
    end

    return math.exp(M.log_gamma(x))
end

---Log gamma.
---@param x number
---@return number result
function M.log_gamma(x)
    assert(x > 0, "Invalid input")

    if x < 12.0 then
        return math.log(math.abs(M.gamma(x)))
    end

    -- Abramowitz and Stegun 6.1.41
    -- Asymptotic series should be good to at least 11 or 12 figures
    -- For error analysis, see Whittiker and Watson
    -- A Course in Modern Analysis (1927), page 252

    local c = {
        1.0 / 12.0,
        -1.0 / 360.0,
        1.0 / 1260.0,
        -1.0 / 1680.0,
        1.0 / 1188.0,
        -691.0 / 360360.0,
        1.0 / 156.0,
        -3617.0 / 122400.0
    }
    local z = 1.0 / (x * x)
    local sum = c[8]
    for i = 7, 1, -1 do
        sum = sum * z
        sum = sum + c[i]
    end
    local series = sum / x

    local halfLogTwoPi = 0.91893853320467274178032973640562
    local logGamma = (x - 0.5) * math.log(x) - x + halfLogTwoPi + series
    return logGamma
end


return M
