import gleam/dynamic/decode
import gleam/javascript/promise.{type Promise}

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
