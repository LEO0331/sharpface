import { PracticeSession } from "@/components/PracticeSession";

export const metadata = { title:"Practice Mode" };
export default function PracticePage() { return <div className="container"><div className="page-intro"><div className="eyebrow">Guided revision</div><h1>Practice mode</h1><p className="lead">Pick a subject area or work through the whole collection. Reveal guidance only when you need it.</p></div><PracticeSession /></div>; }
