# CNA Practice

CNA Practice is an independent study app for University of Adelaide Computer Networks and Applications historical exam questions and revision notes. The starter collection contains 30 questions from the 2013–2015 Semester 1 main papers supplied with this project.

The app keeps past exam wording separate from original study guidance. It is intended for study and revision; historical questions and notes may not reflect the current University of Adelaide CNA syllabus, assessment format, or official answers.

## Technology

- Next.js App Router, React, strict TypeScript, Tailwind CSS
- Local typed question data; no account or database
- Browser `localStorage` for reviewed, bookmarked, and last viewed progress

## Run locally

```bash
cd cna-practice
npm install
npm run dev
```

Open <http://localhost:3000>. Verification commands:

```bash
npm run lint
npm run typecheck
npm test
npm run build
```

## Pages

- `/` — collection overview and category links
- `/questions` — searchable library with shareable year, category, topic, and type filters
- `/questions/[id]` — question and separate Key Concepts, Answer Approach, and Full Answer reveals
- `/practice` — configurable one-question-at-a-time practice with local progress
- `/topics` and `/topics/[slug]` — data-derived topic counts and listings
- `/categories/[slug]` — data-derived category listings
- `/about` — source labeling and disclaimer

## Data structure

`src/types/question.ts` defines the `Question` and `QuestionType` contracts. `src/data/questions.ts` holds the initial records. `src/lib/filters.ts` contains reusable pure search and filter functions; `src/lib/questions.ts` provides data-derived queries and counts. `src/lib/progress.ts` handles local progress state. UI components live in `src/components`.

Each `past-exam` record includes a year, original question reference, and source PDF/page. Key concepts, answer approaches, and full answers are original revision notes. An additional representative item without verified historical wording must use `sourceKind: 'study'`, omit any invented exam reference, and be labeled Study Question in the UI.

Example record:

```ts
{
  id: "study-dns-cache",
  category: "application-layer",
  topic: "DNS",
  type: "why",
  question: "Study Question: Why can DNS caching reduce lookup delay?",
  keyConcepts: ["TTL", "cache hit", "resolver"],
  answerApproach: ["Compare local cache hits with full iterative lookups."],
  answer: "A valid cached record can answer a repeated query without contacting the DNS hierarchy again.",
  sourceKind: "study",
}
```

## Add a question or year

1. Open the source document and verify exact wording, marks, year, and question reference. Record the PDF filename and page in `source`.
2. Add a unique, readable `id` and a typed object to `src/data/questions.ts`. Add the year only when the source supports it.
3. Write separate `keyConcepts`, `answerApproach`, and `answer` fields. Label unverified or newly written wording as `study`.
4. Run lint, typecheck, tests, and build. Years, topics, category counts, routes, and filters update from data automatically.

The recommended next import step is to create a small extraction and review sheet for every 2013–2015 exam item, including page, question reference, marks, exact wording, answer confidence, and a second-person source check. Then add the reviewed records to `src/data/questions.ts` in batches.

## Future roadmap

The typed data boundary allows a later JSON, CMS, or database import without changing page components. Possible later work includes more years, accounts and cloud sync, answer submission, AI explanation, random quizzes, spaced repetition, difficulty and statistics, import tools, a content editor, Markdown answers, and mathematical notation. These are outside this v1.
