# Tour content: change table for owner approval (Slice 2)

Nothing here is wired into the game yet. `TourContent.luau` and `QuizKey.luau` are data only; no script, billboard,
credit board or quiz reads them until this table is approved (Slices 3b, 8, 11). Dialogue changes need the repo owner's
approval (README rule 6). Facts come from the project PDF (`Detail Reference/more details.pdf`); numbers in brackets are
the PDF's reference numbers. Everything is plain ASCII.

How to read it: each section ends with the decision it needs. "Approve all" is a valid answer.

## 1. Facts that differ from earlier text (the PDF wins)
| Site | Earlier text | New text | PDF ref |
|---|---|---|---|
| Tagbakin | tawilis declared endangered by the IUCN in 2019 | listed as endangered by the IUCN since 2018 | 25 |
| Farm | 51 hectares; opened December 14, 2002 | 52 hectares; opening date dropped (not in the PDF) | 19 |
| Outlets | 71,000 workers (2024); "largest privately owned industrial estate" | 186 companies, over 75,000 employees; the "largest" claim dropped | 18 |
| Carmel | a commission of Filipino bishops found no supernatural character in 1951; Archbishop Arguelles declared the events worthy of belief in 2015 | the Church's 1951 ruling called the events not supernatural and the Vatican reaffirmed it in 2015; the Archbishop line and the commission are dropped (not in the PDF) | 24 |
| Carmel | "when Lipa was one of the most damaged areas" | dropped (not in the PDF) | 23 |
| Cathedral | bell tower "first had five stories ... made taller in the 1950s" | damaged in 1944, rebuilt by 1957, tower went from five to seven floors | 16 |
| Market | "new concrete market ... most complete of any provincial town in the islands" | "possibly the most complete provincial market in the country"; three main buildings; cost 61,000 pesos | 15 |
| Lomi | "Batangas lomi ... late 1960s" | "Lipa lomi", opened 1968, plus the PDF's caveat that it is an attribution, not fully documented | 7 |
| Cafe | kapeng barako is "the strong coffee Batangas is known for"; Queen Regent Maria Cristina granted the title | a Liberica coffee known for its strong flavor; "elevated to Villa de Lipa" on October 21, 1887 (no named agent) | 10, 12, 5 |
| Malarayat | course split into Lobo, Makulot and Malipunyo; "championship" | 27-hole course about 1,200 ft above sea level; first private golf course (the split is not in the PDF) | 20, 22 |
| Farm | "a lagoon", "activities like yoga" | dropped (not in the PDF text); gardens, labyrinth, peacocks, 300-year-old mango tree kept | 19 |
| Tagbakin | "freshwater sardine"; "a sitio" in dialogue | dropped (not in the PDF text) | 25 |

Decision: approve each fact fix (or tell me which dropped line you want back with a source; the Carmel lines on
Archbishop Arguelles need an outside source and a careful tone).

