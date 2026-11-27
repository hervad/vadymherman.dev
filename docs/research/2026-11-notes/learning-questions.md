# Check-for-understanding questions when an AI writes the code and the learner must explain it

Research notes, compiled 2026-11-27. Web research only; no project files were changed.

## How to read these notes

Evidence strength label on every claim:

- **[META]** meta-analysis or systematic review
- **[REVIEW]** narrative review or theory paper
- **[STUDY]** single study (or one small series)
- **[PRACT]** practitioner opinion, product documentation, book advice

Verification label (what I actually saw today):

- **(opened)** I read the primary text today (full text, or the paper's own abstract in the PDF / publisher or index record).
- **(abstract)** I only saw the abstract or an index record through search results; numbers come from there.
- **(secondary)** I only saw someone else's summary of it. Low confidence.
- **(unconfirmed)** From memory; not opened today. Treat as a pointer, not as evidence.

Anything taken from web pages is lower confidence than something run locally; the learner should spot-check the few sources a decision rests on. The ones that matter most are marked with ★.

The setting assumed throughout: an adult novice in DevOps/SRE, low prior knowledge of the specific tools, material with many interacting parts (Ansible + sshd + SELinux + systemd), the AI writes the code, the learner reviews and must be able to explain it. Current routine: (a) predict before a run, (b) explain back in two sentences, (c) three recall questions next session, (d) one "explain to an interviewer" question at milestones. Complaint: questions too complex, he ends up guessing, prefers "show first, then ask about what was shown".

---

## 1. Sequencing: explain/show first, or question/problem first?

### 1.1 What supports "show first" for a novice

- **Worked-example effect.** Studying worked examples beats solving equivalent problems for novices. Meta-analysis in mathematics: g = 0.48 (55 studies, 181 effect sizes); correct examples worked better than incorrect or mixed ones; the effect was *smaller* when self-explanation prompts were added to the examples (surprising, noted by the authors). **[META] (abstract)** Barbieri, Miller-Cotto, Clerjuste & Chawla 2023, *Educ Psychol Rev* 35:11. https://link.springer.com/article/10.1007/s10648-023-09745-1
- **High element interactivity → instruction first.** Two randomized experiments (N = 64, N = 71) testing productive failure directly: with higher element interactivity, explicit instruction before problem solving was better, including on transfer. **[STUDY] (abstract)** ★ Ashman, Kalyuga & Sweller 2020, *Educ Psychol Rev* 32:229–247. https://link.springer.com/article/10.1007/s10648-019-09500-5
- **Crossover by complexity and expertise.** For novices, studying examples won on high-interactivity material and generating answers won on low-interactivity material; for more knowledgeable learners generating won on everything. **[STUDY] (abstract)** Chen, Kalyuga & Sweller 2015, *J Educ Psychol* 107:689–704. https://eric.ed.gov/?id=EJ1071512
- **Guidance for novices in general.** **[REVIEW] (abstract)** Kirschner, Sweller & Clark 2006, *Educ Psychologist* 41:75–86. https://eric.ed.gov/?id=EJ736299 (a position paper; contested by Hmelo-Silver et al. 2007).
- **Rosenshine, principle 2 and 4:** present new material in small steps with practice after each step; provide models and worked examples; mix worked examples with problems, and use *partially completed problems* so the learner has to attend to the example. **[PRACT, summarising classroom process-product research] (opened)** ★ Rosenshine 2012, *American Educator* 36(1):12–19, 39. https://www.aft.org/sites/default/files/Rosenshine.pdf

### 1.2 What supports "question/problem first"

- **Productive failure (PS-I).** 53 studies, 166 comparisons: problem solving before instruction beat instruction first on **conceptual knowledge and transfer**, g = 0.36 [0.20, 0.51], up to 0.58 when done with high fidelity to Kapur's design. But: **no advantage for procedural knowledge** (g = −0.03 [−0.20, 0.15], 51 comparisons); **instruction-first was better for grades 2–5** and for domain-general skills; the authors themselves say lack of relevant prior knowledge likely explains the reversal and recommend scaffolding the problem phase. Almost all studies are school/university maths and science. **[META] (opened)** ★ Sinha & Kapur 2021, *Rev Educ Res* 91:761–798. https://doi.org/10.3102/00346543211019105 (note: one author is the originator of productive failure; the "true effect after publication bias, g = 0.87" is the authors' own estimate).
- **It only works with specific design features.** "PS-I fosters learning only if specific design features (namely contrasting cases or building instruction on student solutions) are implemented." The mechanisms are prior-knowledge activation, awareness of the knowledge gap, and noticing deep features. **[REVIEW] (opened: abstract)** ★ Loibl, Roll & Rummel 2017, *Educ Psychol Rev* 29:693–715. https://doi.org/10.1007/s10648-016-9379-x
- **Not always replicated.** Problem solving first was not better than studying worked or failed examples first. **[STUDY] (abstract)** Hartmann, van Gog & Rummel 2021, *Instructional Science* 49:1–21. https://link.springer.com/article/10.1007/s11251-020-09528-z
- **Programming.** A small study (n = 20, Python lists) reports better delayed results for productive failure than direct instruction. Too small to lean on. **[STUDY] (secondary: search snippet)** arXiv 2411.11227 / SIGCSE TS 2025. https://arxiv.org/abs/2411.11227
- **Pretesting / prequestions.** Answering questions *before* the material improves later memory even when most answers are wrong. But the benefit is narrow: meta-analysis g = 0.54 for the information that was asked about, **g ≈ 0.04 for everything else**; it is larger when learners actually generate an answer (≈0.65) than when they only read the question (≈0.22). **[META] (abstract)** St. Hilaire, Chan & Ahn 2023/2024, *Psychon Bull Rev* 31:411–441. https://link.springer.com/article/10.3758/s13423-023-02353-8. Review: **[REVIEW] (abstract; full text not opened)** Pan & Carpenter 2023, *Educ Psychol Rev* 35:97. https://link.springer.com/article/10.1007/s10648-023-09814-5
- **Failed attempts help only with the answer following.** Failed retrieval + feedback beat plain study in word-pair experiments. **[STUDY] (abstract)** Kornell, Hays & Bjork 2009, *JEP:LMC* 35:989–998. https://web.williams.edu/Psychology/Faculty/Kornell/Publications/Kornell.Hays.Bjork.2009.pdf. Errors followed by corrective feedback are beneficial in general. **[REVIEW] (abstract)** Metcalfe 2017, *Annu Rev Psychol* 68:465–489. https://files.eric.ed.gov/fulltext/ED574569.pdf

