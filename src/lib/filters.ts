import type { Category, Question, QuestionType } from "../types/question";

export type QuestionFilters = { year?: number; category?: Category; topic?: string; type?: QuestionType; search?: string };

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
    (!filters.type || q.type === filters.type)
  );
  return filters.search ? searchQuestions(filters.search, filtered) : filtered;
}
