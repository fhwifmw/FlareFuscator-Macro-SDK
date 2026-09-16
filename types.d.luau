--!strict
-- Flare Macro SDK global declarations

export type FlareFunction = (...any) -> ...any
export type FlareMacroTier = "lite" | "bal" | "high"

declare FF_OBFUSCATED: boolean
declare FF_LINE: number

declare function FF_CRASH(): never
declare function FF_ASSERT<T>(condition: T, message: string?): T

declare function FF_NO_UPVALUES(fn: FlareFunction): FlareFunction
declare function FF_DEV_ONLY(fn: FlareFunction): FlareFunction

declare FF_ENC:
    ((value: string, transient: boolean?) -> string)
    & ((value: number, transient: boolean?) -> number)
    & ((value: FlareFunction) -> FlareFunction)

declare function FF_SECURE(fn: FlareFunction): FlareFunction
declare function FF_LIGHT(fn: FlareFunction): FlareFunction
declare function FF_NOVM(fn: FlareFunction): FlareFunction

declare function FF_BIND<T>(value: T, runtimeValue: any, expectedValue: any): T

declare FF_EPHEMERAL:
    ((value: string) -> string)
    & ((value: number) -> number)
    & ((value: FlareFunction) -> FlareFunction)

declare FF_EPH: typeof(FF_EPHEMERAL)

declare lite: FlareMacroTier
declare bal: FlareMacroTier
declare high: FlareMacroTier

declare function FF_MACRO(tier: FlareMacroTier): ()
declare function FF_END(): ()

-- Legacy compatibility aliases
declare FLARE_OBFUSCATED: boolean
declare FLARE_LINE: number
declare FLARE_CRASH: typeof(FF_CRASH)
declare FLARE_ASSERT: typeof(FF_ASSERT)
declare FLARE_NO_UPVALUES: typeof(FF_NO_UPVALUES)
declare FLARE_DEV_ONLY: typeof(FF_DEV_ONLY)

declare FLARE_ENCSTR: typeof(FF_ENC)
declare FLARE_STRENC: typeof(FF_ENC)
declare FLARE_ENCNUM: typeof(FF_ENC)
declare FLARE_NUMENC: typeof(FF_ENC)
declare FLARE_PROTECT: typeof(FF_ENC)
declare FLARE_ENCFUNC: typeof(FF_ENC)
declare FLARE_FUNCENC: typeof(FF_ENC)
declare FLARE_SENSITIVE: typeof(FF_SECURE)
declare FLARE_NO_VM: typeof(FF_NOVM)
declare FLARE_NO_VIRTUALIZE: typeof(FF_NOVM)
