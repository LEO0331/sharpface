import test from "node:test";
import assert from "node:assert/strict";
import { adjacentQuestions, filterByProgress, filterQuestions, searchQuestions, siblingQuestions } from "../src/lib/filters.ts";
import { questions } from "../src/data/questions/index.ts";

const sample = [
  { id:"a", year:2013, category:"application-layer", topic:"DNS", type:"concept", question:"How does DNS work?", tags:["lookup"], keyConcepts:["root DNS"], answerStatus:"verified", parentQuestion:"2013 Q1" },
  { id:"b", year:2015, category:"transport-layer", topic:"Flow Control", type:"why", question:"Explain TCP receive window", tags:["TCP window"], keyConcepts:["sliding window"], answerStatus:"draft", parentQuestion:"2015 Q2" },
  { id:"c", year:2015, category:"link-layer", topic:"ARP", type:"protocol-flow", question:"Describe an ARP request", tags:[], keyConcepts:["broadcast"], answerStatus:"draft", parentQuestion:"2015 Q2" },
];

test("filter by answer status", () => assert.deepEqual(filterQuestions({status:"draft"}, sample).map((q) => q.id), ["b","c"]));
test("filter by local progress", () => {
  const progress = { reviewed:["a"], bookmarked:["c"] };
  assert.deepEqual(filterByProgress(sample, "bookmarked", progress).map((q) => q.id), ["c"]);
  assert.deepEqual(filterByProgress(sample, "reviewed", progress).map((q) => q.id), ["a"]);
  assert.deepEqual(filterByProgress(sample, "not-reviewed", progress).map((q) => q.id), ["b","c"]);
  assert.equal(filterByProgress(sample, undefined, progress).length, 3);
});
test("previous and next follow dataset order", () => {
  assert.deepEqual([adjacentQuestions("b", sample).previous?.id, adjacentQuestions("b", sample).next?.id], ["a","c"]);
  assert.equal(adjacentQuestions("a", sample).previous, undefined);
  assert.equal(adjacentQuestions("c", sample).next, undefined);
});
test("sibling parts share a parent question", () => {
  assert.deepEqual(siblingQuestions(sample[1], sample).map((q) => q.id), ["b","c"]);
  assert.deepEqual(siblingQuestions(sample[0], sample), []);
});

test("filter by year", () => assert.deepEqual(filterQuestions({year:2015}, sample).map((q) => q.id), ["b","c"]));
test("filter by category", () => assert.deepEqual(filterQuestions({category:"transport-layer"}, sample).map((q) => q.id), ["b"]));
test("filter by topic", () => assert.deepEqual(filterQuestions({topic:"flow-control"}, sample).map((q) => q.id), ["b"]));
test("search question text, tags, and concepts without case sensitivity", () => {
  assert.deepEqual(searchQuestions("TCP window", sample).map((q) => q.id), ["b"]);
  assert.deepEqual(searchQuestions("ROOT dns", sample).map((q) => q.id), ["a"]);
});
test("question IDs are unique and source-labeled", () => {
  assert.equal(new Set(questions.map((q) => q.id)).size, questions.length);
  assert.ok(questions.length >= 20);
  assert.ok(questions.every((q) => q.source.type === "study" || (q.source.type === "past-exam" && q.year && q.questionNumber && q.source.file)));
});
