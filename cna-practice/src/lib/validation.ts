import { answerStatuses, categoryNames, questionTypes, type Question } from "../types/question.ts";

export const examYears = [2013, 2014, 2015];

// Returns human-readable problems; an empty list means the dataset is valid.
export function validateQuestions(questions: Question[]): string[] {
  const errors: string[] = [];
  const ids = new Set<string>();
  const refs = new Set<string>();
  const topicCategory = new Map<string, string>();

  for (const q of questions) {
    const at = q.id || "(missing id)";
    if (ids.has(q.id)) errors.push(`${at}: duplicate id`);
    ids.add(q.id);

    for (const field of ["id", "topic", "question", "answer"] as const) {
      if (typeof q[field] !== "string" || !q[field].trim()) errors.push(`${at}: missing ${field}`);
    }
    if (!(q.category in categoryNames)) errors.push(`${at}: unknown category "${q.category}"`);
    if (!questionTypes.includes(q.type)) errors.push(`${at}: invalid type "${q.type}"`);
    if (!answerStatuses.includes(q.answerStatus)) errors.push(`${at}: invalid answerStatus "${q.answerStatus}"`);
    if (!Array.isArray(q.keyConcepts) || q.keyConcepts.length < 3 || q.keyConcepts.length > 8) errors.push(`${at}: keyConcepts must have 3–8 items`);
    if (!Array.isArray(q.answerApproach) || q.answerApproach.length < 3 || q.answerApproach.length > 6) errors.push(`${at}: answerApproach must have 3–6 items`);
    if (q.requiresFigure && !q.figureDescription?.trim()) errors.push(`${at}: requiresFigure without figureDescription`);

    const known = topicCategory.get(q.topic);
    if (known && known !== q.category) errors.push(`${at}: topic "${q.topic}" used in both ${known} and ${q.category}`);
    topicCategory.set(q.topic, q.category);

    if (q.source?.type === "past-exam") {
      const s = q.source;
      if (!s.institution || !s.course || !s.courseCode || !s.file) errors.push(`${at}: incomplete past-exam source`);
      if (!q.year || !examYears.includes(q.year)) errors.push(`${at}: year must be one of ${examYears.join(", ")}`);
      if (s.year !== q.year) errors.push(`${at}: source year does not match year`);
      if (!q.questionNumber) errors.push(`${at}: missing questionNumber`);
      if (!q.id.startsWith(`${q.year}-`)) errors.push(`${at}: id must start with its year`);
      const ref = `${q.year} ${q.questionNumber}`;
      if (refs.has(ref)) errors.push(`${at}: duplicate question reference ${ref}`);
      refs.add(ref);
    } else if (q.source?.type !== "study") {
      errors.push(`${at}: missing source`);
    }
  }
  return errors;
}
