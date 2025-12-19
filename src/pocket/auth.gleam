import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/javascript/promise.{type Promise}

import pocket/internal/ffi/pocketbase
import pocket/types.{type Collection, type DecodeResult}

// A function to list authentication methods for a given collection and ID
pub fn list_methods(col: Collection) -> Promise(DecodeResult(Methods)) {
  pocketbase.list_auth_methods(col)
  |> promise.map(decode)
}

fn decode(dynamic: Dynamic) -> DecodeResult(Methods) {
  decode.run(dynamic, methods_decoder())
}

fn methods_decoder() -> decode.Decoder(Methods) {
  use mfa <- decode.field("mfa", mfa_decoder())
  use oauth2 <- decode.field("oauth2", oauth2_decoder())
  use otp <- decode.field("otp", otp_decoder())
  use password <- decode.field("password", password_decoder())
  decode.success(Methods(mfa:, oauth2:, otp:, password:))
}

pub type Methods {
  Methods(mfa: Mfa, oauth2: Oauth2, otp: Otp, password: Password)
}

pub type Mfa {
  Mfa(duration: Int, enabled: Bool)
}

pub type Oauth2 {
  Oauth2(enabled: Bool, providers: List(dynamic.Dynamic))
}

pub type Password {
  Password(enabled: Bool, identity_fields: List(String))
}

pub type Otp {
  Otp(duration: Int, enabled: Bool)
}

fn mfa_decoder() -> decode.Decoder(Mfa) {
  use duration <- decode.field("duration", decode.int)
  use enabled <- decode.field("enabled", decode.bool)
  decode.success(Mfa(duration:, enabled:))
}

fn oauth2_decoder() -> decode.Decoder(Oauth2) {
  use enabled <- decode.field("enabled", decode.bool)
  use providers <- decode.field("providers", decode.list(decode.dynamic))
  decode.success(Oauth2(enabled:, providers:))
}

fn otp_decoder() -> decode.Decoder(Otp) {
  use duration <- decode.field("duration", decode.int)
  use enabled <- decode.field("enabled", decode.bool)
  decode.success(Otp(duration:, enabled:))
}

fn password_decoder() -> decode.Decoder(Password) {
  use enabled <- decode.field("enabled", decode.bool)
  use identity_fields <- decode.field(
    "identityFields",
    decode.list(decode.string),
  )
  decode.success(Password(enabled:, identity_fields:))
}
