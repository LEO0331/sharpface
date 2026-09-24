import test from "node:test";
import assert from "node:assert/strict";
import { progressSummary } from "../src/lib/progress.ts";

test("progress summary counts only known questions", () => {
  const summary = progressSummary({ reviewed:["a","b","gone","a"], bookmarked:["c"], lastViewed:"b" }, ["a","b","c"]);
  assert.deepEqual(summary, { reviewed:2, bookmarked:1, total:3, lastViewed:"b" });
});
test("progress summary drops a last viewed question that no longer exists", () => {
  assert.equal(progressSummary({ reviewed:[], bookmarked:[], lastViewed:"gone" }, ["a"]).lastViewed, undefined);
});
