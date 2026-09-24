"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { filterQuestions, getAvailableYears, getTopics, slugify } from "@/lib/questions";
import { categoryNames, type Category, type QuestionType } from "@/types/question";
import { QuestionCard } from "./QuestionCard";

const types: { value: QuestionType; label: string }[] = [
  { value:"concept", label:"Concept" }, { value:"why", label:"Explain / Why" }, { value:"comparison", label:"Comparison" },
  { value:"calculation", label:"Calculation" }, { value:"true-false", label:"True / False" }, { value:"scenario", label:"Scenario" },
  { value:"protocol-flow", label:"Protocol Flow" }, { value:"algorithm", label:"Algorithm" },
];
export function QuestionBrowser() {
  const params = useSearchParams();
  const router = useRouter();
  const year = params.get("year") ?? "";
  const category = params.get("category") ?? "";
  const topic = params.get("topic") ?? "";
  const type = params.get("type") ?? "";
  const search = params.get("search") ?? "";
  const results = filterQuestions({ year: year ? Number(year) : undefined, category: category as Category || undefined, topic: topic || undefined, type: type as QuestionType || undefined, search });
  const topics = getTopics(category as Category || undefined);
  function update(key: string, value: string) {
    const next = new URLSearchParams(params.toString());
    if (value) next.set(key, value); else next.delete(key);
    if (key === "category") next.delete("topic");
    router.replace(`/questions${next.size ? `?${next.toString()}` : ""}`, { scroll:false });
  }
  return <div className="browser-layout">
    <aside className="panel filters" aria-label="Question filters"><div className="filter-title">Filter questions</div>
      <label className="field"><span>Search</span><input type="search" value={search} onChange={(e) => update("search", e.target.value)} placeholder="e.g. TCP window" /></label>
      <label className="field"><span>Year</span><select value={year} onChange={(e) => update("year", e.target.value)}><option value="">All years</option>{getAvailableYears().map((item) => <option key={item}>{item}</option>)}</select></label>
      <label className="field"><span>Category / Layer</span><select value={category} onChange={(e) => update("category", e.target.value)}><option value="">All categories</option>{Object.entries(categoryNames).map(([value,label]) => <option value={value} key={value}>{label}</option>)}</select></label>
      <label className="field"><span>Topic</span><select value={topic} onChange={(e) => update("topic", e.target.value)}><option value="">All topics</option>{topics.map((item) => <option value={slugify(item.name)} key={`${item.category}:${item.slug}`}>{item.name}</option>)}</select></label>
      <label className="field"><span>Question type</span><select value={type} onChange={(e) => update("type", e.target.value)}><option value="">All types</option>{types.map((item) => <option value={item.value} key={item.value}>{item.label}</option>)}</select></label>
      <button className="button ghost" onClick={() => router.replace("/questions", { scroll:false })}>Clear filters</button>
    </aside>
    <div><div className="results-head"><strong>{results.length} {results.length === 1 ? "question" : "questions"}</strong><span>Answers hidden until opened</span></div>
      {results.length ? <div className="question-list">{results.map((q) => <QuestionCard question={q} key={q.id} />)}</div> : <div className="panel empty">No questions match these filters. Try a broader search.</div>}
    </div>
  </div>;
}
