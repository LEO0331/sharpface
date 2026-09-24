import test from "node:test";
import assert from "node:assert/strict";
import { filterQuestions, searchQuestions } from "../src/lib/filters.ts";
import { questions } from "../src/data/questions/index.ts";

const sample = [
  { id:"a", year:2013, category:"application-layer", topic:"DNS", type:"concept", question:"How does DNS work?", tags:["lookup"], keyConcepts:["root DNS"] },
  { id:"b", year:2015, category:"transport-layer", topic:"Flow Control", type:"why", question:"Explain TCP receive window", tags:["TCP window"], keyConcepts:["sliding window"] },
  { id:"c", year:2015, category:"link-layer", topic:"ARP", type:"protocol-flow", question:"Describe an ARP request", tags:[], keyConcepts:["broadcast"] },
];

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
