import test from "node:test";
import assert from "node:assert/strict";
import { shortcutFor } from "../src/lib/shortcuts.ts";

test("letter and arrow keys map to shortcuts", () => {
  assert.equal(shortcutFor({ key:"k" }), "concepts");
  assert.equal(shortcutFor({ key:"A" }), "approach");
  assert.equal(shortcutFor({ key:"f" }), "answer");
  assert.equal(shortcutFor({ key:"ArrowRight" }), "next");
  assert.equal(shortcutFor({ key:"p" }), "previous");
  assert.equal(shortcutFor({ key:"x" }), undefined);
});
test("modified keys and typing in form fields are ignored", () => {
  assert.equal(shortcutFor({ key:"f", ctrlKey:true }), undefined);
  assert.equal(shortcutFor({ key:"r", metaKey:true }), undefined);
  assert.equal(shortcutFor({ key:"k", target:{ tagName:"INPUT" } }), undefined);
  assert.equal(shortcutFor({ key:"n", target:{ tagName:"SELECT" } }), undefined);
  assert.equal(shortcutFor({ key:"b", target:{ tagName:"DIV", isContentEditable:true } }), undefined);
  assert.equal(shortcutFor({ key:"b", target:{ tagName:"BUTTON" } }), "bookmarked");
});
