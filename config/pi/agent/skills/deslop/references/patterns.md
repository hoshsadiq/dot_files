# Pattern Catalog

A checklist for catching machine-shaped prose. Not every item applies to every text, and the goal isn't mechanical application. It's to catch the patterns that make writing feel generated.

## 1. AI vocabulary

Words that almost always signal model output:

`delve`, `crucial`, `pivotal`, `vibrant`, `vital`, `foster`, `showcase`, `underscore`, `interplay`, `garner`, `enhance`, `renowned`, `nestled`, `additionally`, `moreover`, `furthermore`, `landscape` (figurative), `paradigm`, `myriad`, `plethora`, `tapestry`, `multifaceted`, `nuanced` (as filler), `robust` (outside engineering), `seamless`, `cutting-edge`, `groundbreaking`, `realm`.

Phrases to cut or rephrase:

`in the realm of`, `excited to announce`, `let's dive in`, `plays a key role`, `commitment to excellence`, `it's important to note`, `in conclusion`, `at the end of the day`, `it's worth noting that`, `when it comes to`, `in today's world`, `the landscape of`.

Simpler substitutes:

| AI version | Write instead |
| --- | --- |
| serves as | is |
| stands as | is |
| utilize | use |
| facilitate | help |
| leverage | use |
| in order to | to |
| due to the fact that | because |
| at this point in time | now |
| has the ability to | can |
| a wide range of | many / various |
| on a daily basis | daily |
| in the process of | (cut; just use the verb) |
| plays a crucial role in | matters for / helps with |

## 2. Significance inflation

AI turns plain facts into major turning points.

Before:
> The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain.

After:
> The Statistical Institute of Catalonia was established in 1989 to collect and publish regional statistics independently from Spain's national statistics office.

Watch for: `stands as`, `serves as`, `is a testament`, `is a reminder`, `crucial role`, `pivotal role`, `underscores`, `highlights`, `reflects broader`, `symbolizing`, `setting the stage for`, `represents a shift`, `evolving landscape`, `indelible mark`, `deeply rooted`, `game-changer`, `redefining`.

## 3. Promotional language

AI drifts into brochure mode, especially for places, products, and organizations.

Before:
> Nestled within the breathtaking region of Gonder, Alamata stands as a vibrant town with a rich cultural heritage and stunning natural beauty.

After:
> Alamata is a town in the Gonder region of Ethiopia, known for its weekly market and 18th-century church.

Watch for: `boasts`, `vibrant`, `rich` (figurative), `profound`, `enhancing`, `showcasing`, `commitment to`, `natural beauty`, `nestled`, `in the heart of`, `groundbreaking`, `renowned`, `breathtaking`, `must-visit`, `stunning`, `world-class`, `state-of-the-art`.

## 4. Participle padding

Chains of -ing words that pad sentences without adding information.

Before:
> The temple's colors resonate with the region's beauty, symbolizing local bluebonnets and the Gulf coast, reflecting the community's deep connection to the land.

After:
> The temple uses blue, green, and gold. The architect said these reference local bluebonnets and the Gulf coast.

Watch for: `highlighting`, `underscoring`, `emphasizing`, `ensuring`, `reflecting`, `symbolizing`, `contributing to`, `cultivating`, `fostering`, `encompassing`, `showcasing`, `demonstrating`, `illustrating`.

## 5. Vague attributions

Name the source when you can.

Before:
> Experts believe it plays a crucial role in the regional ecosystem.

After:
> The river supports several endemic fish species, according to a 2019 survey by the Chinese Academy of Sciences.

Named people, organizations, dates, and numbers make claims trustworthy. "Studies show" is almost always replaceable with a specific citation or should be cut.

## 6. Copula avoidance

AI dodges `is` and `are` with clunky alternatives.

Before:
> Gallery 825 serves as LAAA's exhibition space. The gallery features four spaces and boasts over 3,000 square feet.

After:
> Gallery 825 is LAAA's exhibition space. The gallery has four rooms totaling 3,000 square feet.

Watch for: `serves as`, `stands as`, `marks`, `represents`, `functions as`, `boasts`, `features`, `offers`, `constitutes`.

## 7. Rule of three

Three-item lists aren't wrong, but AI reaches for them reflexively.

Before:
> The event features keynote sessions, panel discussions, and networking opportunities. Attendees can expect innovation, inspiration, and industry insights.

After:
> The event includes talks and panels. There's also time for informal networking between sessions.

Two items is fine. Four is fine. The problem is when every sentence has exactly three.

## 8. Contrastive negation

"Not only X but Y" and "It's not just X, it's Y." AI's default intensifier.

Before:
> It's not just about the beat; it's part of the aggression and atmosphere. It's not merely a song, it's a statement. The real question isn't whether we should adopt AI, it's whether we can afford not to.

After:
> The heavy beat adds to the aggressive tone. We plan to adopt AI tools next quarter.

Use these forms only when there's a real, meaningful contrast. Most of the time, just state the positive claim.

## 9. Elegant variation

AI cycles synonyms when repetition would be more natural.

Before:
> The protagonist faces challenges. The main character must overcome obstacles. The central figure eventually triumphs. The hero returns home.

After:
> The protagonist faces many challenges but eventually triumphs and returns home.

Repetition is human. Forced synonym rotation is not.

## 10. False ranges

