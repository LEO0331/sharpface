"use client";

import { useEffect, useState } from "react";
import { readProgress, saveProgress, type Progress } from "@/lib/progress";
import { answerStatusLabels, type Question } from "@/types/question";

export function QuestionPractice({ question: q }: { question: Question }) {
  const [concepts, setConcepts] = useState(false);
  const [approach, setApproach] = useState(false);
  const [answer, setAnswer] = useState(false);
  const [progress, setProgress] = useState<Progress>({ reviewed: [], bookmarked: [] });
  useEffect(() => {
    const current = readProgress();
    const next = { ...current, lastViewed: q.id };
    setProgress(next);
    saveProgress(next);
    setConcepts(false); setApproach(false); setAnswer(false);
  }, [q.id]);
  function toggle(field: "reviewed" | "bookmarked") {
    const next = { ...progress, [field]: progress[field].includes(q.id) ? progress[field].filter((id) => id !== q.id) : [...progress[field], q.id] };
    setProgress(next); saveProgress(next);
  }
  return <>
    <div className="actions"><button className="button secondary" aria-expanded={concepts} onClick={() => setConcepts(!concepts)}>{concepts ? "Hide" : "Show"} Key Concepts</button><button className="button secondary" aria-expanded={approach} onClick={() => setApproach(!approach)}>{approach ? "Hide" : "Show"} Answer Approach</button><button className="button" aria-expanded={answer} onClick={() => setAnswer(!answer)}>{answer ? "Hide" : "Show"} Answer</button></div>
    {concepts && <section className="reveal"><h3>Key Concepts</h3><ul>{q.keyConcepts.map((item) => <li key={item}>{item}</li>)}</ul></section>}
    {approach && <section className="reveal"><h3>Answer Approach</h3><ol>{q.answerApproach.map((item) => <li key={item}>{item}</li>)}</ol></section>}
    {answer && <section className="reveal"><h3>Full Answer</h3><p className="answer-status">Answer status: {answerStatusLabels[q.answerStatus]}. Revision notes, not an official marking scheme.</p><p>{q.answer}</p>{q.formulas?.map((formula) => <code className="formula" key={formula}>{formula}</code>)}</section>}
    <hr className="divider" />
    <div className="actions"><button className="button ghost" aria-pressed={progress.reviewed.includes(q.id)} onClick={() => toggle("reviewed")}>{progress.reviewed.includes(q.id) ? "✓ Reviewed" : "Mark as Reviewed"}</button><button className="button ghost" aria-pressed={progress.bookmarked.includes(q.id)} onClick={() => toggle("bookmarked")}>{progress.bookmarked.includes(q.id) ? "★ Bookmarked" : "☆ Bookmark"}</button></div>
  </>;
}
