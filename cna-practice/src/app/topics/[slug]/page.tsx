import Link from "next/link";
import { notFound } from "next/navigation";
import { getQuestionsByTopic, getTopics } from "@/lib/questions";
import { QuestionCard } from "@/components/QuestionCard";

export function generateStaticParams() { return [...new Set(getTopics().map((t) => t.slug))].map((slug) => ({ slug })); }
export default async function TopicPage({ params }: { params: Promise<{ slug:string }> }) {
  const slug = (await params).slug;
  const items = getQuestionsByTopic(slug);
  if (!items.length) notFound();
  return <div className="container"><div className="page-intro"><Link className="text-link" href="/topics">← All topics</Link><div className="eyebrow" style={{marginTop:26}}>Topic</div><h1>{items[0].topic}</h1><p className="lead">{items.length} {items.length === 1 ? "question" : "questions"} in this topic.</p></div><div className="question-list" style={{paddingBottom:50}}>{items.map((q) => <QuestionCard question={q} key={q.id} />)}</div></div>;
}