### 1.3 Prediction specifically

- **Predicting is not the same as guessing.** Predicting "involves at least some familiarity with the materials", enough to "commit to one (out of several possible) outcomes with at least some confidence". Its benefit runs through *surprise* at a wrong, confidently held prediction, which focuses attention on the feedback; "incorrect guesses, which are by definition provided with low confidence, are highly unlikely to elicit strong surprise reactions". Feedback must be immediate. Scope: simple declarative learning only. **[REVIEW] (opened via Europe PMC)** ★ Brod 2021, *Psychon Bull Rev* 28:1839–1847. https://link.springer.com/article/10.3758/s13423-021-01904-1
- **Prediction beats "postdiction".** 36 students; predicting before seeing the answer improved learning more than judging afterwards; pupil dilation (surprise) only in the prediction condition. **[STUDY] (abstract)** Brod, Hasselhorn & Bunge 2018, *Learning and Instruction* 55:22–31. https://escholarship.org/content/qt0qn99739/qt0qn99739.pdf
- **Predict before a demonstration.** Physics lecture demos, end-of-semester test (854 student-by-demonstration responses; students rotated between modes week by week): correct outcomes 61% (no demo), 70% (observe), 77% (predict), 82% (predict + discuss); correct *explanations* 22%, 24%, 30%, 32%. Passive observers were slightly better on outcomes (p = .03, small) and no better on explanations (p = .64) than students who never saw the demo. Predicting cost about 2 extra minutes (13 vs 11 min). Students were right in only 26% of in-class predictions in the predict mode and still learned more. Two details matter here: the students had already been taught the underlying topic, and in predict mode they **chose from a list of possible outcomes**. **[STUDY] (opened)** ★ Crouch, Fagen, Callan & Mazur 2004, *Am J Phys* 72:835–838. https://www.otffeo.on.ca/wp-content/uploads/sites/2/2014/11/Mazur_demo-article.pdf
- **PRIMM** (Predict–Run–Investigate–Modify–Make) puts prediction first, but on a *given, readable* program with discussion before running. Quasi-experimental study, 493 students aged 11–14, 13 schools: better post-test than control; teachers split on whether Predict or Investigate was hardest. **[STUDY] (opened: design; result via abstract)** Sentance, Waite & Kallia 2019, *Computer Science Education*. https://doi.org/10.1080/08993408.2019.1608781
- **Practitioner advice, live coding:** have learners commit to an expected result before running. **[PRACT] (secondary)** Brown & Wilson 2018, "Ten quick tips for teaching programming", *PLoS Comput Biol*. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5886386/

### 1.4 Expertise reversal: the right order changes over time

- Guidance that helps novices becomes redundant or harmful as knowledge grows. **[REVIEW] (abstract)** Kalyuga, Ayres, Chandler & Sweller 2003, *Educ Psychologist* 38:23–31. https://en.wikipedia.org/wiki/Expertise_reversal_effect (overview), full text: https://mrbartonmaths.com/resourcesnew/8.%20Research/Explicit%20Instruction/The%20Expertise%20Reversal%20Effect.pdf
- The practical form is **fading**: complete example → example with the last step missing → more steps missing → full problem; removing the last steps first ("backward fading") did at least as well and was more efficient. **[STUDY/REVIEW] (abstract)** Renkl & Atkinson 2003, *Educ Psychologist* 38:15–22; Atkinson, Renkl & Merrill 2003, *J Educ Psychol* 95:774–783. https://www.researchgate.net/publication/253450162
- In programming: completing/extending given programs beat writing from scratch for beginners. **[STUDY] (abstract)** van Merriënboer 1990, *J Educ Computing Research* 6:265–285. https://eric.ed.gov/?id=EJ417022

### 1.5 Conclusion for sequencing

| Situation | Order that the evidence favours | Why |
|---|---|---|
| New mechanism, many interacting parts, learner has no relevant prior knowledge | Explain/show → then question | Worked-example effect; Ashman 2020; Rosenshine. A question first would be a blind guess (low confidence → no surprise benefit, Brod). |
| A state-changing run, mechanism already explained, both "wanted" and "current" state visible | Constrained prediction → run → compare | Crouch 2004; Brod 2018/2021; PRIMM. Passive watching adds little. |
| Simple isolated facts (a flag, a path, a default) | A quick question first is fine | Pretesting effect; low element interactivity (Chen 2015). Benefit is limited to what was asked. |
| Conceptual topic where the learner already has usable intuitions | Short problem first, then instruction that builds on his attempt | Sinha & Kapur 2021; Loibl 2017. Not for procedures. |
| Topic becoming familiar | Move the question earlier, shrink the explanation | Expertise reversal; fading. |

---

## 2. Designing the question that follows an explanation or demo

### 2.1 General principles

