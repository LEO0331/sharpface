# CNA Practice

CNA Practice is an independent study app for University of Adelaide Computer Networks and Applications historical exam questions and revision notes. The collection contains every recoverable question and sub-question from the 2013, 2014, and 2015 Semester 1 primary exam papers supplied with this project. Run `npm run stats` for current counts.

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
npm run stats   # dataset counts + validation (also runs before build)
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

`src/types/question.ts` defines the `Question`, `QuestionType`, `AnswerStatus`, and `QuestionSource` contracts. Question records live in one file per exam year:

```
src/data/questions/
  2013.ts   2014.ts   2015.ts   # questions2013 / questions2014 / questions2015
  source.ts                     # examSource(year, page) and exam file names
  index.ts                      # exports the combined `questions` array
```

`src/lib/validation.ts` holds the pure `validateQuestions()` checks used by the tests and by `scripts/dataset-report.mjs`. `src/lib/filters.ts` contains reusable pure search and filter functions; `src/lib/questions.ts` provides data-derived queries and counts. `src/lib/progress.ts` handles local progress state. UI components live in `src/components`.

## Dataset

Each exam sub-question is its own record with a deterministic ID (`2015-q2-d-i` = 2015, Question 2(d)(i)), plus `parentQuestion` and `part` linking it to its parent. Sub-question records repeat the shared stem so each page stands alone.

- **Question text** is transcribed from the PDF. Only line-wrap hyphenation and layout are fixed; historical typos (e.g. “Subnect”, “occured”) are kept. Handwritten student annotations on the scans are excluded.
- **category** is one of `application-layer`, `transport-layer`, `network-layer`, `link-layer`, `security-management`. Each topic (e.g. “Congestion Control”, “TCP Connection”) belongs to exactly one category.
- **type** is one of `concept`, `why`, `comparison`, `calculation`, `true-false`, `scenario`, `protocol-flow`, `algorithm`.
- **keyConcepts** (3–8 cues), **answerApproach** (3–6 guiding steps), **answer**, and optional **formulas** are revision notes written for this app, not official marking schemes.
- **answerStatus**: `verified` — directly supported by the supplied 2017 student study notes; `draft` — written from networking principles with no historical answer available; `needs-review` — the wording, figure, or interpretation is uncertain. Items needing attention are listed in [`docs/dataset-review.md`](docs/dataset-review.md).
- **requiresFigure** / **figureDescription** mark questions that depend on a figure in the paper and give a text transcription of it.

Example record:

```ts
{
  id: '2015-q2-d-iii', year: 2015, exam: 'Primary Examination, Semester 1',
  questionNumber: 'Q2(d)(iii)', parentQuestion: '2015 Q2(d)', part: 'iii',
  category: 'transport-layer', topic: 'Reliable Transport',
  subtopics: ['Alternating Bit', 'Go-Back-N', 'Selective Repeat', 'Sequence numbers'],
  type: 'concept', marks: 3,
  question: 'We looked at three protocols for providing reliable transport: Alternating Bit, Go-Back-N and Selective-Repeat.

Given a window size, W , what is the minimum sequence space required for each of these protocols?',
  keyConcepts: ['Sequence number wrap-around', 'W + 1 for GBN', '2W for SR', '1 bit for Alternating Bit'],
  answerApproach: ['Alternating Bit has a window of 1: how many numbers distinguish new from duplicate?', 'For GBN, consider a full window sent and all ACKs lost.', 'For SR, the sender and receiver windows must not overlap.'],
  answer: 'Alternating Bit: 2 sequence numbers (0 and 1). Go-Back-N: W + 1. Selective Repeat: 2W (the window can be at most half the sequence space).',
  formulas: ['AB: 2', 'GBN: ≥ W + 1', 'SR: ≥ 2W'],
  source: {
    type: 'past-exam', institution: 'University of Adelaide',
    course: 'Computer Networks and Applications', courseCode: 'COMPSCI 3001 / 7039',
    year: 2015, file: 'CNA-2015-s1-MAIN.pdf', page: 4,
  },
  answerStatus: 'draft',
}
```

In the year files, `source` is written as `examSource(2015, 4)`.

## Add a question or year

1. Open the source PDF and verify exact wording, marks, year, question reference, and page.
2. Add one record per sub-question to the year file (`src/data/questions/<year>.ts`, created from an existing one and added to `index.ts`). Use `examSource(year, page)`, and add the file name to `examFiles` in `source.ts`.
3. Write separate `keyConcepts`, `answerApproach`, and `answer` fields. Set `answerStatus` honestly, and add a `docs/dataset-review.md` entry for anything uncertain.
4. Run `npm run stats`, lint, typecheck, tests, and build. Years, topics, category counts, routes, and filters update from data automatically. (To add years outside 2013–2015, update `examYears` in `src/lib/validation.ts`.)

## Future roadmap

The typed data boundary allows a later JSON, CMS, or database import without changing page components. Possible later work includes more years, accounts and cloud sync, answer submission, AI explanation, random quizzes, spaced repetition, difficulty and statistics, import tools, a content editor, Markdown answers, and mathematical notation. These are outside this v1.
