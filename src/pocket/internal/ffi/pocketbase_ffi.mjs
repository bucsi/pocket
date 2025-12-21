import PocketBase from "pocketbase";

/**
 * @typedef {import("pocketbase").default} PocketBase
 * @typedef {ReturnType<import("pocketbase").default["collection"]>} PbCollection
 */

/**
 * @param {string} baseUrl
 * @returns {PocketBase}
 */
export const pb_new = (baseUrl) => new PocketBase(baseUrl)

/**
 * @param {PocketBase} pb
 * @param {string} idOrName
 * @returns {PbCollection}
 */
export const pb_collection = (pb, idOrName) => pb.collection(idOrName)

/**
 * @param {PbCollection} collection
 */
export async function pb_list_auth_methods(collection) {
  return await collection.listAuthMethods();
}

/**
 * @param {PbCollection} collection
 * @param {string} id
 */
export async function pb_get_one(collection, id) {
  return await collection.getOne(id);
}

/**
 * @param {PbCollection} collection
 */
export async function pb_get_full_list(collection) {
  return await collection.getFullList();
}

/**
 * @param {PbCollection} collection
 */
export async function pb_auth_with_password(collection, user, pass) {
  return await collection.authWithPassword(user, pass);
}

/**
 * @param {PocketBase} pb
 */
export function pb_get_auth_store(pb) {
  const isValid = pb.authStore.isValid
  const token = pb.authStore.token
  const record = pb.authStore.record

  return {isValid, token, record}
}

/**
 * @param {PocketBase} pb
 */
export function pb_get_auth_info(pb) {
  const isValid = pb.authStore.isValid
  const token = pb.authStore.token
  const recordId = pb.authStore.record?.id

  return {isValid, token, recordId}
}
