export const categoryNames = {
  "application-layer": "Application Layer",
  "transport-layer": "Transport Layer",
  "network-layer": "Network Layer / IP",
  "link-layer": "Link Layer",
  "security-management": "ICMP / SNMP / Security",
} as const;

export type Category = keyof typeof categoryNames;
export type QuestionType = "concept" | "why" | "comparison" | "calculation" | "true-false" | "scenario" | "protocol-flow" | "algorithm";
export type Question = {
  id: string;
  year?: number;
  exam?: string;
  questionNumber?: string;
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
  source?: string;
  sourceKind: "past-exam" | "study";
};