- **Check understanding after every small step, with real questions.** Effective teachers asked many questions, including *process* questions ("how did you get that?"), asked students to summarise or restate a procedure, and to agree/disagree with an answer. Less effective teachers asked "Are there any questions?" and moved on. **[PRACT/observational] (opened)** ★ Rosenshine 2012 (principles 3 and 6), URL above.
- **Self-explanation prompts work, and scaffolded ones work better.** Meta-analysis: g = 0.55 [0.45, 0.65], 69 effect sizes. **[META] (abstract)** Bisra, Liu, Nesbit, Salimi & Winne 2018, *Educ Psychol Rev* 30:703–725. https://link.springer.com/article/10.1007/s10648-018-9434-x. In mathematics, scaffolding the explanation (training, or structured response formats such as sentence frames) was the moderator that raised immediate gains; design advice: prompt explanation of correct information *and* of why a common misconception is wrong, and do not let prompts crowd out other content. **[META] (abstract)** Rittle-Johnson, Loehr & Durkin 2017, *ZDM* 49:599–611. https://eric.ed.gov/?id=EJ1149060
- **Providing the explanation can switch off the learner's own explaining.** 2×2 experiment, 80 student teachers: prompts-only learned most; adding ready-made instructional explanations reduced self-explanation and learning; yet the explanation-only group *rated* its learning highest. **[STUDY] (abstract)** ★ Schworm & Renkl 2006, *Computers & Education* 46:426–445. https://eric.ed.gov/?id=EJ729810
- **In human tutoring, what the student constructs matters more than what the tutor explains.** Tutors restricted to prompts (no explanations) produced the same learning. **[STUDY] (abstract)** Chi, Siler, Jeong, Yamauchi & Hausmann 2001, *Cognitive Science* 25:471–533. https://onlinelibrary.wiley.com/doi/10.1207/s15516709cog2504_1
- **"Why?" questions (elaborative interrogation) depend on prior knowledge.** Rated "moderate utility"; "effects generally increase as prior knowledge increases… The benefit for lower-knowledge learners is less certain." **[REVIEW] (opened)** ★ Dunlosky, Rawson, Marsh, Nathan & Willingham 2013, *Psychol Sci Public Interest* 14:4–58. https://www.wku.edu/senate/documents/improving_student_learning_dunlosky_2013.pdf. Consequence: ask "why" only where the reason was just shown or can be derived from the map; otherwise it is a guess.
- **Hinge / diagnostic questions.** A quick question at a decision point; wrong options each correspond to a specific misconception, and a learner holding a misconception must not be able to get it right. **[PRACT] (secondary)** Wiliam 2011, *Embedded Formative Assessment*; summary: https://www.structural-learning.com/post/hinge-questions-teachers-complete-guide. Same advice for teaching programmers: distractors must be plausible and tell the instructor what to explain next. **[PRACT] (secondary: search snippets of the book)** Wilson, *Teaching Tech Together*, ch. 2. https://teachtogether.tech/en/index.html
- **Teach-back / learning by teaching.** Actually explaining (not just preparing to) gave a lasting advantage: one week later d = 0.79 for teaching vs 0.24 for preparing only. Later work suggests the benefit depends on explaining *from memory* rather than from notes. **[STUDY] (abstract)** Fiorella & Mayer 2013, *Contemp Educ Psychol* 38:281–288. https://www.sciencedirect.com/science/article/abs/pii/S0361476X13000209. ("Teach-back" as a term comes from health communication; I found no meta-analysis under that name in education.)
- **Why explain-back is diagnostic.** People overrate how well they understand mechanisms until they have to explain them step by step. **[STUDY] (abstract)** Rozenblit & Keil 2002, *Cognitive Science* 26:521–562. https://www.sciencedirect.com/science/article/abs/pii/S0364021302000782

### 2.2 Programming-education evidence

- **Trace → explain → write.** Exam data: knowledge of basic constructs at the bottom, then tracing, explaining code in plain English and Parsons problems in the middle, code writing on top. **[STUDY, correlational, n = 38] (abstract)** Lopez, Whalley, Robbins & Lister 2008, ICER. https://dl.acm.org/doi/abs/10.1145/1404520.1404531. Replication: broadly similar, tracing and explaining together predict writing best, but results depend on which questions are used. **[STUDY] (abstract)** Venables, Tan & Lister 2009, ICER. https://opus.lib.uts.edu.au/handle/10453/11384. This is a correlational hierarchy, not proof that teaching in that order causes better learning.
- **Parsons problems** (arrange given lines) took less time than fixing or writing code, with similar learning and one-week retention. **[STUDY] (abstract)** Ericson, Margulieux & Rick 2017, Koli Calling. https://dl.acm.org/doi/10.1145/3141880.3141895
- **Questions around AI-generated code (closest study to this setting).** ★ Seven "cognitive engagement" techniques vs showing the code with an explanation; study 1 N = 82, study 2 N = 42. **[STUDY] (opened)** Kazemitabaar, Huang, Suh, Henley & Grossman 2025, IUI '25. https://austinhenley.com/pubs/Kazemitabaar2025IUI_AIFriction.pdf
  - **No technique was statistically better than the baseline on later manual coding** (study 1 underpowered; study 2 Friedman p = .15). Honest reading: design of the questions is not yet proven to raise learning in this setting.
  - *Lead-and-Reveal* (a question about the next step before each line is revealed): same task load as baseline, 1.8× the time, and the only condition where self-rated ability correlated with real ability (r = .26). In version 1 learners complained they were "constantly guessing what the AI was doing"; the fix in version 2 was that **"each guiding question is now preceded by extensive context"**, plus feedback and hints after wrong answers.
  - *Trace-and-Predict* (code shown first, then predict variable values, then explain a highlighted part): learners answered 76% of its questions correctly vs 58% for Lead-and-Reveal, but it took 2.7× baseline time and had the highest task load; single-line questions were found too easy, multi-step ones tiring.
  - Deliberately injected bugs ("verify and review") produced the most frustration; the paper notes that erroneous examples help advanced learners but can overwhelm novices.

### 2.3 What makes a question too hard

