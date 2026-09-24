"use client";

import { useEffect, useMemo, useState } from "react";
import { categoryNames, filterQuestions, getAvailableYears, getTopics, questionLabel, slugify } from "@/lib/questions";
import { readProgress } from "@/lib/progress";
import type { Category } from "@/types/question";
import { QuestionPractice } from "./QuestionPractice";

export function PracticeSession() {
  const [year, setYear] = useState("");
  const [category, setCategory] = useState("");
  const [topic, setTopic] = useState("");
  const [count, setCount] = useState("10");
  const [sessionIds, setSessionIds] = useState<string[]>([]);
  const [index, setIndex] = useState(0);
  const [lastViewed, setLastViewed] = useState<string>();
  useEffect(() => { setLastViewed(readProgress().lastViewed); }, []);
  const available = useMemo(() => filterQuestions({ year:year ? Number(year) : undefined, category:category as Category || undefined, topic:topic || undefined }), [year,category,topic]);
  const session = useMemo(() => sessionIds.map((id) => available.find((q) => q.id === id)).filter((q) => !!q), [sessionIds,available]);
  const current = session[index];
  function start() { setSessionIds(available.slice(0, Math.min(Number(count), available.length)).map((q) => q.id)); setIndex(0); }
  function reset() { setSessionIds([]); setIndex(0); }
  if (sessionIds.length && current) return <div>
    <div className="practice-top"><strong>Question {index + 1} / {session.length}</strong><button className="button ghost" onClick={reset}>Change session</button></div>
    <article className="panel question-main"><div className="meta"><span className="pill">{questionLabel(current)}</span><span>{categoryNames[current.category]}</span><span>· {current.topic}</span>{current.marks && <span>· {current.marks} marks</span>}</div><p className="prompt">{current.question}</p><QuestionPractice question={current} /></article>
    <div className="actions" style={{justifyContent:"space-between", marginBottom:50}}><button className="button secondary" disabled={index === 0} onClick={() => setIndex(index - 1)}>← Previous</button><button className="button" disabled={index >= session.length - 1} onClick={() => setIndex(index + 1)}>Next →</button></div>
  </div>;
  return <div className="panel practice-config"><h2>Set up a session</h2><p>Choose a focus, then work through questions one at a time. Your reviewed and bookmarked questions are saved on this device.</p>
    <div className="practice-config-grid">
      <label className="field"><span>Year</span><select value={year} onChange={(e) => setYear(e.target.value)}><option value="">All years</option>{getAvailableYears().map((value) => <option key={value}>{value}</option>)}</select></label>
      <label className="field"><span>Layer</span><select value={category} onChange={(e) => { setCategory(e.target.value); setTopic(""); }}><option value="">All layers</option>{Object.entries(categoryNames).map(([value,label]) => <option value={value} key={value}>{label}</option>)}</select></label>
      <label className="field"><span>Topic</span><select value={topic} onChange={(e) => setTopic(e.target.value)}><option value="">All topics</option>{getTopics(category as Category || undefined).map((item) => <option value={slugify(item.name)} key={`${item.category}:${item.slug}`}>{item.name}</option>)}</select></label>
      <label className="field"><span>Number of questions</span><select value={count} onChange={(e) => setCount(e.target.value)}>{[5,10,15,20,30].map((value) => <option value={value} key={value}>{value}</option>)}</select></label>
    </div><p><strong>{available.length}</strong> questions available with these settings.</p>
    <button className="button" disabled={!available.length} onClick={start}>Start practice →</button>
    {lastViewed && <p style={{fontSize:".85rem",marginTop:22}}>Last viewed: <a className="text-link" href={`/questions/${lastViewed}`}>return to question</a></p>}
  </div>;
}