## 2. Lines kept from earlier text that are NOT in the PDF (still marked [VERIFY])
| Site | Line | Why it is kept |
|---|---|---|
| Market | "Our model follows a plan drawing and recent street photos, so some details may differ." (replaces "Our facade photo is from 2014, so the building may look different today."; owner approved 2026-10-29) | the Market was rebuilt from BP1 (the group's plan drawing) and recent Google Street View views, not from the 2014 photo; the model note comes from briefs/site02.md, not the PDF |
| Lomi | "Our model follows a 2026 Street View image and a drawn board, so details may differ." (replaces "Our photo is from 2015, so the front may have changed."; owner approved 2026-10-31) | Lomi King was rebuilt from the group's Architectural Blueprint Board and a January 2026 Google Street View view, not from the 2015 photo; the model note comes from briefs/site03.md, not the PDF |
| Cafe | "This model shows the Tibig/STAR branch, and its interior is a representative display." | the model note from the brief |
| Cathedral | "Down the steps from this forecourt is Plaza Independencia ..." | describes the model layout |
| Market | name "Candido B. Lopez Memorial Public Market" (sign name); the PDF says "Lipa City Public Market" | which name is correct? |
| Farm, Tagbakin | display lists (3 to 4 short items) | the PDF has no labelled display list for these two, so they come from the place text |
| Tagbakin | billboard "Lipa's lakeside side" | printed that way in the PDF; probably a typo, wording yours |
| City Hall | art "look at" line | new; no City Hall brief exists yet, so Slice 3a checks it against the built model |
| Jeep driver | all five lines ("Sakay na!", "Saan po tayo?", golden hour line) | new driver chatter without facts; the glosses are general Tagalog, not from the PDF |

Decision: keep, reword or drop each.

## 3. Mood mismatches (the game is set at golden hour)
| Where | PDF wording | What I did |
|---|---|---|
| Jun, Malarayat | "Morning! Ready to swing?" | changed to "Hey there! Ready to swing?" |
| Ate Joy wrap-up | "a little sunburnt" | kept the PDF wording (needs your call) |
| Paolo, Outlets | "bring an umbrella or sunscreen" | kept (reads fine at any hour) |
| Mang Tonyo | "The lake's calm today." | kept |

Decision: confirm Jun's change; keep or change "sunburnt" (suggestion: "a little sun-kissed").

## 4. Length and sound rules applied (no meaning change)
- Blurbs are 25 words or fewer; every trivia line is exactly one sentence, one fact; every dialogue line has at most
  two sentences, so a few PDF lines of three or four sentences were merged or trimmed (examples: Ate Joy's first talk,
  Paolo's "bring an umbrella" line, Jun's goodbye "Fore! Haha, kidding, enjoy the view.").
- Local words are explained right away (tawad po, Balik ka ha, Busog ka na, para po). A few unexplained words were
  dropped ("titos" in Mika's goodbye).
- Billboard headlines are the PDF's billboard lines, shortened only where long (Cathedral, Lomi, Carmel).
- ASCII: Cafe (not the accented spelling), Lipenos, Jose Rizal, Batangueno; no curly quotes or dashes. The README bars
  non-ASCII because the typewriter slices by byte. Option: I can make the typewriter UTF-8 safe in Slice 11 so accents
  and "Cafe" with its accent can come back. Keep ASCII (default) or switch?

## 5. NPC names
`TourContent` uses the PDF's names: Lola Cora (Cathedral and plaza), Aling Nena (Market), Kuya Ben (Lomi King),
Mika (Cafe de Lipa), Ate Liza (Carmel), Paolo (Outlets), Ms. Grace (Farm), Jun (Malarayat), Mang Tonyo (Tagbakin),
Ate Joy (City Hall). `SiteData` still holds the old role names ("Plaza Guide", "Market Vendor", "Lomi Host", ...) and
was not touched (shared file). Decision: in Slice 3b/11, should `guideName` become these names? (Recommended.)

## 6. Quiz (one question per site, 3 options, one star per correct answer)
The answer index lives only in `ServerStorage.LipaServer.QuizKey`. The answers are listed here so you can check them;
the repo is public, so this file is visible to anyone who reads it.
| # | Site | Question | Right answer | Ref |
|---|---|---|---|---|
| 1 | Cathedral | Which religious order founded the cathedral's parish in 1605? | The Augustinians (option 2) | 16 |
| 2 | Market | How much did Lipa's market cost to build? | 61,000 pesos (option 1) | 15 |
| 3 | Lomi King | Which immigrant do local historians credit with Lipa lomi? | To Kim Eng (option 3) | 7 |
| 4 | Cafe de Lipa | When did Spanish friars introduce coffee in Lipa? | In the 1740s (option 2) | 12 |
| 5 | Carmel | In what year was the Carmelite monastery founded? | 1946 (option 3) | 23 |
| 6 | Outlets | In what year was The Outlets at Lipa rebranded as The Outlets at LIMA Estate? | 2025 (option 1) | 18 |
| 7 | Farm | How many hectares does The Farm at San Benito cover? | 52 hectares (option 3) | 19 |
| 8 | Malarayat | How many holes does the Mount Malarayat course have? | 27 (option 2) | 22 |
| 9 | Tagbakin | Since what year has the IUCN listed tawilis as endangered? | 2018 (option 1) | 25 |
| 10 | City Hall | What do the 72 elevated blocks at the New Lipa City Hall stand for? | The 72 barangays of Lipa (option 2) | 2 |

Each question can be answered from what the guide says (talk first, then quiz). The Carmel question asks an established
fact, never whether the apparitions are true. Decision: approve the questions, or send replacements.

## 7. Wrap-up reflection (wording is a proposal)
- Ate Joy, wrap-up text: "So, full, caffeinated, and a little sunburnt? Perfect, that's the full Lipa experience."
  (PDF wording; "So?" became "So," to stay within two sentences)
- Reflection: "Balik ka ha! Which of Eat, Pray or Love do you usually stop at, and which one will you try next time?"
  (Eat = Lomi King, Cafe de Lipa, Market; Pray = Cathedral, Carmel; Love = Outlets, Farm, Malarayat, Tagbakin; City
  Hall is the Welcome stop.) This carries your "see the culture behind the checklist" advocacy.
Decision: your wording or mine.

## 8. Art "look at" lines (one per site; all eight elements covered)
| Site | Elements | Origin |
|---|---|---|
| Cathedral | form, space | approved line, edited (tower tiers; plaza space); paired columns and warm walls removed (not in the current build) |
| Market | rhythm, line | reworded 2026-10-30 (owner approved): arches along the top floor, the two stairs climb toward the middle; source is the PublicMarketBP1 and BP2 blueprints the model is built from |
| Lomi King | color, texture | approved line; bamboo screen is built |
| Cafe | line, texture | approved line; fascia line and slatted chairs |
| Carmel | emphasis, space | rewritten: the old line said "tall arched windows above the entry", which does not match the built facade (rose window and niche above the portico) |
| Outlets | shape | approved line plus "shape" |
| Farm | none by word (curve against flat walls) | approved line, merged to two sentences ("rough texture" dropped) |
| Malarayat | color | approved line plus the red-brown color line |
| Tagbakin | none by word (repeating dock posts) | approved line, "on the model" removed |
| City Hall | shape, rhythm, space | new |
Decision: approve, or point me to a site whose line you want changed.

## 9. Credits draft (written into `CreditsData` and `content/site_credits.md` in Slice 3b, only after you approve)
Add the PDF's 25 references as the sources behind the new text, by site:
Cathedral [16][17]; Market [14][15]; Lomi King [6][7][8][9]; Cafe [5][10][11][12][13]; Carmel [23][24];
Outlets [18]; Farm [19][20]; Malarayat [20][21][22]; Tagbakin [20][25]; City Hall (new entry) [1][2][3][4][5].
The URLs are copied from the PDF by script (not retyped). Still needed from you: a credit line for your 3D blueprints
(wording yours) and the source or "my own screenshot" for the City Hall `.avif` photos and the screenshots.

## 10. Left out on purpose
- Slice 2 does not change `SiteData`, `CreditsData`, `BuildCheck`, `requiredProps` or any in-game script. The display
  lists stay in `TourContent.displayProps`; each structure slice promotes its own list into `requiredProps` together
  with the build, so BuildCheck is not red for props that do not exist yet.
- Outfit textures are drawn (`tools/outfit_textures.py`, 22 images) but kept out of the repo and not uploaded.

## What I need from you at the start of the next session
1. Approve (or edit) sections 1 to 8, with the open questions in 2, 3, 4, 5 and 7.
2. The blueprint credit wording and the City Hall photo source (section 9).
3. OK or not to upload the outfit textures to your Roblox account (Slice 12 uses them).

## 11. Owner decisions (2026-10-26)
- Sections 1, 6, 7 and 8 approved as written.
- Market name, both: the guide's dialogue uses the PDF name "Lipa City Public Market"; the sign and billboard keep
  "Candido B. Lopez Memorial Public Market" (still [VERIFY]).
- Ate Joy wrap-up: "a little sunburnt" becomes "a little sun-kissed".
- Tagbakin billboard: "Lipa's lakeside side" becomes "Lipa's lakeside spot" (the PDF prints "side").
- The other section 2 lines stay [VERIFY].
- ASCII-only text is kept.
- Jun's change ("Hey there!") is confirmed.
- SiteData guideName takes the PDF names in Slice 3b.