- **Element interactivity**: how many things must be held in mind *at the same time* to answer. It depends on the learner: with knowledge, several elements collapse into one chunk. **[REVIEW/theory] (abstract)** Chen, Kalyuga & Sweller 2015 (above); Ashman et al. 2020 (above). Caveat: critics point out that element interactivity "is not defined in a quantitative, measurable way". **[REVIEW] (opened)** Karpicke & Aue 2015, *Educ Psychol Rev* 27:317–326. https://learninglab.psych.purdue.edu/downloads/2015/2015_Karpicke_Aue_EDPR.pdf
- Working memory overload from too much new material at once; errors arise "when the information is new and the student does not have adequate or well-formed background knowledge". **[PRACT] (opened)** Rosenshine 2012.
- **Granularity.** Tutoring at the level of single solution *steps* is about as effective as human tutoring (d ≈ 0.76 vs 0.79); answer-level-only tutoring is much weaker (d ≈ 0.31); going finer than steps adds nothing. **[META/REVIEW] (secondary: author's slides via search)** VanLehn 2011, *Educ Psychologist* 46:197–221. https://asu.elsevierpure.com/en/publications/the-relative-effectiveness-of-human-tutoring-intelligent-tutoring/
- Practical checklist derived from the above (my synthesis, not a tested instrument). A question is probably too hard if any of these hold:
  1. it needs more than one inference step ("what will change *and why*" is two questions);
  2. it needs a fact that has not been shown or cannot be seen on screen;
  3. it asks about the whole system instead of one observable (one task, one file, one line of output);
  4. it is open-ended on first exposure (free recall + generation at once);
  5. the learner cannot tell what a good answer would look like.

---

## 3. Difficulty calibration

- **About 80% correct during guided practice.** "The optimal success rate for fostering student achievement appears to be about 80 percent. A success rate of 80 percent shows that students are learning the material, and it also shows that the students are challenged." Underlying observation: 82% correct in the most successful fourth-grade maths classes vs 73% in the least. Reason given: with low success, learners "are practicing and learning errors". **[PRACT, from correlational classroom studies of children] (opened)** ★ Rosenshine 2012, p. 17. Not an experiment and not adults.
- **The "85% rule" is not education evidence.** It is a mathematical result for gradient-descent learners on **binary classification**; the number depends on the noise assumption (≈82% Laplacian, ≈75% Cauchy); the authors say "not all models will exhibit a sweet spot" and that the link to human learning is untested. **[STUDY: theory + simulation] (opened via Europe PMC)** Wilson, Shenhav, Straccia & Cohen 2019, *Nat Commun* 10:4646. https://www.nature.com/articles/s41467-019-12552-4. Use it as an illustration that some failure is expected, not as a target.
- **Retrieval success and feedback interact.** Testing vs restudy overall g = 0.50. Without feedback: initial success ≤ 50% → **g = 0.03** (no benefit); 51–75% → 0.29; > 75% → 0.56. With feedback: **g = 0.73** regardless of success. **[META] (opened)** ★ Rowland 2014, *Psychol Bull* 140:1432–1463. https://doi.org/10.1037/a0037559. So a hard question is only wasted if no answer follows.
- **"Reasonably successful" retrieval.** "Retrieval is most beneficial when it is reasonably successful at bringing accurate and relevant information to mind (particularly important when no feedback is provided)." **[REVIEW] (opened: author manuscript)** ★ Carpenter, Pan & Butler 2022, *Nat Rev Psychol* 1:496–511. https://sc-pan.github.io/pdf/NRP_2022.pdf
- **Formats.** Cued recall g = 0.61, free recall 0.29, recognition 0.29 in the full data set, but confounded with feedback; with exposure controlled, cued 0.72 and free recall 0.81 both beat recognition 0.36. **[META] (opened)** Rowland 2014. A second meta-analysis found multiple-choice practice (g ≈ 0.70) at least as good as short-answer (≈ 0.48). **[META] (secondary)** Adesope, Trevisan & Sundararajan 2017, *Rev Educ Res* 87:659–701. https://doi.org/10.3102/0034654316689306. The two disagree, so "free recall is always best" is not safe; recognition questions are a legitimate first rung.
- **Scaffolded retrieval.** Starting with a strong cue and removing it step by step ("diminishing cues") helped in conditions where ordinary testing did not (no feedback); with feedback the two were equal. Word-pair materials. **[STUDY] (abstract)** Fiechter & Benjamin 2018, *Psychon Bull Rev* 25:1868–1876. https://link.springer.com/article/10.3758/s13423-017-1366-9
- **Desirable difficulties and their limit.** The idea (Bjork) is that effortful retrieval, spacing and variation slow performance now and improve retention later. The limit: a difficulty is only desirable if the learner can respond to it successfully or gets the answer afterwards. **[REVIEW] (unconfirmed: Bjork & Bjork 2011 not opened today; the limit is consistent with Rowland 2014 and Carpenter et al. 2022 above.)**

### Laddering

Recognition → cued recall / completion → trace or constrained prediction → explain in plain English → what-if / debug → teach-back and transfer.

Support for the ladder as a whole is indirect: fading studies (Renkl & Atkinson), the programming skill hierarchy (Lopez; Venables, correlational), scaffolded retrieval (Fiechter & Benjamin), and contingent tutoring. I found no experiment that tests this exact six-rung ladder. Rule for moving on it (contingency): after a failure give more help on the next question, after a success give less. **[STUDY, n = 32 children] (secondary)** Wood, Wood & Middleton 1978, *Int J Behav Dev* 1:131–147. Note: a preregistered replication reportedly did *not* reproduce the advantage of the contingent strategy (Utrecht/Tilburg repository record, ~2026); seen only as a search snippet, so **low confidence both ways**. https://research-portal.uu.nl/ws/files/275996783/2026-36551-001.pdf

---

## 4. After a wrong answer or "I don't know"

- **Feedback with information beats right/wrong.** Overall feedback effect d = 0.48 (435 studies); "high-information" feedback d = 0.99. **[META] (abstract)** Wisniewski, Zierer & Hattie 2020, *Front Psychol* 10:3087. https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2019.03087
- **For novices: immediate, directive, correct answer plus a short elaboration.** Hints alone are the weaker choice for beginners; delayed and "facilitative" feedback suit more advanced learners; elaborate in manageable units. **[REVIEW] (secondary: guideline tables via search)** Shute 2008, *Rev Educ Res* 78:153–189. https://myweb.fsu.edu/vshute/pdf/shute%202008_b.pdf. Note the tension with the testing literature, where delayed feedback was larger (g = 1.38, k = 6, vs 0.66 immediate; Rowland 2014 warns the delayed estimate is thin and confounded).
- **Hint ladders.** AutoTutor's order per expected idea: pump ("tell me more") → hint (a leading question) → prompt (fill in one word) → assertion (state the answer). **[PRACT/system design] (secondary)** Graesser et al. 2004/2005. https://www.researchgate.net/publication/215835920_AutoTutor_A_tutor_with_dialogue_in_natural_language
- **On-demand hints have a small payoff and get abused.** Learners click through to the bottom-out hint; time spent reading the bottom-out hint (i.e. self-explaining it) is what relates to learning. **[REVIEW] (secondary: search snippets)** Aleven, Roll, McLaren & Koedinger 2016, *IJAIED* 26:205–223. https://doi.org/10.1007/s40593-015-0089-1. When to give and when to withhold help is an open problem ("assistance dilemma"). **[REVIEW] (abstract)** Koedinger & Aleven 2007, *Educ Psychol Rev* 19:239–264. https://link.springer.com/article/10.1007/s10648-007-9049-0
- **Bounded attempts.** In the AI-code study: up to three tries, then the correct answer is shown; learners explicitly asked for "hints or explanations after incorrect answers". **[STUDY] (opened)** Kazemitabaar et al. 2025.
- **Errors are fine if corrected; confident errors are corrected best.** **[REVIEW] (abstract)** Metcalfe 2017. A blind guess is the opposite case: low confidence, little surprise (Brod 2021).
- **Reteach rather than push on.** Checks tell the teacher "when parts of the material need to be retaught"; one effective teacher stopped an exercise entirely when errors piled up. **[PRACT] (opened)** Rosenshine 2012. That re-explaining should use a *different* representation (diagram instead of words, a concrete trace instead of a rule) is common advice; I found no direct experimental source for it. **[PRACT] (no source found)**
- **Re-ask later.** Missed items should come back until answered correctly, then again in later sessions ("successive relearning"). **[REVIEW] (opened)** Carpenter, Pan & Butler 2022.

Suggested protocol (synthesis of the above):

```
wrong answer ─► name what is right in it
             ─► one narrowing cue (point at the line / the output / the box on the map)
             ─► second try
             ─► still wrong: give the answer + the one-sentence reason (no third guess)
             ─► ask the learner to restate it in his own words
             ─► put a variant of the question in the next-session queue

"I don't know" ─► do not ask for a guess
               ─► turn the question into a 2–3 option choice, or show where the answer is visible
               ─► if still stuck: the explanation was too big; re-explain one smaller piece, then ask about that piece
```

---

## 5. Later-session retrieval

- **Retrieval practice and spacing are the two best-supported techniques.** Rated "high utility". **[REVIEW] (opened)** Dunlosky et al. 2013. Testing vs restudy g = 0.50 **[META] (opened)** Rowland 2014. In real classrooms: 50 experiments, 57% of effects medium or large, across formats and feedback timings. **[META/systematic review] (abstract)** Agarwal, Nunes & Blunt 2021, *Educ Psychol Rev* 33:1409–1453. https://link.springer.com/article/10.1007/s10648-021-09595-9
- **Spacing.** The best gap grows with how long you want to remember: roughly 10–20% of the retention interval for a few weeks, about 5% for a year; a zero gap is much worse. **[STUDY, N = 1,354] (abstract)** Cepeda, Vul, Rohrer, Wixted & Pashler 2008, *Psychol Sci* 19:1095–1102. https://escholarship.org/uc/item/0kp5q19x. Practical guidance: long enough that it is no longer fresh, short enough that it is still recognisable. **[REVIEW] (secondary)** Carpenter via retrievalpractice.org.
- **Feedback** "typically increases the effectiveness of retrieval practice"; essential when recall is poor. **[REVIEW] (opened)** Carpenter et al. 2022; **[META]** Rowland 2014.
- **Successive relearning**: retrieve with feedback until correct, repeat in later sessions; getting each item right more than once in the first session made later sessions easier (d = 0.63 two days later). Mostly shown for factual material. **[REVIEW] (opened)** Carpenter et al. 2022.
- **Limits.** "Retrieval benefits retention but produces limited benefits on far transfer"; transfer improved when learners were given a hint that the earlier solution applied. **[REVIEW] (opened)** Carpenter et al. 2022.
- **Disputed: complex material.** Claim: "the testing effect decreases or even disappears as the complexity of learning materials increases". **[REVIEW] (abstract)** van Gog & Sweller 2015, *Educ Psychol Rev* 27:247–264. https://link.springer.com/10.1007/s10648-015-9310-x. Reply: the null results came from "immediate, massed retrieval practice" right after a worked example, not from complexity. **[REVIEW] (opened: abstract)** Karpicke & Aue 2015. Both sides agree on one practical point: a question asked *immediately* after showing the answer is weak retrieval. Space it.
- **How many?** No source gives a number for adults in this setting. Rosenshine describes a 5–8 minute review at the start of lessons **[PRACT] (opened)**. Three to five short questions fits that; the count matters less than feedback and re-queuing misses.

Format advice that follows from sections 3–5:

- cued recall with a context cue ("in the users_ssh piece, the drop-in file starts with 01- because…?"), not "tell me everything about last session";
- one item from an older piece (spacing);
- answer and one-sentence reason after every item;
- a missed item returns next session; an item answered correctly in two separate sessions is retired or upgraded to a what-if question;
- questions come from the learning log, so they ask about what was actually explained.

---

## 6. AI tutoring products and studies

- ★ **Harvard physics AI tutor (RCT, crossover, N = 194).** Learning gains with the AI tutor were about double those of an in-class active-learning lesson (0.73–1.3 SD), in less time (median 49 min). Design, quoted from the system prompt: "Keep responses BRIEF (a few sentences or less)", "Only give away ONE STEP AT A TIME, DO NOT give away the full solution in a single message", "if the student wants the answer in the first message, encourage them to give it a try first", may confirm a right answer, "Assume the student is learning this topic for the first time. Assume no prior knowledge." Each problem's prompt carried a teacher-written step-by-step solution; a prompt alone could not keep multi-part problems in sequence, so the platform enforced the order. Authors' caveats: one course, one institution, authors are the instructors, tasks at understand/apply/analyse level, "when the AI tutor should openly provide answers versus guiding students to reflect" is an open question. **[STUDY] (opened: Europe PMC full text + preprint with prompt)** Kestin, Miller, Klales, Milbourne & Ponti 2025, *Sci Rep* 15:17458. https://www.nature.com/articles/s41598-025-97652-6; prompt: https://www.researchsquare.com/article/rs-4243877/v1
- ★ **"Generative AI without guardrails can harm learning" (RCT, ~1,000 Turkish high-school students, maths).** Plain ChatGPT-style help ("GPT Base"): +48% on assisted practice, **−17% on the later unassisted exam**. "GPT Tutor" (hints instead of answers, teacher-written solutions and common mistakes in the prompt): +127% on practice, exam no different from control (no harm, **no gain**). Students in neither arm noticed; GPT Tutor students believed they had done better. **[STUDY] (opened via Europe PMC)** Bastani, Bastani, Sungu, Ge, Kabakcı & Mariman 2025, *PNAS* 122(26):e2422633122. https://www.pnas.org/doi/10.1073/pnas.2422633122
- ★ **AI assistance and coding skill formation (RCT, 52 mostly junior developers learning a new Python library).** Quiz afterwards: 50% with AI vs 67% by hand (d = 0.74, p = .01), biggest gap on debugging; no significant time saving. Within the AI group (small subgroups, associations only): delegating everything ≈ 39%, using AI to debug iteratively ≈ 24%; generating code and then asking questions until it was understood ≈ 86%, asking for code with explanations ≈ 68%, asking only conceptual questions ≈ 65%. The authors point to learning modes (naming Claude Code's Learning and Explanatory styles) but did not test them, and expect agentic tools to have a *larger* effect. **[STUDY, small] (opened: Anthropic's write-up; arXiv 2601.20245 not opened)** Shen & Tamkin 2026. https://www.anthropic.com/research/AI-assistance-coding-skills
- **Substitute vs complement use.** In university coding courses, asking the LLM for solutions was associated with lower learning, asking for explanations with higher. **[STUDY] (secondary: search snippets)** Lehmann, Cornelius & Sting 2024, arXiv 2409.09047. https://arxiv.org/abs/2409.09047
- **Kazemitabaar et al. 2025** (section 2.2): questions around AI-written code; context before each question and feedback after errors were the fixes learners needed; no significant learning gain shown.
- **Claude Code output styles.** *Explanatory*: adds short "Insight" blocks about why choices were made. *Learning*: the same Insights, and for pieces with a real design decision Claude leaves a `TODO(human)` and sends a "Learn by Doing" request with three parts: **Context** (what is already built), **Your Task**, **Guidance** (what to weigh); then waits, and gives one Insight on the learner's code. No quiz or recall questions are described. So the built-in pattern is context first → small completion task → feedback, i.e. a faded worked example. **[PRACT: product documentation] (opened)** https://code.claude.com/docs/en/output-styles
- **Claude Learning mode (claude.ai).** Described as Socratic: guiding questions ("How would you approach this problem?", "What evidence supports your conclusion?") instead of direct answers. **[PRACT] (secondary: press coverage only; no Anthropic primary page opened)**. Anthropic's Education Report (≈1M student conversations) found ~47% of conversations were "direct" answer-seeking and that Claude, not the student, did most of the creating (39.8%) and analysing (30.2%); it mentions Learning Mode as a response and says its effect on learning has not been measured. **[STUDY: usage analysis] (opened)** https://www.anthropic.com/research/anthropic-education-report-how-university-students-use-claude
- **Khanmigo.** Official blog lists tutoring principles: meet students where they are, immediate feedback, prompt "self explanation", keep students at their "Goldilocks" learning edge, clear up misconceptions, economy of language. **[PRACT] (opened)** https://blog.khanacademy.org/khan-academys-7-step-approach-to-prompt-engineering-for-khanmigo. An unofficial copy of the "Khanmigo Lite" prompt adds: don't give answers, find where the student is stuck and give small hints, "be wary of me repeatedly asking for hints or help without making any effort". **[PRACT] (secondary, unofficial gist)** https://gist.github.com/25yeht/c940f47e8658912fc185595c8903d1ec
- **ChatGPT study mode** (July 2025): system-prompt based; guiding questions, sectioned explanations to limit overload, knowledge checks with feedback, opening probe of goals and prior knowledge. **[PRACT] (secondary: search results; primary page https://openai.com/index/chatgpt-study-mode/ not opened)**

Pattern across the products with evidence behind them: short turns; one step at a time; the learner attempts before the answer is given; the answer is available when asked for (Kestin) or after bounded attempts (Kazemitabaar); prepared correct solutions behind the tutor; assume no prior knowledge. Pure "never tell" Socratic questioning is a product choice, not something these studies isolate, and Bastani's result shows hints-only guardrails prevented harm without producing gains.

---

## 7. DevOps / SRE specifics

- **Google SRE book, ch. 28 "Accelerating SREs to On-Call and Beyond".** **[PRACT] (opened)** https://sre.google/sre-book/accelerating-sre-on-call/
  - Structured, sequential learning is recommended over "trial by fire" ("We're throwing you in the deep end of the pool"); theory early, hands-on as soon as practical.
  - **On-call learning checklist** per system with "comprehension questions", e.g. "Which backends of this server are considered 'in the critical path,' and why?" and "Where do you think the first bottleneck is in this architecture?" — questions about one system at a time, answerable from material the learner has just studied.
  - **Reverse engineering a service**: the newcomer diagrams the stack and reviews the diagram with a senior SRE (teach-back on a map).
  - **Wheel of Misfortune**: role-played outage; the game master feeds dashboard information step by step, redirects from red herrings, asks pointed questions. A transfer exercise for people who already know the system.
  - **"Let's burn a search cluster to the ground"**: the team discusses expected behaviour, *records predictions*, breaks the stack, then explains what happened. Prediction on a real system, done by people who know it.
  - **Shadowing → reverse shadowing**: watch the on-caller, later be primary while the expert watches and gives hints only when needed. This is fading.
- **Katas / repetition drills**: common practitioner advice; I found no research source specific to DevOps katas. **[PRACT] (no source found)**

Bearing on question design: the profession's own practice puts questions *after* a learning path, ties them to one named system, uses the learner's own diagram as the object of explanation, and reserves open scenario questions for later.

---

## (i) Rules: "after X, ask Y"

1. **After explaining or showing a new mechanism for the first time, ask one question about one element that is visible on screen but cannot be answered by copying a sentence** (a trace, or a choice between options). Not before the explanation. — Rosenshine 2012; Barbieri 2023; Ashman 2020; Kazemitabaar 2025 (context before each question).
2. **Before a state-changing run, once the mechanism is explained and both the diff and the current state are on screen, ask for a *constrained* prediction**: pick one of 2–3 named outcomes, or one observable (e.g. the `changed=` count of one task), plus "how sure, 1–3". Leave "and why" for after the run. — Brod 2021; Brod 2018; Crouch 2004 (list of outcomes, ~2 minutes, passive watching ≈ nothing); PRIMM; SRE ch. 28.
3. **After the run, ask one self-explanation question tied to the gap between prediction and output**: "the recap shows X; which line of the diff produced it?" — Bisra 2018; Rittle-Johnson 2017; Brod 2021 (surprise directs attention to feedback).
4. **After a step is finished, ask for the explain-back, with a sentence frame at first** ("This change makes ___ so that ___; without it ___ would happen"), and drop the frame once he succeeds regularly. — Fiorella & Mayer 2013; Rozenblit & Keil 2002; Rittle-Johnson 2017 (scaffolded explanations); Renkl & Atkinson 2003 (fading).
5. **After writing any question, check it: one idea, one inference step, answer visible or already taught. If not, split it.** — Chen 2015 / Ashman 2020 (element interactivity); Rosenshine (small steps); VanLehn 2011 (step granularity).
6. **After each answer, adjust: two misses in a row → go one rung down the ladder; three or four first-try successes → go one rung up.** Aim for roughly four out of five right on first try for checks that follow an explanation. — Rosenshine 2012 (~80%); Rowland 2014; Wood et al. 1978 (contingency; replication doubtful); Kalyuga 2003.
7. **After a wrong answer: say what is right in it, give one narrowing cue, allow a second try, then give the answer with a one-sentence reason and have him restate it.** No third guess. — Wisniewski 2020; Shute 2008; AutoTutor hint order; Kazemitabaar 2025 (bounded attempts); Kestin 2025 (answer available on request).
8. **After "I don't know", do not ask for a guess: turn the question into a 2–3 option choice or point to where the answer is visible; if still stuck, re-explain a smaller piece and ask about that.** Treat it as a sign the explanation was too big, not that the learner failed. — Brod 2021 (low-confidence guesses give little); Rowland 2014; Rosenshine (reteach).
9. **At the start of the next session, ask 3–5 cued-recall questions taken from the learning log, one of them from an older piece; give the answer after each; re-queue misses; retire or upgrade items answered correctly in two separate sessions.** — Rowland 2014; Carpenter, Pan & Butler 2022; Cepeda 2008; Agarwal 2021; Dunlosky 2013.
10. **At a milestone, ask the "explain it to a maintainer" question as a teach-back on the project map, from memory, and only on topics that already passed the lower rungs; add one what-if scenario for transfer and say which earlier piece it relates to.** — Fiorella & Mayer 2013; SRE ch. 28 (diagram review, Wheel of Misfortune); Carpenter 2022 (transfer needs a hint that earlier knowledge applies).
11. **Once a topic is familiar, move the question in front of the explanation and leave a small gap for him to fill (`TODO(human)`, last step first).** — Kalyuga 2003; Chen 2015; Sinha & Kapur 2021 (conceptual topics); van Merriënboer 1990; Renkl & Atkinson 2003; Claude Code Learning style.
12. **After an explanation, never accept "makes sense" as the check, and never replace the question with more explanation.** — Rosenshine ("Are there any questions?"); Schworm & Renkl 2006; Deslauriers 2019; Bastani 2025; Shen & Tamkin 2026.

---

## (ii) Question templates, easiest → hardest

Each has one DevOps example. "Expected" is the gist of a good answer.

**T1. Recognition / hinge question** (choose; every wrong option = one known misconception)

> We changed the sshd drop-in template; the task has `notify: restart sshd`. When does sshd restart?
> A) Right after that task, every run. B) Once, at the end of the play, and only if the task reported `changed`. C) At the end of every play, changed or not.

