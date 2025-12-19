import gleam/dynamic.{type Dynamic}
import gleam/javascript/promise.{type Promise}

import pocket/types.{type Collection, type PocketBase}

@external(javascript, "./pocketbase_ffi.mjs", "pb_new")
@internal
pub fn new(base_url: String) -> PocketBase

@external(javascript, "./pocketbase_ffi.mjs", "pb_collection")
@internal
pub fn collection(pb: PocketBase, id_or_name: String) -> Collection

@external(javascript, "./pocketbase_ffi.mjs", "pb_list_auth_methods")
@internal
pub fn list_auth_methods(col: Collection) -> Promise(Dynamic)
