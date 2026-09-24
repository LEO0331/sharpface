import Link from "next/link";
import { categoryNames, questionLabel } from "@/lib/questions";
import type { Question } from "@/types/question";

export function QuestionCard({ question: q }: { question: Question }) {
  return <Link href={`/questions/${q.id}`} className="question-card">
    <div className="meta"><span className="pill">{questionLabel(q)}</span><span>{categoryNames[q.category]}</span><span aria-hidden="true">·</span><span>{q.topic}</span>{q.marks && <span>· {q.marks} marks</span>}</div>
    <h3>{q.question}</h3>
    {!!q.tags?.length && <div className="tags">{q.tags.slice(0, 4).map((tag) => <span className="tag" key={tag}>{tag}</span>)}</div>}
    <span className="open">Open question →</span>
  </Link>;
}