Expected: B. A = "notify is a function call"; C = "handlers always run". Sources: Wiliam (hinge); Wilson (distractors); Rowland 2014 (recognition is a valid, lower rung).

**T2. Cued recall / completion** (one blank, the rest given)

> The deploy flips the site with `ln -s releases/<sha> current.tmp && mv -T current.tmp ______`. What goes in the blank, and what is the one-word property this gives us?

Expected: `current`; atomic (a single rename, so no visitor sees a half-switched site). Sources: van Merriënboer 1990; Renkl & Atkinson 2003; Fiechter & Benjamin 2018.

**T3. Trace / constrained prediction** (both states visible, one observable)

> Current state: `firewall-cmd --list-services` prints `ssh`. The diff adds `http`, `https` and `http3`, each with `permanent: true, immediate: true`. After the run, what will that command print? And what will `changed=` be on the *second* run?

Expected: ssh plus the three services; second run `changed=0` because the module compares wanted and current state before acting. Sources: Crouch 2004; Brod 2021; Lopez 2008 (tracing); Kazemitabaar 2025 (Trace-and-Predict).

**T4. Explain in plain English / self-explanation** (purpose of one line, with a frame at first)

> In one sentence, what is `AllowUsers kai deploy` for? Then: why is the file called `01-hardening.conf` and not `99-hardening.conf`? ("It is named 01- because sshd ___, so ___.")

