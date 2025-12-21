import gleam/dynamic/decode
import gleam/javascript/promise
import gleam/json
import gleam/option
import gleeunit

import glanoid

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

pub fn auth_real_test() {
  let pb = pocket.new("https://pocketbase.io")

  let info = auth.get_info(pb)
  assert info.is_valid == False
  assert info.record_id == option.None

  let #(user_id, payload) = create_new_user_payload()

  let user_created_promise =
    pb
    |> pocket.collection("users")
    |> pocket.create(payload, {
      use record_id <- decode.field("id", decode.string)
      decode.success(record_id)
    })

  use user_created <- promise.await(user_created_promise)
  let assert Ok(user_record_id) = user_created

  let login_promise =
    pb
    |> pocket.collection("users")
    |> auth.with_password(user_id <> "@example.com", user_id)

  use _ <- promise.map(login_promise)

  let info = auth.get_info(pb)
  assert info.is_valid == True
  assert info.record_id == option.Some(user_record_id)
}

pub fn create_user_real_test() {
  let #(user_id, data) = create_new_user_payload()
  pocket.new("https://pocketbase.io")
  |> pocket.collection("users")
  |> pocket.create(data, user_decoder())
  |> promise.map(fn(result) {
    let assert Ok(user) = result |> echo

    assert user
      == User(
        avatar: "",
        collection_name: "users",
        email: user_id <> "@example.com",
        email_visibility: True,
        name: "",
        username: user_id,
        verified: False,
        website: "",
      )
  })
}

fn create_new_user_payload() {
  let assert Ok(nanoid) = glanoid.make_generator(glanoid.default_alphabet)
  let nano_id = nanoid(4)
  let user_id = nano_id <> "-" <> nano_id
  #(
    user_id,
    json.object([
      #("email", json.string(user_id <> "@example.com")),
      #("username", json.string(user_id)),
      #("password", json.string(user_id)),
      #("passwordConfirm", json.string(user_id)),
      #("emailVisibility", json.bool(True)),
    ]),
  )
}

pub type User {
  User(
    avatar: String,
    collection_name: String,
    email: String,
    email_visibility: Bool,
    name: String,
    username: String,
    verified: Bool,
    website: String,
  )
}

fn user_decoder() -> decode.Decoder(User) {
  use avatar <- decode.field("avatar", decode.string)
  use collection_name <- decode.field("collectionName", decode.string)
  use email <- decode.field("email", decode.string)
  use email_visibility <- decode.field("emailVisibility", decode.bool)
  use name <- decode.field("name", decode.string)
  use username <- decode.field("username", decode.string)
  use verified <- decode.field("verified", decode.bool)
  use website <- decode.field("website", decode.string)
  decode.success(User(
    avatar:,
    collection_name:,
    email:,
    email_visibility:,
    name:,
    username:,
    verified:,
    website:,
  ))
}
