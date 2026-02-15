import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/option
import gleam/result

import pocket/internal/ffi/pocketbase
import pocket/types.{type Collection, type PocketBase}

/// Creates a new PocketBase client.
pub fn new(base_url: String) -> PocketBase {
  pocketbase.new(base_url)
}

/// Gets a collection reference by name.
pub fn collection(pb: PocketBase, name: String) -> Collection {
  pocketbase.collection(pb, name)
}

/// Calls [getOne](https://pocketbase.io/docs/api-records/#view-record) and decodes the result using the provided decoder.
/// ```gleam
/// pocket.new("https://pocketbase.io")
///    |> pocket.collection("posts")
///    |> pocket.get_one(post_decoder())
/// ```
pub fn get_one(
  from collection: Collection,
  id id: String,
  using decoder: decode.Decoder(t),
) -> Promise(types.DecodeResult(t)) {
  collection
  |> pocketbase.get_one(id)
  |> promise.map(decode.run(_, decoder))
}

/// Calls [getFullList](https://pocketbase.io/docs/api-records/#listsearch-records:~:text=.getFullList) and decodes results using the provided decoder.
/// ```gleam
/// pocket.new("https://pocketbase.io")
///    |> pocket.collection("posts")
///    |> pocket.get_full_list(post_decoder())
/// ```
pub fn get_full_list(
  from collection: Collection,
  using decoder: decode.Decoder(t),
) -> Promise(types.DecodeResult(List(t))) {
  collection
  |> pocketbase.get_full_list()
  |> promise.map(decode.run(_, decode.list(decoder)))
}

/// Calls [create](https://pocketbase.io/docs/api-records/#create-record).
/// ```gleam
/// pocket.new("https://pocketbase.io")
///    |> pocket.collection("posts")
///    |> pocket.create(post |> post_to_json, posts_decoder())
/// ```
pub fn create(
  in collection: Collection,
  encoded_data json: json.Json,
  using decoder: decode.Decoder(t),
) -> Promise(Result(t, CreateError)) {
  collection
  |> pocketbase.create(json)
  |> promise.map(decode(_, decoder))
  |> promise.rescue(parse_create_error)
}

fn decode(dyn: dynamic.Dynamic, decoder: decode.Decoder(t)) -> Result(t, CreateError) {
  decode.run(dyn, decoder) |> result.map_error(ValueDecodeError)
}

fn parse_create_error(dyn: dynamic.Dynamic) -> Result(a, CreateError) {
  case decode.run(dyn, create_response_error_decoder()) {
    Ok(error_descriptor) -> Error(error_descriptor)
    Error(decode_errors) -> Error(ErrorDecodeError(decode_errors))
  }
}

pub type CreateError {
  ValueDecodeError(errors: List(decode.DecodeError))
  ErrorDecodeError(errors: List(decode.DecodeError))
  ClientResponseError(
    url: String,
    status: Int,
    excuses: List(Excuse),
    is_abort: option.Option(Bool),
  )
}

fn create_response_error_decoder() -> decode.Decoder(CreateError) {
  use url <- decode.field("url", decode.string)
  use status <- decode.field("status", decode.int)
  use excuses_dict <- decode.subfield(
    ["response", "data"],
    decode.dict(decode.string, decode.dynamic),
  )
  use is_abort <- decode.field("isAbort", decode.optional(decode.bool))
  case excuses_dict |> excuse_dict_to_types {
    Ok(excuses) -> ClientResponseError(url:, status:, excuses:, is_abort:)
    Error(errors) -> ErrorDecodeError(errors)
  }
  |> decode.success
}

pub type Excuse {
  Excuse(key: String, message: String, code: String)
}

fn excuse_dict_to_types(
  dict: dict.Dict(String, dynamic.Dynamic)
) -> Result(List(Excuse), List(decode.DecodeError)) {
  dict
  |> dict.to_list
  |> list.map(fn(kvp) {
      let #(key, value) = kvp
      decode.run(value, {
        use message <- decode.field("message", decode.string)
        use code <- decode.field("code", decode.string)
        decode.success(Excuse(key:, message:, code:))
      })
    })
    |> result.partition
    |> fn(partitions) {
      let #(oks, errors) = partitions
      case errors {
        [] -> Ok(oks)
        errors -> Error(errors |> list.flatten)
      }
    }
  }