Expected: only those two accounts may log in over SSH; drop-ins are read in alphabetical order and the first value wins, so ours must come before `50-cloud-init.conf`. Sources: Bisra 2018; Rittle-Johnson 2017; Lopez 2008 / Venables 2009 (explain-in-plain-English).

**T5. What-if / debug** (near transfer; one change to a known situation)

> The deploy job dies after rsync has finished copying `releases/<new-sha>/` but before the symlink flip. What does a visitor see? What is left on the server?

Expected: the old site, complete and unchanged, because `current` still points at the old release; an unused new directory remains. Sources: Rittle-Johnson 2017 (explain why the wrong idea is wrong); Shen & Tamkin 2026 (debugging is where AI-assisted learners were weakest); Kazemitabaar 2025 (use sparingly with novices).

**T6. Teach-back / transfer** (from memory, to an imagined maintainer or interviewer; a scenario for later stages)

> A maintainer asks: "Why releases plus a symlink instead of rsync straight into the live directory?" Give the reason, one cost of this approach, and one situation where plain rsync would be good enough.
> Later-stage variant (Wheel of Misfortune): "CI is green but the site still shows yesterday's page. What are the first three things you check, in order, and what would each tell you?"

Sources: Fiorella & Mayer 2013; Rozenblit & Keil 2002; SRE book ch. 28.

