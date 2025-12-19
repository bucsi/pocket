import gleam/dynamic/decode
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

pub fn get_real_test() {
  let first =
    pocket.new("https://pocketbase.io")
    |> pocket.collection("posts")
    |> pocket.get_full_list(post_for_get_test_decoder())
    |> promise.map(fn(x) {
      let assert Ok([first, ..]) = x
      first
    })

  let item = {
    use first <- promise.await(first)
    pocket.new("https://pocketbase.io")
    |> pocket.collection("posts")
    |> pocket.get_one(first.id, post_for_get_test_decoder())
    |> promise.map(fn(x) {
      let assert Ok(item) = x
      item
    })
  }

  use first <- promise.map(first)
  use item <- promise.map(item)
  assert first == item
}

type PostForGetTest {
  PostForGetTest(id: String, title: String)
}

fn post_for_get_test_decoder() -> decode.Decoder(PostForGetTest) {
  use id <- decode.field("id", decode.string)
  use title <- decode.field("title", decode.string)
  decode.success(PostForGetTest(id:, title:))
}
