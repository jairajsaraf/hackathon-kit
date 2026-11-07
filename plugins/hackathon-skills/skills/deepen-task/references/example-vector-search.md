# Worked example (condensed)

**User task:** "Create a prompt for Claude Code to watch videos/read articles, then create a document that explains Vector Search so I can fully grasp the concept and, most importantly, explain it to a non-technical audience."

## 1. What a top professional would do
The task treats both goals as "read, then summarize." An ML engineer who also teaches well would:
- **Build it before explaining it** — embed a small dataset, brute-force search, then an approximate index, and measure what was lost.
- **Map where it fails** — similar ≠ relevant; keyword search (BM25) wins on exact codes and names; approximate indexes trade accuracy for speed.
- **Design around misconceptions** — "the computer understands meaning", "it searches everything"; each analogy gets a stated breaking point.
- **Pin down the audience** — executives buying a vector DB, interviewers, or family each need a different explanation.

Feasibility flag: not certain Claude Code can "watch" video; at best it pulls transcripts. Treat videos as optional.

## 2. Rawest material
- Vectors the user generates themselves, including bad query results.
- Primary papers (HNSW, FAISS, product quantization, Sentence-BERT) — IDs marked "verify before relying on."
- Library docs and source (FAISS wiki, hnswlib, sentence-transformers).
- Benchmark data (ann-benchmarks, MTEB), flagged as possibly stale.

## 3. Methods and tools
Technical: sentence-transformers embeddings; numpy cosine as ground truth; FAISS flat/HNSW/IVF-PQ compared by recall@k; rank_bm25 baseline; UMAP/PCA plot with a distortion caveat.
Explanation: Feynman technique; misconception inventory; analogies with break points; readability score (proxy only); teach-back.

## 4. What shows it's right (other than Claude or the user)
- Recall@k numbers from the code vs. the document's claims.
- Every technical claim traced to a paper or official docs.
- **A real non-technical person** explains it back and correctly predicts 2–3 untold outcomes ("Would 'cheap flights' find 'affordable airfare'? Would it reliably find order #48213?"). Most important check for the user's goal.
- Optional practitioner skim.

## 5. Rewritten prompt (skeleton)
```
Goal: deeply understand vector search and explain it to [AUDIENCE: e.g. "hiring
managers in a 3-minute interview answer" / "stakeholders deciding whether we need
a vector database"]. Depth over breadth; no survey of every vector database.

Ground rules: primary sources over blogs/videos; videos only if a transcript is
actually retrieved; no invented citations, numbers or quotes; mark inferences;
note versions/dates.

Phase 1 Sources -> sources.md
Phase 2 Build (small public dataset): embeddings, brute force, FAISS indexes with
  recall@10 + latency table, BM25 baseline, 2-D plot, 3 wins / 3 failures / 1 ANN miss
Phase 3 Failure modes -> failure_modes.md
Phase 4 Document, two layers: technical (for me) + audience layer (30-sec and
  3-min versions, one analogy with its break point, misconceptions, top 5 questions)
Phase 5 Verification -> verification.md: claim->source map, numbers match Phase 2,
  teach-back kit (3 prediction questions, expected answers, rubric), open doubts

Checkpoint: before Phase 2, state the dataset chosen and why in two sentences.
```

Closing pushback: the teach-back with a real person is the only thing that tests the second goal — run it before relying on the explanation anywhere that matters.

**Follow-up handled:** user said "it can use /watch:watch" → videos became usable but stayed secondary; video claims needed confirmation against papers before entering the technical layer. Rest of the prompt unchanged.
