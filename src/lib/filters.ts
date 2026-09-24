import type { AnswerStatus, Category, Question, QuestionType } from "../types/question";

export type QuestionFilters = { year?: number; category?: Category; topic?: string; type?: QuestionType; status?: AnswerStatus; search?: string };
export type ProgressFilter = "bookmarked" | "reviewed" | "not-reviewed";
export const progressFilters: { value: ProgressFilter; label: string }[] = [
  { value: "bookmarked", label: "Bookmarked" }, { value: "reviewed", label: "Reviewed" }, { value: "not-reviewed", label: "Not reviewed yet" },
];

export function slugify(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}
export function searchQuestions(query: string, source: Question[]): Question[] {
  const terms = query.toLowerCase().trim().split(/\s+/).filter(Boolean);
  if (!terms.length) return source;
  return source.filter((q) => {
    const haystack = [q.question, q.topic, q.category.replace(/-/g, " "), ...(q.tags ?? []), ...q.keyConcepts, ...(q.subtopics ?? [])].join(" ").toLowerCase();
    return terms.every((term) => haystack.includes(term));
  });
}
export function filterQuestions(filters: QuestionFilters, source: Question[]): Question[] {
  const filtered = source.filter((q) =>
    (!filters.year || q.year === filters.year) &&
    (!filters.category || q.category === filters.category) &&
    (!filters.topic || slugify(q.topic) === slugify(filters.topic)) &&
    (!filters.type || q.type === filters.type) &&
    (!filters.status || q.answerStatus === filters.status)
  );
  return filters.search ? searchQuestions(filters.search, filtered) : filtered;
}
export function filterByProgress(source: Question[], mode: ProgressFilter | undefined, progress: { reviewed: string[]; bookmarked: string[] }): Question[] {
  if (mode === "bookmarked") return source.filter((q) => progress.bookmarked.includes(q.id));
  if (mode === "reviewed") return source.filter((q) => progress.reviewed.includes(q.id));
  if (mode === "not-reviewed") return source.filter((q) => !progress.reviewed.includes(q.id));
  return source;
}
// Neighbours in dataset order (year, then question number).
export function adjacentQuestions(id: string, source: Question[]): { previous?: Question; next?: Question } {
  const index = source.findIndex((q) => q.id === id);
  return index < 0 ? {} : { previous: source[index - 1], next: source[index + 1] };
}
// All parts sharing a parent question, in order; empty when the question stands alone.
export function siblingQuestions(q: Question, source: Question[]): Question[] {
  if (!q.parentQuestion) return [];
  const parts = source.filter((item) => item.parentQuestion === q.parentQuestion);
  return parts.length > 1 ? parts : [];
}
