import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/javascript/promise.{type Promise}
import gleam/option

import pocket/internal/ffi/pocketbase
import pocket/types.{type Collection, type DecodeResult}

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

pub type AuthStore(u) {
  AuthStore(is_valid: Bool, token: String, record: option.Option(u))
}

pub type AuthInfo {
  AuthInfo(is_valid: Bool, token: String, record_id: option.Option(String))
}

pub fn with_password(
  collection: Collection,
  username_or_email: String,
  password: String,
) -> Promise(Dynamic) {
  collection |> pocketbase.auth_with_password(username_or_email, password)
}

pub fn get_store(
  pb: types.PocketBase,
  decoder: decode.Decoder(u),
) -> DecodeResult(AuthStore(u)) {
  pb |> pocketbase.get_auth_store() |> decode.run(auth_store_decoder(decoder))
}

pub fn get_info(pb: types.PocketBase) -> AuthInfo {
  let assert Ok(info) =
    pb |> pocketbase.get_auth_info() |> decode.run(auth_info_decoder())
    as "The data will always be of the expected shape"
  info
}

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

fn auth_store_decoder(
  record_decoder: decode.Decoder(u),
) -> decode.Decoder(AuthStore(u)) {
  use is_valid <- decode.field("isValid", decode.bool)
  use token <- decode.field("token", decode.string)
  use record <- decode.field("record", decode.optional(record_decoder))
  decode.success(AuthStore(is_valid:, token:, record:))
}

fn auth_info_decoder() -> decode.Decoder(AuthInfo) {
  use is_valid <- decode.field("isValid", decode.bool)
  use token <- decode.field("token", decode.string)
  use record_id <- decode.field("recordId", decode.optional(decode.string))
  decode.success(AuthInfo(is_valid:, token:, record_id:))
}
