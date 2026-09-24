import Link from "next/link";
import { categoryNames, getQuestionStats } from "@/lib/questions";
import type { Category } from "@/types/question";

export default function Home() {
  const stats = getQuestionStats();
  return <>
    <section className="hero"><div className="container hero-grid"><div>
      <div className="eyebrow">Computer Networks and Applications</div>
      <h1>Study the question.<br />Then study the answer.</h1>
      <p className="lead">CNA Practice is a structured collection of University of Adelaide Computer Networks and Applications past exam questions and revision notes.</p>
      <p className="lead">The initial collection focuses on 2013–2015 historical material, with guided recall and answer approaches for each question.</p>
      <div className="actions"><Link className="button" href="/practice">Practice All →</Link><Link className="button secondary" href="/questions">Browse Questions</Link></div>
    </div><aside className="hero-note"><strong>{stats.total} questions</strong><span>Across {stats.years.join(", ")} and focused study topics. Historical wording is identified separately from Study Questions.</span></aside></div></section>
    <div className="container"><section className="section"><div className="section-heading"><h2>Explore by layer</h2><Link className="text-link" href="/topics">All topics →</Link></div>
      <div className="category-grid">{(Object.entries(categoryNames) as [Category,string][]).map(([id, name], index) => <Link className="category-card" href={`/categories/${id}`} key={id}><div className="number">0{index + 1}</div><div><h3>{name}</h3><span className="count">{stats.byCategory[id]} questions →</span></div></Link>)}</div>
    </section><div className="stat-strip"><div><strong>{stats.total}</strong><span>Total questions</span></div><div><strong>{stats.years.length}</strong><span>Available years</span></div><div><strong>5</strong><span>Subject areas</span></div></div>
    <section className="section"><h2>How to use this collection</h2><p className="lead">Read a question first. Reveal key concepts when you need a nudge, then the answer approach. Open the full answer only after you have tried your own response.</p><div className="actions"><Link className="button secondary" href="/about">About the sources</Link><Link className="text-link" href="/about#links">GitHub: Coming Soon</Link></div></section></div>
  </>;
}
