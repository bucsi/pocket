import gleam/javascript/promise.{type Promise}

import pocket/internal/ffi/pocketbase
import pocket/types.{type Collection, type DecodeResult, type PocketBase}

// A simple function to create a PocketBase instance and log something
pub fn new(base_url: String) -> PocketBase {
  pocketbase.new(base_url)
}

// A simple function to get a collection from PocketBase
pub fn collection(pb: PocketBase, id_or_name: String) -> Collection {
  pocketbase.collection(pb, id_or_name)
}
