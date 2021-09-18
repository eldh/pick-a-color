type suspenseConfig = {timeoutMs: int}

@module("react")
external useTransition: suspenseConfig => (bool, (unit => unit) => unit) = "useTransition"
