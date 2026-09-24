// Prints dataset counts and exits non-zero if validation fails. Run: npm run stats
import { questions } from "../src/data/questions/index.ts";
import { validateQuestions } from "../src/lib/validation.ts";
import { answerStatuses, categoryNames } from "../src/types/question.ts";

const count = (pick) => questions.reduce((acc, q) => ({ ...acc, [pick(q)]: (acc[pick(q)] ?? 0) + 1 }), {});
const byYear = count((q) => q.year);
const byCategory = count((q) => q.category);
const byStatus = count((q) => q.answerStatus);
const byType = count((q) => q.type);

console.log(`Total records: ${questions.length}`);
console.log("\nBy year:");
for (const [year, n] of Object.entries(byYear)) console.log(`  ${year}: ${n}`);
console.log("\nBy category:");
for (const key of Object.keys(categoryNames)) console.log(`  ${categoryNames[key]}: ${byCategory[key] ?? 0}`);
console.log("\nBy answer status:");
for (const status of answerStatuses) console.log(`  ${status}: ${byStatus[status] ?? 0}`);
console.log("\nBy type:");
for (const [type, n] of Object.entries(byType).sort()) console.log(`  ${type}: ${n}`);
console.log(`\nRequires figure: ${questions.filter((q) => q.requiresFigure).length}`);
console.log(`Topics: ${new Set(questions.map((q) => q.topic)).size}`);

const errors = validateQuestions(questions);
if (errors.length) {
  console.error(`\n${errors.length} validation error(s):`);
  for (const error of errors) console.error(`  - ${error}`);
  process.exit(1);
}
console.log("\nValidation: OK");
