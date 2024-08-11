local bint = require ".bint" (256)

local mod = {}

--- Perform division rounding up between two numbers considering bints.
-- @param x The numerator, a bint or lua number.
-- @param y The denominator, a bint or lua number.
-- @return The quotient rounded up, a bint or lua number.
-- @raise Asserts on attempt to divide by zero.
local function div_round_up(x, y)
  local ix, iy = bint.tobint(x), bint.tobint(y)
  if ix and iy then
    local quot, rem = bint.tdivmod(ix, iy)
    if not rem:iszero() and (bint.ispos(x) == bint.ispos(y)) then
      quot:_inc()
    end
    return quot
  end
  local nx, ny = bint.tonumber(x), bint.tonumber(y)
  local quotient = nx / ny
  if quotient ~= math.floor(quotient) then
    return math.ceil(quotient)
  end
  return quotient
end


--- Calculate value of input token expressed in output token (Get-Price), according to current amm pool reserves + configuration
--- @param inAmount bint total input qty (base token)
--- @param reservesIn bint token reserve
--- @param reservesOut bint token reserve
--- @param totalFee number fee taken by pool
--- @param ammCalcPrecision number (power of 10) used by pool to perform calculations
--- @return bint value The value in quote token of the amount in base token
local function getOutput(inAmount, reservesIn, reservesOut, totalFee, ammCalcPrecision)
  local amountAfterFees = bint.udiv(
    inAmount * bint(math.floor((100 - totalFee) * ammCalcPrecision)),
    bint(100 * ammCalcPrecision)
  )

  local K = reservesIn * reservesOut
  return reservesOut - div_round_up(K, (reservesIn + amountAfterFees))
end

function mod.getExpectedOut(reserves, fee)
  local tokenIn = TOKEN_A
  local tokenOut = TOKEN_B
  local amountIn = bint(INPUT_QTY)
  local reservesIn = reserves[tokenIn]
  local reservesOut = reserves[tokenOut]
  local ammCalcPrecision = 100

  return getOutput(
    amountIn,
    bint(reservesIn),
    bint(reservesOut),
    tonumber(fee),
    ammCalcPrecision)
end

return mod
