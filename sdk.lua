-- Flare Macro SDK
-- Development-time compatibility shims for FlareFuscator V3 macros.
--
-- This file preserves plain-source development behavior. It does not emulate
-- FlareFuscator's VM, encryption, protected constant storage, or planner.

if not FF_OBFUSCATED then
    FF_OBFUSCATED = false
    FF_LINE = -1

    lite = lite or "lite"
    bal = bal or "bal"
    high = high or "high"

    local function macroError(code, message, level)
        error(("Flare Macro SDK [%s]: %s"):format(code, message), (level or 1) + 1)
    end

    local function protectableType(value)
        local kind = type(value)
        return kind == "string" or kind == "number" or kind == "function"
    end

    function FF_CRASH(...)
        if select("#", ...) ~= 0 then
            macroError("FF_CRASH:E_ARG_COUNT", "FF_CRASH() does not accept arguments.", 2)
        end
        error("FF_CRASH", 0)
    end

    function FF_ASSERT(condition, message)
        if not condition then
            error(message or "FF_ASSERT failed", 2)
        end
        return condition
    end

    function FF_NO_UPVALUES(fn)
        if type(fn) ~= "function" then
            macroError("FF_NO_UPVALUES:E_FUNCTION_REQUIRED", "expected a function.", 2)
        end
        -- The compiler performs the authoritative capture validation.
        return fn
    end

    function FF_DEV_ONLY(fn)
        if type(fn) ~= "function" then
            macroError("FF_DEV_ONLY:E_FUNCTION_REQUIRED", "expected a function.", 2)
        end
        return fn
    end

    function FF_ENC(value, ...)
        local argc = select("#", ...)
        if argc > 1 then
            macroError("FF_ENC:E_ARG_COUNT", "expected FF_ENC(value [, transient]).", 2)
        end
        if not protectableType(value) then
            macroError("FF_ENC:E_UNSUPPORTED_VALUE", "expected a string, number, or function.", 2)
        end

        if argc == 1 then
            local transient = ...
            if type(transient) ~= "boolean" then
                macroError("FF_ENC:E_TRANSIENT_TYPE", "transient must be a boolean.", 2)
            end
            if type(value) == "function" then
                macroError("FF_ENC:E_TRANSIENT_FUNCTION", "transient decoding cannot be applied to functions.", 2)
            end
        end

        return value
    end

    function FF_SECURE(fn)
        if type(fn) ~= "function" then
            macroError("FF_SECURE:E_FUNCTION_REQUIRED", "expected a function.", 2)
        end
        return fn
    end

    function FF_LIGHT(fn)
        if type(fn) ~= "function" then
            macroError("FF_LIGHT:E_FUNCTION_REQUIRED", "FF_LIGHT is a function wrapper and expects a function.", 2)
        end
        return fn
    end

    function FF_NOVM(fn)
        if type(fn) ~= "function" then
            macroError("FF_NOVM:E_FUNCTION_REQUIRED", "FF_NOVM is a function wrapper and expects a function.", 2)
        end
        return fn
    end

    function FF_BIND(value, runtimeValue, expectedValue)
        if not protectableType(value) then
            macroError("FF_BIND:E_UNSUPPORTED_VALUE", "expected a string, number, or function protected value.", 2)
        end
        if type(runtimeValue) ~= type(expectedValue) then
            macroError(
                "FF_BIND:E_TYPE_MISMATCH",
                ("runtime value type %s does not match expected value type %s."):format(type(runtimeValue), type(expectedValue)),
                2
            )
        end
        if runtimeValue ~= expectedValue then
            macroError(
                "FF_BIND:E_RUNTIME_MISMATCH",
                "runtime expression does not equal the expected value in this development run.",
                2
            )
        end
        return value
    end

    function FF_EPHEMERAL(value)
        if not protectableType(value) then
            macroError("FF_EPH:E_UNSUPPORTED_VALUE", "expected a string, number, or function.", 2)
        end

        if type(value) ~= "function" then
            -- Primitive values remain real primitives in development. The V3
            -- compiler/runtime enforces global source-site single-consumption.
            return value
        end

        -- Best-effort development approximation. Production V3 semantics are
        -- stronger: consumption is GLOBAL PER PROTECTED SOURCE SITE, including
        -- separately-created closures from the same FF_EPH site.
        local consumed = false
        return function(...)
            if consumed then
                macroError("FF_EPH:E_ALREADY_CONSUMED", "ephemeral function has already been invoked.", 2)
            end
            consumed = true -- consume at entry, even when the wrapped call errors
            return value(...)
        end
    end

    FF_EPH = FF_EPHEMERAL

    -- FF_MACRO is the only arbitrary area macro. In plain development these
    -- markers are no-ops, so everything between them remains ordinary Luau in
    -- the exact same lexical scope.
    function FF_MACRO(tier, ...)
        if select("#", ...) ~= 0 then
            macroError("FF_MACRO:E_ARG_COUNT", "expected FF_MACRO(lite|bal|high).", 2)
        end
        if tier ~= lite and tier ~= bal and tier ~= high then
            macroError("FF_MACRO:E_INVALID_TIER", "tier must be lite, bal, or high.", 2)
        end
    end

    function FF_END(...)
        if select("#", ...) ~= 0 then
            macroError("FF_MACRO:E_END_ARGS", "FF_END() does not accept arguments.", 2)
        end
    end

    -- Compatibility aliases retained for older source. Canonical V3 names are FF_*.
    FLARE_OBFUSCATED = FF_OBFUSCATED
    FLARE_LINE = FF_LINE
    FLARE_CRASH = FF_CRASH
    FLARE_ASSERT = FF_ASSERT
    FLARE_NO_UPVALUES = FF_NO_UPVALUES
    FLARE_DEV_ONLY = FF_DEV_ONLY

    FLARE_ENCSTR = FF_ENC
    FLARE_STRENC = FF_ENC
    FLARE_ENCNUM = FF_ENC
    FLARE_NUMENC = FF_ENC
    FLARE_PROTECT = FF_ENC
    FLARE_ENCFUNC = FF_ENC
    FLARE_FUNCENC = FF_ENC
    FLARE_SENSITIVE = FF_SECURE
    FLARE_NO_VM = FF_NOVM
    FLARE_NO_VIRTUALIZE = FF_NOVM
end
