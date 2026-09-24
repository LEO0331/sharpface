# Dataset review

Items in the 2013–2015 dataset that need a human check. This covers every figure-dependent question and every transcription or answer decision that could reasonably be disputed. No record is currently `needs-review`: where the intended answer was uncertain, the answer follows the textbook (Kurose & Ross) or a stated common assumption, and the record is `draft`.

Sources: the three exam PDFs (`CNA-2013-S1-Main.pdf`, `CNA-2014-s1 (4) (1).pdf`, `CNA-2015-s1-MAIN.pdf`) and the 2017 student answer notes. The notes are unofficial. `verified` means "directly supported by those notes", not "matches an official marking scheme".

## General

### All years — handwritten annotations
Reason: the PDFs are a student's annotated copies. They contain red handwritten notes (for example "root dns", "timer", "shorter", "n forwarding table and 2n interface") and OneNote page titles such as "Application Layer_ DNS 21 Apr 2017". None of this is exam text, and all of it was excluded from `question`. Some notes were used as evidence for `verified` answers.
Dataset status: question text contains printed exam wording only. Spot-check a few records against a clean copy of the paper if one is available.

### All years — image-only answer notes
Reason: several note files are scanned images with no extractable text: P2P CS, Socket Port, SMTP, Protocol General, and Distance Vector. Answers on those topics could not be checked against the notes.
Dataset status: the related records are `draft`, except where the printed annotations on the exam PDF support the answer. Examples are 2014 Q1(a) and 2015 Q1(a).

### All years — multi-line math
Reason: equations were typeset in LaTeX. They are rendered as plain text, e.g. `NF/(us + Σ_{i=1}^{N} ui)` and `lim_{N→∞} (1 − 1/N)^N = 1/e`.
Dataset status: the meaning is preserved. Check the rendering if math notation support is added later.

## 2013

### 2013 Q1(f)
Reason: the question asks when client-server is faster than P2P. By the standard lower-bound formulas it never is. The student note says "no condition, based on the formula, p2p always quicker than c-s". The intended exam answer (formula-based "never", or practical conditions) is unknown.
Dataset status: `draft`. Resolved with the textbook formula view: in the ideal model client-server is never faster (equal only when N = 1 or peers upload nothing). The answer then lists the practical conditions the model ignores.

### 2013 Q3(b)
Reason: the question depends on Figure 1. Link costs were transcribed from the image: A–B 6, A–E 2, B–C 1, B–E 3, C–D 2, E–D 3. "Assume that routing loops are prevented" can be read in more than one way, which changes some intermediate cells. The answer uses neighbour distances that avoid B (poisoned reverse). The final routing table is the same under either reading.
Dataset status: `draft`, `requiresFigure: true`. Edge costs were re-checked against the rendered figure and match. The loop-avoiding reading is stated as an assumption in the answer.

### 2013 Q4(b)
Reason: the true/false verdict depends on reading "error-free" as perfect or as effectively reliable.
Dataset status: `draft`. The answer explains both halves of the statement.

### 2013 Q4(c)(i)–(iii)
Reason: computed answers. The last 3 bits (`011`) were assumed to be the CRC, as the question states. The remainder of 101000011 ÷ 1001 is 110, which was checked by script.
Dataset status: `draft`.

### 2013 Q3(g)
Reason: a calculation. It assumes a 20-byte IPv4 header with no options.
Dataset status: `draft`. The result is 5 fragments with offsets 0/85/170/255/340.

### 2013 — preserved typos
Reason: the original wording is kept: "Given an example" (Q3(a)), "upto" and "Subnect" (Q3(e)), "orginal" (Q3(g)), "What is the an important" (Q5(a)).
Dataset status: intentional. Do not "fix" these.

## 2014

### 2014 Q1(a)(i) / Q1(a)(ii)
Reason: the equation is printed as "Dpsp", almost certainly a typo for D_p2p. The item labels were Greek letters that did not extract; α/β/γ were reconstructed from the page image. The example opens with a closing quote (”), as printed.
Dataset status: `verified` (matched by the notes). The wording is kept as printed.

### 2014 Q3(d)(i)
Reason: no prefix length is given. The answer assumes classful addressing: 10.0.0.0/8, so 1 network. A different assumption changes the answer.
Dataset status: `draft`. The classful assumption is stated in the answer.

### 2014 Q3(e)
Reason: the question states a 20-byte IP header only. Counting a 20-byte TCP header as well changes the answer from 3379 to 3425 datagrams.
Dataset status: `draft`. The answer notes both.

### 2014 Q2(d)(i)
Reason: the receiver buffer sizes (AB 1 KB, GBN 1 KB, SR 1 MB) are derived and are not in the notes.
Dataset status: `draft`.

## 2015

### 2015 Q3(a)
Reason: the question depends on Figure 1. Transcribed link costs: A–B 2, A–C 1, B–C 2, B–D 2, D–E 3, A–E 8.
Dataset status: `draft`, `requiresFigure: true`. Check the costs against the figure. The Dijkstra result (D via B cost 4, E via B cost 7) depends on them.

### 2015 Q3(b)(i) / Q3(b)(ii)
Reason: the question depends on the Figure 1 network and on the printed tables. The tables were transcribed into the question text as plain rows. B's vector is printed as "[A, 2 C, 2 D, 2 E, 5]" and read as A 2, C 2, D 2, E 5.
Dataset status: `draft`, `requiresFigure: true`. For (ii), the answer also mentions the poisoned-reverse variant.

### 2015 Q4(a)
Reason: the student annotation reads "n forwarding table and 2n interface", which counts router interfaces only.
Dataset status: `draft`. Uses the textbook answer: 8 interfaces (2n + 2, including both hosts) and 3 forwarding tables.

### 2015 Q5(a)
Reason: the page includes Figure 2 (ALOHA efficiency plot: slotted peaks ≈ 0.37 at G = 1, pure ≈ 0.18 at G = 0.5). The question can be answered without it.
Dataset status: `draft`, `requiresFigure` not set.

### 2015 Q5(b)
Reason: 1 Mbps host rates on a 2 Mbps channel make the intended TDMA/FDMA/ALOHA figures ambiguous. The question also ends with a stray "pure ALOHA),", kept as printed.
Dataset status: `draft`. The answer is a direction: it assumes an average demand of 0.2 Mbps per host and p = 0.2 for ALOHA, and quotes the textbook maximum efficiencies (1/e, 1/(2e)).

### 2015 Q5(c)
Reason: the efficiency formula is printed as "efficiency = 1/1 + 5tprop/ttrans" (a typesetting error). The intended formula is 1/(1 + 5·tprop/ttrans), given in `formulas`.
Dataset status: `draft`. The question text is kept as printed.

### 2015 Q5(d)
Reason: the question depends on Figure 3 (MPLS tables), transcribed into `figureDescription`. R5's and R6's interface numbers towards R4 are not labelled. Each has a single link to R4, so the answer assumes interface 0. The label values chosen (10 and 8) are one valid option.
Dataset status: `draft`, `requiresFigure: true`.

### 2015 Q5(f)
Reason: a 4 × 4 layout was assumed to be the "minimum-length EDC field", which gives 9 parity bits.
Dataset status: `draft`.

### 2015 — preserved typos
Reason: the original wording is kept: "compare to" (Q4(f)), "dectection" (Q5(f)), "7 collision has occured" (Q5(g)), "text based protocols" (Q1(f)), and "4 ∗ 10^9" (Q1(c)(i)).
Dataset status: intentional.
