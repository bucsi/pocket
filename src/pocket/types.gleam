import gleam/dynamic/decode

pub type PocketBase

pub type Collection

pub type DecodeResult(t) =
  Result(t, List(decode.DecodeError))
