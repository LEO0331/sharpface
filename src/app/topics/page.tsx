import Link from "next/link";
import { categoryNames, getTopics } from "@/lib/questions";
import type { Category } from "@/types/question";

export const metadata = { title:"Topics" };
export default function TopicsPage() { return <div className="container"><div className="page-intro"><div className="eyebrow">Study index</div><h1>Topics</h1><p className="lead">Topic counts come directly from the question collection.</p></div><div className="topic-groups">{(Object.entries(categoryNames) as [Category,string][]).map(([id,name]) => <section className="panel topic-group" key={id}><div className="section-heading"><h2>{name}</h2><Link className="text-link" href={`/categories/${id}`}>View layer →</Link></div><div className="topic-links">{getTopics(id).map((topic) => <Link href={`/topics/${topic.slug}`} key={topic.slug}><span>{topic.name}</span><small>{topic.count} {topic.count === 1 ? "question" : "questions"}</small></Link>)}</div></section>)}</div></div>; }