Use T1–T3 right after an explanation; T4 at the end of a step; T2–T4 as next-session recall; T5–T6 at milestones and only for topics that passed the lower rungs.

---

## (iii) Where the evidence disagrees with the learner's preference

The preference: "explain or show first, then ask about what was just shown."

**Where the evidence agrees.** For a novice on material with many interacting parts, explanation and worked example first is the better-supported order (Barbieri 2023; Ashman 2020; Chen 2015; Rosenshine 2012). Questions that need facts he has not been given are blind guesses, and low-confidence guesses carry little of the benefit prediction is supposed to bring (Brod 2021). The closest study to this setting found learners complaining of exactly this ("constantly guessing what the AI was doing") and fixed it by putting context before every question (Kazemitabaar 2025). Feeling that questions are "too complex" is good information about the questions.

**Where it disagrees.**

1. **Do not drop the prediction before a run.** Watching a demonstration without predicting was barely better than not seeing it (and no better at explaining it); predicting first was clearly better, even though most predictions were wrong (Crouch 2004; Brod 2018). The remedy is a narrower prediction (options, one observable), not no prediction.
2. **Being wrong is not the problem; being wrong without an answer is.** Errors followed by feedback help (Metcalfe 2017; Kornell 2009; pretesting g = 0.54 for the asked items, St. Hilaire 2023). With feedback, the benefit of testing does not depend on getting it right (Rowland 2014: g = 0.73). So the target is about 80% right, not 100%; some misses are expected and useful.
3. **A question that only echoes what was just shown is weak.** Immediate, massed retrieval right after the explanation is the condition where testing effects were absent or small (van Gog & Sweller 2015; Karpicke & Aue 2015 agree on this point). The question should change something (trace it, apply it to a slightly different case, say why) and the same idea should return next session.
4. **The feeling of having understood an explanation is unreliable.** Students rated fluent lectures higher and learned less than from active work (Deslauriers et al. 2019, **[STUDY] (abstract)** *PNAS* 116:19251–19257, https://www.pnas.org/doi/10.1073/pnas.1821936116); the explanation-only group rated its learning highest and learned least (Schworm & Renkl 2006); GPT Tutor users thought they had done better and had not (Bastani 2025). More explanation is the comfortable choice and the less effective one. When the AI writes the code this risk is highest (Shen & Tamkin 2026).
5. **Explain-back should stay, even though it is the hardest part.** It is the step with direct evidence for durable learning (Fiorella & Mayer 2013) and the one that exposes illusions of understanding (Rozenblit & Keil 2002). Make it easier with a frame; do not remove it.
6. **"Show first" is right for now, not for ever.** With growing knowledge, guidance-first turns from help into drag (Kalyuga 2003; Chen 2015, experiment 2), and for *conceptual* understanding problem-first has a moderate advantage in older learners (Sinha & Kapur 2021). The routine should plan to move questions earlier topic by topic.
7. **"Why" questions are hardest exactly for a beginner** (Dunlosky 2013), yet the project's goal (explain every change) needs them. They belong after the reason has been shown, and later as recall, not as a first probe.

**Where the experts disagree with each other** (so no firm rule): productive failure vs cognitive load theory on sequencing; whether retrieval practice works for complex material; multiple-choice vs short-answer as practice format (Rowland vs Adesope); immediate vs delayed feedback (Shute vs Rowland); whether contingent tutoring replicates; and whether any question pattern around AI-written code measurably improves learning (Kazemitabaar: not shown; Bastani: guardrails removed harm, added no gain).

---

## (iv) Could not verify

Not opened today; cited from memory or from someone else's summary. Treat as pointers.

- **Pan & Carpenter 2023** (pretesting review): full text blocked (publisher redirect); only the abstract and citing papers seen. Its exact statements on prior knowledge and boundary conditions are not confirmed.
- **Barbieri 2023, Ashman 2020, Chen 2015, Kalyuga 2003, Kirschner 2006, Hartmann 2021, Bisra 2018, Rittle-Johnson 2017, Schworm & Renkl 2006, Chi 2001, Fiorella & Mayer 2013, Rozenblit & Keil 2002, Lopez 2008, Venables 2009, Ericson 2017, Kornell 2009, Metcalfe 2017, Cepeda 2008, Agarwal 2021, Fiechter & Benjamin 2018, Wisniewski 2020, Koedinger & Aleven 2007, Deslauriers 2019, Brod 2018, van Gog & Sweller 2015, van Merriënboer 1990, Renkl & Atkinson 2003**: abstract or index record only (via search); numbers are as reported there.
- **St. Hilaire et al. 2023** numbers (0.54 / 0.04 / 0.65 / 0.22): from search snippets and a citing paper, not the article.
- **Adesope et al. 2017** format effect sizes: secondary summaries only; the summaries disagree on the number of studies.
- **VanLehn 2011** effect sizes: from the author's slides as reported in search results, not the article.
- **Shute 2008** guidelines: from search snippets of the publisher page.
- **Aleven et al. 2016** (hint use): search snippets; the author PDF link redirected elsewhere.
- **AutoTutor** hint order: search snippets of Graesser et al. papers.
- **Wood, Wood & Middleton 1978** and its reported failed replication: search snippets only; the replication's details (authors, year, journal) are not confirmed.
- **Wiliam's hinge-question principles**: secondary sources and reader notes; the book was not opened.
- **Wilson, *Teaching Tech Together***: search snippets; the "predict before running" advice was confirmed only in Brown & Wilson 2018 (snippet), not in the book's live-coding section.
- **Lehmann, Cornelius & Sting 2024**: search snippets of a preprint.
- **Shen & Tamkin 2026**: Anthropic's own write-up opened; the arXiv paper (2601.20245) was not, so per-pattern scores and limitations are as the write-up states them.
- **Claude Learning mode on claude.ai**: press coverage only. **ChatGPT study mode**: search results only. **Khanmigo Lite prompt**: unofficial copy.
- **Productive failure in Python (arXiv 2411.11227)**: search snippet; n = 20.
- **Sentance et al. 2019 (PRIMM)**: stages read in the author copy; the "statistically significant" result is from an abstract-level summary, effect size not seen.
- From memory, not looked up today (**unconfirmed**): Bjork & Bjork 2011 "desirable difficulties"; Sweller & Cooper 1985 (original worked-example study); Paas 1992 (completion problems); Chi et al. 1989/1994 and Renkl 1997 (original self-explanation studies); Lister et al. 2004 (ITiCSE tracing study); Parsons & Haden 2006; Roediger & Karpicke 2006; Hattie & Timperley 2007; Kapur 2008/2016; Bloom 1984 (2-sigma); Hmelo-Silver, Duncan & Chinn 2007.
- **No source found**: research on DevOps/SRE "katas"; an experiment testing the full recognition → transfer ladder as a sequence; direct evidence that re-explaining in a *different representation* beats repeating the same explanation; any evidence for the specific number "three" recall questions; any study of check-for-understanding questions in an AI-writes-code, learner-reviews setting with infrastructure code (the nearest are Kazemitabaar 2025 and Shen & Tamkin 2026, both on application code).
