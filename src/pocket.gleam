import gleam/dynamic/decode
import gleam/javascript/promise.{type Promise}

import pocket/internal/ffi/pocketbase
import pocket/types.{type Collection, type PocketBase}

// A simple function to create a PocketBase instance and log something
pub fn new(base_url: String) -> PocketBase {
  pocketbase.new(base_url)
}

// A simple function to get a collection from PocketBase
pub fn collection(pb: PocketBase, id_or_name: String) -> Collection {
  pocketbase.collection(pb, id_or_name)
}

// Get one record from a collection with decoding
pub fn get_one(
  from collection: Collection,
  id id: String,
  using decoder: decode.Decoder(t),
) -> Promise(types.DecodeResult(t)) {
  collection
  |> pocketbase.get_one(id)
  |> promise.map(decode.run(_, decoder))
}

pub fn get_full_list(
  from collection: Collection,
  using decoder: decode.Decoder(t),
) -> Promise(types.DecodeResult(List(t))) {
  collection
  |> pocketbase.get_full_list()
  |> promise.map(decode.run(_, decode.list(decoder)))
}
