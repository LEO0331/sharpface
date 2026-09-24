import { questions } from "@/data/questions";
import { answerStatusLabels, answerStatuses, categoryNames, type AnswerStatus, type Category, type Question } from "@/types/question";
import { filterQuestions as filter, searchQuestions as search, slugify } from "./filters";

export { questions, categoryNames, answerStatusLabels };
export { slugify };
export type { QuestionFilters } from "./filters";

export function getQuestionsByYear(year: number): Question[] { return questions.filter((q) => q.year === year); }
export function getQuestionsByCategory(category: Category): Question[] { return questions.filter((q) => q.category === category); }
export function getQuestionsByTopic(topic: string): Question[] { return questions.filter((q) => slugify(q.topic) === slugify(topic)); }
export function getAvailableYears(): number[] { return [...new Set(questions.flatMap((q) => q.year ? [q.year] : []))].sort((a, b) => b - a); }
export function getTopics(category?: Category): { name: string; slug: string; count: number; category: Category }[] {
  const entries = new Map<string, { name: string; slug: string; count: number; category: Category }>();
  for (const q of questions) {
    if (category && q.category !== category) continue;
    const slug = slugify(q.topic);
    const key = `${q.category}:${slug}`;
    const item = entries.get(key);
    if (item) item.count += 1;
    else entries.set(key, { name: q.topic, slug, count: 1, category: q.category });
  }
  return [...entries.values()].sort((a, b) => a.name.localeCompare(b.name));
}
export function searchQuestions(query: string, source: Question[] = questions): Question[] { return search(query, source); }
export function filterQuestions(filters: import("./filters").QuestionFilters, source: Question[] = questions): Question[] { return filter(filters, source); }
export function getQuestionStats() {
  return {
    total: questions.length,
    years: getAvailableYears(),
    byCategory: Object.fromEntries(Object.keys(categoryNames).map((category) => [category, getQuestionsByCategory(category as Category).length])) as Record<Category, number>,
    byYear: Object.fromEntries(getAvailableYears().map((year) => [year, getQuestionsByYear(year).length])) as Record<number, number>,
    byStatus: Object.fromEntries(answerStatuses.map((status) => [status, questions.filter((q) => q.answerStatus === status).length])) as Record<AnswerStatus, number>,
    requiresFigure: questions.filter((q) => q.requiresFigure).length,
  };
}
export function questionLabel(q: Question): string {
  return q.source.type === "past-exam" && q.year && q.questionNumber ? `${q.year} ${q.questionNumber}` : "Study Question";
}
export function getQuestion(id: string): Question | undefined { return questions.find((q) => q.id === id); }
export function sourceLabel(q: Question): string {
  return q.source.type === "past-exam" ? `${q.source.file}${q.source.page ? `, p. ${q.source.page}` : ""}` : q.source.note ?? "Study question";
}
