# Flare Macro SDK

Development-time compatibility shims and Luau declarations for **FlareFuscator** macros.

Current FlareFuscator version: **V3**. 

The SDK preserves normal unobfuscated execution. It does **not** emulate FlareFuscator's encryption, virtualization, protected VM state, or automatic macro planner.

## Usage

Load the SDK before the rest of your unobfuscated script:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/fhwifmw/FlareFuscator-Macro-SDK/refs/heads/main/sdk.lua"))()
```

Then use the macros normally.

## `FF_ENC(value [, transient])`

In development this returns the original value while validating the public argument contract.

```lua
local secret = FF_ENC("hello")
local transient = FF_ENC("password", true)
local id = FF_ENC(123456)

local fn = FF_ENC(function(x)
    return x * 2
end)
```

`FF_ENC(function() end, true)` is invalid because transient decoding applies to supported literals, not functions.

Production V3 owns the real protected constant/function backend.

## `FF_SECURE(function)`

```lua
local verify = FF_SECURE(function(key)
    return key == "abc"
end)
```

The SDK returns the original function. Production V3 applies the security policy.

## `FF_LIGHT(function)`

`FF_LIGHT` is a **function wrapper only**.

```lua
local hot = FF_LIGHT(function(x)
    return x * x
end)
```

It is not an arbitrary area macro.

## `FF_NOVM(function)`

`FF_NOVM` is also a **function wrapper only**.

```lua
local raw = FF_NOVM(function(value)
    return tostring(value)
end)
```

It is not an arbitrary area macro.

## `FF_BIND(value, runtimeValue, expectedValue)`

```lua
local payload = FF_BIND("secret", game.PlaceId, 123456789)
```

For unobfuscated development, the SDK validates `runtimeValue == expectedValue` and returns `value`.

Production V3 binds protected reconstruction to the supplied runtime value.

## `FF_EPHEMERAL(value)` / `FF_EPH(value)`

`FF_EPH` means global single-consumption **per protected source site** in production V3.

```lua
local init = FF_EPH(function()
    print("once")
end)
```

The SDK provides a best-effort one-call wrapper for a function value and consumes it at call entry, even if that call errors.

The production compiler/runtime is stronger: separately-created closures from the same `FF_EPH` source site share the same global one-shot capability.

For primitive strings/numbers, the SDK returns the original primitive unchanged because plain Lua/Luau cannot transparently track every later read without changing the value's type or semantics. Production V3 enforces the protected source-site lifecycle.

## `FF_MACRO(tier) ... FF_END()`

`FF_MACRO` is the **only arbitrary area macro**.

```lua
local outside = 50

FF_MACRO(bal)

local inside = outside + 1
print(inside)

FF_END()

print(inside)
```

In the development SDK, `FF_MACRO` and `FF_END` are no-op marker functions. That means everything between them stays ordinary Luau in exactly the same lexical scope. There is no string body, nested `loadstring`, wrapper closure, or source preprocessor.

Available local policy tiers:

```lua
FF_MACRO(lite)
-- performance-biased automatic macro planning
FF_END()

FF_MACRO(bal)
-- balanced automatic macro planning
FF_END()

FF_MACRO(high)
-- security-biased automatic macro planning
FF_END()
```

These are **local planner policies**, not global obfuscation presets.

Nested `FF_MACRO` regions are valid in the compiler; the innermost region supplies the most local automatic policy. Explicit macros such as `FF_LIGHT` or `FF_SECURE` still override automatic planner decisions.

## Other retained V3 macros

```lua
FF_OBFUSCATED
FF_LINE
FF_CRASH()
FF_ASSERT(condition, message)
FF_NO_UPVALUES(function() ... end)
FF_DEV_ONLY(function() ... end)
```

Development behavior:

- `FF_OBFUSCATED` is `false`.
- `FF_LINE` is `-1`; the protected compiler owns real per-site source lines.
- `FF_CRASH()` terminates immediately.
- `FF_ASSERT` acts as an assertion.
- `FF_NO_UPVALUES` returns the function; the compiler performs authoritative capture validation.
- `FF_DEV_ONLY` returns the function during development.

Source directives such as `--!flare keep-next` and `--!flare strip-next` are compiler directives and need no runtime shim.

## Type declarations

`types.d.luau` declares the global macro surface for Luau-aware tooling. Register it using the mechanism supported by your autocomplete.
