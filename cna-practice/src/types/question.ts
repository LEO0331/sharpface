export const categoryNames = {
  "application-layer": "Application Layer",
  "transport-layer": "Transport Layer",
  "network-layer": "Network Layer / IP",
  "link-layer": "Link Layer",
  "security-management": "ICMP / SNMP / Security",
} as const;

export type Category = keyof typeof categoryNames;
export type QuestionType = "concept" | "why" | "comparison" | "calculation" | "true-false" | "scenario" | "protocol-flow" | "algorithm";
export const questionTypes: QuestionType[] = ["concept", "why", "comparison", "calculation", "true-false", "scenario", "protocol-flow", "algorithm"];

// verified: directly supported by the supplied CNA answer notes.
// draft: written from the notes and networking principles; no historical marking answer available.
// needs-review: source, figure, or interpretation is uncertain; the answer text says what to check.
export type AnswerStatus = "verified" | "draft" | "needs-review";
export const answerStatuses: AnswerStatus[] = ["verified", "draft", "needs-review"];
export const answerStatusLabels: Record<AnswerStatus, string> = {
  verified: "Verified against study notes",
  draft: "Draft answer (unofficial)",
  "needs-review": "Needs review",
};

export type PastExamSource = {
  type: "past-exam";
  institution: "University of Adelaide";
  course: "Computer Networks and Applications";
  courseCode: "COMPSCI 3001 / 7039";
  year: number;
  file: string;
  page?: number;
};
// Reserved for original prompts without verified historical wording; labeled "Study Question".
export type StudySource = { type: "study"; note?: string };
export type QuestionSource = PastExamSource | StudySource;

export type Question = {
  id: string;
  year?: number;
  exam?: string;
  questionNumber?: string;
  parentQuestion?: string;
  part?: string;
  category: Category;
  topic: string;
  subtopics?: string[];
  type: QuestionType;
  marks?: number;
  question: string;
  keyConcepts: string[];
  answerApproach: string[];
  answer: string;
  formulas?: string[];
  tags?: string[];
  source: QuestionSource;
  requiresFigure?: boolean;
  figureDescription?: string;
  answerStatus: AnswerStatus;
};
