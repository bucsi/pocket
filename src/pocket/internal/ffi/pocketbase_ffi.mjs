import PocketBase from "pocketbase";

/**
 * @typedef {import("pocketbase").default} PocketBase
 * @typedef {ReturnType<import("pocketbase").default["collection"]>} PbCollection
 * @typedef {ReturnType<PbCollection["listAuthMethods"]>} PbListAuthMethods
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
 * @returns {PbListAuthMethods}
 */
export async function pb_list_auth_methods(collection) {
  return await collection.listAuthMethods();
}