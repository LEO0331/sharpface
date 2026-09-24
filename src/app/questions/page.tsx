import { Suspense } from "react";
import { QuestionBrowser } from "@/components/QuestionBrowser";

export const metadata = { title: "Question Browser" };
export default function QuestionsPage() { return <div className="container"><div className="page-intro"><div className="eyebrow">Question library</div><h1>Browse questions</h1><p className="lead">Filter by year, layer, topic, or question type. Search the wording and key concepts.</p></div><Suspense fallback={<div className="panel empty">Loading questions…</div>}><QuestionBrowser /></Suspense></div>; }
