import gleam/dynamic.{type Dynamic}
import gleam/javascript/promise.{type Promise}

import pocket/types.{type Collection, type PocketBase}

@external(javascript, "./pocketbase_ffi.mjs", "pb_new")
pub fn new(base_url: String) -> PocketBase

@external(javascript, "./pocketbase_ffi.mjs", "pb_collection")
pub fn collection(pb: PocketBase, id_or_name: String) -> Collection

@external(javascript, "./pocketbase_ffi.mjs", "pb_list_auth_methods")
pub fn list_auth_methods(col: Collection) -> Promise(Dynamic)

@external(javascript, "./pocketbase_ffi.mjs", "pb_get_one")
pub fn get_one(col: Collection, id: String) -> Promise(Dynamic)

@external(javascript, "./pocketbase_ffi.mjs", "pb_get_full_list")
pub fn get_full_list(col: Collection) -> Promise(Dynamic)
