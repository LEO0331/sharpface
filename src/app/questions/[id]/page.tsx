import { notFound } from "next/navigation";
import Link from "next/link";
import { answerStatusLabels, categoryNames, getAdjacentQuestions, getQuestion, getSiblingQuestions, questionLabel, questions, sourceLabel } from "@/lib/questions";
import { QuestionPractice } from "@/components/QuestionPractice";

export function generateStaticParams() { return questions.map((q) => ({ id:q.id })); }
export async function generateMetadata({ params }: { params: Promise<{ id:string }> }) {
  const q = getQuestion((await params).id);
  return { title: q ? `${questionLabel(q)} — ${q.topic}` : "Question" };
}
export default async function QuestionPage({ params }: { params: Promise<{ id:string }> }) {
  const q = getQuestion((await params).id);
  if (!q) notFound();
  const { previous, next } = getAdjacentQuestions(q.id);
  const parts = getSiblingQuestions(q);
  return <div className="container"><div className="page-intro"><Link href="/questions" className="text-link">← Back to questions</Link><div className="eyebrow" style={{marginTop:26}}>Guided practice</div><h1>{questionLabel(q)}</h1></div>
    <div className="detail-grid"><article className="panel question-main"><div className="meta"><span className="pill">{q.source.type === "past-exam" ? "Past Exam Question" : "Study Question"}</span><span>{categoryNames[q.category]}</span><span>· {q.topic}</span>{q.marks && <span>· {q.marks} marks</span>}</div><p className="prompt">{q.question}</p>{q.requiresFigure && <p className="figure-note"><strong>Figure required:</strong> {q.figureDescription ?? "This question refers to a figure in the original paper."}</p>}<p style={{color:"var(--muted)",fontSize:".9rem"}}>Try an answer before revealing the guidance below.</p><QuestionPractice question={q} /></article>
      <aside className="panel sidebar"><strong>Question details</strong><dl><dt>Reference</dt><dd>{questionLabel(q)}</dd><dt>Layer</dt><dd>{categoryNames[q.category]}</dd><dt>Topic</dt><dd><Link className="text-link" href={`/topics/${q.topic.toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/^-|-$/g,"")}`}>{q.topic}</Link></dd><dt>Type</dt><dd>{q.type.replace(/-/g," / ")}</dd><dt>Source</dt><dd>{sourceLabel(q)}</dd><dt>Answer status</dt><dd>{answerStatusLabels[q.answerStatus]}</dd></dl>
        {parts.length > 0 && <><strong>Parts of {q.parentQuestion}</strong><ul className="part-list">{parts.map((part) => <li key={part.id}>{part.id === q.id ? <span className="current">{part.questionNumber} (this question)</span> : <Link className="text-link" href={`/questions/${part.id}`}>{part.questionNumber}</Link>} <span className="part-topic">· {part.topic}</span></li>)}</ul></>}</aside>
    </div>
    <nav className="question-nav" aria-label="Question navigation">{previous ? <Link className="button secondary" href={`/questions/${previous.id}`}>← {questionLabel(previous)}</Link> : <span />}{next && <Link className="button" href={`/questions/${next.id}`}>{questionLabel(next)} →</Link>}</nav></div>;
}
