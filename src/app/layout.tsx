import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "CNA Practice — Computer Networks Past Questions", template: "%s | CNA Practice" },
  description: "Structured University of Adelaide Computer Networks and Applications past exam questions, revision notes, and guided answer approaches.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>
    <header className="site-header"><div className="container header-inner">
      <Link className="brand" href="/">CNA <span>Practice</span></Link>
      <nav aria-label="Main navigation" className="nav">
        <Link href="/questions">Questions</Link><Link href="/topics">Topics</Link><Link href="/practice">Practice</Link><Link href="/about">About</Link>
      </nav>
    </div></header>
    <main>{children}</main>
    <footer className="site-footer"><div className="container footer-inner"><span>CNA Practice · Independent revision resource</span><span>Historical material may differ from the current syllabus.</span></div></footer>
  </body></html>;
}
