import gleam/javascript/promise
import gleeunit

import pocket
import pocket/auth

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn list_auth_methods_real_test() {
  pocket.new("https://pocketbase.io")
  |> pocket.collection("users")
  |> auth.list_methods()
  |> promise.map(fn(x) {
    assert x
      == Ok(auth.Methods(
        mfa: auth.Mfa(duration: 0, enabled: False),
        oauth2: auth.Oauth2(enabled: False, providers: []),
        otp: auth.Otp(duration: 0, enabled: False),
        password: auth.Password(enabled: True, identity_fields: ["email"]),
      ))
  })
}
