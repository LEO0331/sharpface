import test from "node:test";
import assert from "node:assert/strict";
import { questions, questions2013, questions2014, questions2015 } from "../src/data/questions/index.ts";
import { examYears, validateQuestions } from "../src/lib/validation.ts";
import { answerStatuses, categoryNames, questionTypes } from "../src/types/question.ts";

test("dataset passes validation", () => assert.deepEqual(validateQuestions(questions), []));
test("question IDs are unique", () => assert.equal(new Set(questions.map((q) => q.id)).size, questions.length));
test("years are 2013–2015 and each year file holds only its year", () => {
  assert.ok(questions.every((q) => examYears.includes(q.year)));
  for (const [year, list] of [[2013, questions2013], [2014, questions2014], [2015, questions2015]]) {
    assert.ok(list.length > 0);
    assert.ok(list.every((q) => q.year === year && q.id.startsWith(`${year}-q`)));
  }
});
test("question types, statuses, and categories are valid", () => {
  assert.ok(questions.every((q) => questionTypes.includes(q.type)));
  assert.ok(questions.every((q) => answerStatuses.includes(q.answerStatus)));
  assert.ok(questions.every((q) => q.category in categoryNames));
});
test("required fields are present", () => {
  for (const q of questions) {
    for (const field of ["id", "category", "topic", "type", "question", "answer", "answerStatus", "questionNumber"]) assert.ok(q[field], `${q.id} missing ${field}`);
    assert.ok(q.keyConcepts.length >= 3 && q.keyConcepts.length <= 8, `${q.id} keyConcepts`);
    assert.ok(q.answerApproach.length >= 3 && q.answerApproach.length <= 6, `${q.id} answerApproach`);
  }
});
test("no duplicate question references within a year", () => {
  const refs = questions.map((q) => `${q.year} ${q.questionNumber}`);
  assert.equal(new Set(refs).size, refs.length);
});
test("past-exam source metadata is complete", () => {
  for (const q of questions) {
    assert.equal(q.source.type, "past-exam", q.id);
    assert.equal(q.source.courseCode, "COMPSCI 3001 / 7039");
    assert.equal(q.source.year, q.year);
    assert.ok(q.source.institution && q.source.course && q.source.file && q.source.page > 0, q.id);
  }
});
test("sub-questions are separate records linked to a parent", () => {
  for (const q of questions.filter((item) => item.part)) {
    assert.ok(q.parentQuestion, q.id);
    assert.ok(q.id.endsWith(`-${q.part}`), q.id);
  }
});
test("figure-dependent questions describe the figure", () => {
  assert.ok(questions.filter((q) => q.requiresFigure).every((q) => q.figureDescription));
});
test("each topic belongs to one category", () => {
  const seen = new Map();
  for (const q of questions) {
    assert.equal(seen.get(q.topic) ?? q.category, q.category, q.topic);
    seen.set(q.topic, q.category);
  }
});
test("validator reports broken records", () => {
  const bad = { ...questions[0], id: questions[1].id, type: "essay", answerStatus: "official", category: "physics" };
  const errors = validateQuestions([questions[1], bad]);
  for (const text of ["duplicate id", "invalid type", "invalid answerStatus", "unknown category"]) assert.ok(errors.some((e) => e.includes(text)), text);
});