Decorative ranges that gesture at breadth without adding content.

Before:
> Our journey has taken us from the singularity of the Big Bang to the grand cosmic web, from the birth of stars to the enigmatic dance of dark matter.

After:
> The book covers the Big Bang, star formation, and current theories about dark matter.

## 11. Em dash overuse

Models use em dashes far more frequently than most human writers. They become a tell when clustered.

Before:
> The term is primarily promoted by Dutch institutions — not by the people themselves. You don't say "Netherlands, Europe" — yet this continues — even in official documents.

After:
> The term is primarily promoted by Dutch institutions, not by the people themselves.

Replace most em dashes with commas, periods, or parentheses. Or restructure to eliminate the aside.

## 12. Inline-header lists and boldface

Bullet lists where each item starts with a bold label, especially when the labels are obvious.

Before:
> - **User Experience:** The UX has been significantly improved.
> - **Performance:** Performance has been enhanced through optimized algorithms.
> - **Security:** Security has been strengthened with end-to-end encryption.

After:
> The update improves the interface, speeds up load times through optimized algorithms, and adds end-to-end encryption.

Prose or simple lists are almost always better when the labels aren't doing real work.

## 13. Filler, hedging, and generic conclusions

Sentences that explain nothing.

Before:
> It is important to note that the data shows the system has the ability to process more requests.

After:
> The data shows the system can process more requests.

Before:
> The future looks bright. Exciting times lie ahead as we continue this journey toward excellence.

After:
> The company plans to open two more locations next year.

## 14. Communication artifacts

Chatbot residue that leaked into a draft.

Watch for: `Great question!`, `I hope this helps!`, `Let me know if you'd like...`, `Certainly!`, `Of course!`, `You're absolutely right!`, `As of my last training update...`, `While specific details are limited based on available information...`, `Happy to help!`.

## 15. Pseudo-profound flourishes

State what something does. Skip the grand framing.

Watch for: `This changes everything.`, `The implications are staggering.`, `We're witnessing the emergence of...`, `This is just the beginning.`, `The future of X is Y.`, `In an era where...`, `In a world where...`.

## 16. Dying metaphors

Worn-out metaphors that read as filler.

Avoid: `toe the line`, `Achilles' heel`, `level playing field`, `play into the hands of`, `hotbed`, `at the end of the day`, `double-edged sword`, `tip of the iceberg`, `game-changer`, `paradigm shift`.

Use simple verbs when they do the job.

## 17. Staccato and monotone rhythm

Too many short declarative sentences in a row feels robotic. Too much polished uniformity feels equally artificial.

Before:
> The experiment produced interesting results. The agents generated 3 million lines of code. Some developers were impressed. Others were skeptical. The implications remain unclear.

After:
> I genuinely don't know how to feel about this one. 3 million lines of code, generated while the humans presumably slept. Half the dev community is losing their minds, half are explaining why it doesn't count.

Vary sentence length. Let some run long, and let others land short. Real writing has texture.

## 18. Extrapolation to universal principles

Keep claims at the scale of the evidence.

Before:
> Once you experience fast deploys, slow CI feels completely unacceptable.

After:
> Fast deploys cut our release cycle from two weeks to a day.

State what happened. Skip the universal lesson unless the source supports it.

## 19. Transition word overuse

AI leans on transition words as connective tissue between sentences that don't need it.

Watch for overuse of: `However,`, `Moreover,`, `Furthermore,`, `Additionally,`, `Nevertheless,`, `Consequently,`, `Meanwhile,`, `Notably,`, `Importantly,`, `Ultimately,`, `Indeed,`.

Most of the time, the logical connection is obvious without the transition word. Cut them and see if the text reads better.

## 20. Passive voice clusters

AI defaults to passive construction more than most human writers. One passive sentence is fine. Several in a row make prose feel evasive or bureaucratic.

Before:
> The decision was made by the team. The rollout was approved by leadership. A timeline was established by the project manager.

After:
> The team decided to proceed. Leadership approved the rollout, and the project manager set a timeline.

Not every passive is wrong. Use it when the actor is unknown, unimportant, or when you want to emphasize the object. But if you can name who did the thing, name them.

## 21. Vague demonstratives

"This" without a clear referent. AI uses bare "this" as a transition between ideas, forcing the reader to guess what it refers to.

Before:
> The API now supports batch processing. This is important because it reduces overhead. This highlights the need for better documentation.

After:
> The API now supports batch processing, which reduces overhead. The new feature also needs better documentation.

If "this" could refer to more than one thing in the previous sentence, replace it with the specific noun, or restructure.

## 22. Performative meta-commentary

The text narrates what it's about to do instead of doing it.

Before:
> Let's explore the key factors. Let's take a closer look at the data. Let's break this down into three parts.

After:
> (Just start with the factors, the data, or the parts.)

Watch for: `Let's explore`, `Let's dive into`, `Let's take a closer look`, `Let's break this down`, `Let's unpack`, `It's worth exploring`, `We need to examine`. These are stalling. Cut them and start with the content.

## Quick reminders

- Read aloud before you stop.
- Favor specifics over abstractions when the facts are available, and keep helpful repetition if it sounds human.
- Add voice sparingly. Only where the context benefits from it.
- When in doubt, shorter is better. The goal is natural, not clever; don't replace one kind of artificiality with another.
