import Link from "next/link";
import { notFound } from "next/navigation";
import { categoryNames, getQuestionsByCategory, getTopics } from "@/lib/questions";
import type { Category } from "@/types/question";
import { QuestionCard } from "@/components/QuestionCard";

export function generateStaticParams() { return Object.keys(categoryNames).map((slug) => ({ slug })); }
export default async function CategoryPage({ params }: { params: Promise<{ slug:string }> }) {
  const slug = (await params).slug as Category;
  if (!(slug in categoryNames)) notFound();
  const items = getQuestionsByCategory(slug);
  return <div className="container"><div className="page-intro"><Link className="text-link" href="/">← Home</Link><div className="eyebrow" style={{marginTop:26}}>Subject area</div><h1>{categoryNames[slug]}</h1><p className="lead">{items.length} questions · {getTopics(slug).length} topics</p></div><div className="question-list" style={{paddingBottom:50}}>{items.map((q) => <QuestionCard question={q} key={q.id} />)}</div></div>;
}
