# NPC Guide Dialogue: Lipa City Landmarks (APPROVED, Slice 12)

Status: **approved 2026-10-17; shortened 2026-10-22** after the professor asked for 2-3 sentence descriptions (drafted by Shana with AI help; the repo owner approves the wording in the PR). The shortened lines reuse only facts already approved below; nothing new was added. Cut from the dialogue: The Farm's "places to stay", Carmel's "local devotion grew around them", Tagbakin's "a well-known local fish", Cafe's "the interior is a representative display" (the InfoPanel still says it) and Outlets' "LIMA Estate spans Lipa and Malvar" (the InfoPanel and in-world signs still say it). The user delegated the open decisions: names and details visible in the reference photos are taken as truth, and anything else was decided from the sources below. This text is loaded into `src/ReplicatedStorage/LipaShared/SiteData.luau` (`dialogue`, `panelText`) and into the in-world labels built by `builders/site05.luau`, `site06.luau` and `site09.luau`. If a line here changes, change SiteData and re-run `tests/SiteData_Test.luau`.

Voice: plain, friendly student guide. Each site has two lines: (a) what the place is and what it represents today, (b) a "Look at..." line that points at one art or architecture feature **built on the model**. Carmel has four lines: (a), then (h1) the 1948 reports with the 1951 finding and (h2) the 2015 declaration with the Holy See's rejection, so no reported event appears without the Church ruling on it, then (b). The "Did you know?" trivia (next feedback item) will go between (a) and (b).

Until 2026-10-22 each site had four lines (what it is, what it represents, an art observation, the Look prompt) and Carmel had six; the old text is in git history.

Rules enforced by tests: every line is 220 bytes or fewer, **ASCII only** (the typewriter in GuideClient slices by byte, so accented letters would be cut mid-glyph), no tags or placeholders, no glamping claim anywhere, last line starts with "Look".

## What was checked, and how

"Opened" means the page was fetched and the sentence read. "Snippet" means only a search summary was seen.

| Claim | Status |
|---|---|
| Carmel founded 31 May 1946 | Opened: carmelitaniscalzi.com ("Founded on 31 May 1946") |
| 1948 reports to Teresita Castillo | Opened: Wikipedia "Mary, Mediatrix of All Grace"; catholic.org (id 72779) |
| 1951 finding by six Filipino bishops, 11 April 1951 | Opened: Wikipedia; catholic.org |
| Holy See reaffirmed the negative judgment | Opened: catholic.org ("reiterated its negative judgement"); Wikipedia (decree overruled the archbishop) |
| Arguelles declared "worthy of belief" (12 Sept 2015), later withdrew it | Opened: catholic.org; Wikipedia (retracted 1 June 2016) |
| A December 2015 Vatican decree ordering commissions disbanded | **Not used.** Only a search snippet; no opened page supports it. |
| "Papal approval of the 1951 finding is disputed" | **Not used.** The opened pages do not say so. |
| Halang is "developed as one of the tourist spots in the city"; Tagbakin is a sitio of Halang; its waters "always teemed with" tawilis | Opened: lipa.gov.ph/barangay-profiles |
| Glamping at Tagbakin | **Not on the city page**, and the photo notes say the shoreline building is not verified as glamping. Left out of every line and in-world sign. |
| Mount Malarayat: name, Barangay Dagatan, Lipa City, golf, hotel, membership or booking | Opened: malarayat.com/contact |
| The Farm at San Benito: Lipa, gardens, Big Lagoon, wellness activities, booking | Opened: marriott.com experiences page (villas are not mentioned there, so the line says "places to stay") |
| Outlets renamed in 2025; the Aboitiz Pitch | Opened: aboitizeconomicestates.com (press release 4 March 2025, "officially rebranding as The Outlets @LIMA Estate") |
| LIMA Estate spans Lipa and Malvar | Snippet (several Aboitiz-linked results) and `05_The_Outlets_LIMA/REFERENCE_NOTES.txt` |
| Market name "Candido B. Lopez Memorial Public Market" | Read from the sign in `Market_Facade_2014.jpg` (checked again 2026-10-17). A web search found only "Lipa City Public Market". |
| "cafedelipa" sign, Tibig/STAR branch | Read from `Cafe_de_Lipa_Tibig_STAR_Entrance_and_Outdoor_Seating_Night.jpg` (lowercase, lit yellow letters on a dark fascia) |
| Lomi King sign, menu banner, parking sign | Read from `Lomi_King_Front_Oblique_2015.jpg` |
| "% THE OUTLETS" slatted entrance sign | Read from `Outlets_Entrance_Sign.jpg` |
| Plaza Independencia, Metropolitan Cathedral of San Sebastian | From the user's reference folder and details document. `lipa.gov.ph/city/` no longer carries a plaza description (it now shows a news item), so the plaza sentence stays general. |

Pages that returned HTTP 403 and could not be opened: the Inquirer (`newsinfo.inquirer.net/1593317`), BusinessWorld (`bworldonline.com/?p=474580`), Esquire Philippines. Not opened and not relied on for any claim: Wikipedia "Lipa Cathedral", The Poor Traveler, PIA, Traveloka, Primer, Wikivoyage, Architizer, Outlook Traveller, Benjie Layug.

## 1. Plaza Independencia and Metropolitan Cathedral of San Sebastian
- (a) Welcome to the Metropolitan Cathedral of San Sebastian, the center of Lipa's religious life. Down the steps from this forecourt is Plaza Independencia, where the city gathers for events.
- (b) Look at the bell tower and count its tiers as it narrows up to the cupola. Then find the paired columns and the warm yellow walls on the front.

The earlier draft's (c)/(d) described the rear apse from an aerial photo, which a player in the plaza cannot see. The sources disagree on the cathedral's style, so no style is named.

Revised in Slice 14 (the user left the wording to the assistant) after the model was rebuilt from 2023-2025 photos: the facade has paired round columns, not pilasters; the walls are butter yellow, not cream; and the guide stands on the forecourt above Plaza Independencia, which is down a flight of steps (28 Dec 2025 drone photos). No new facts were added.

## 2. Candido B. Lopez Memorial Public Market
- (a) This is the Candido B. Lopez Memorial Public Market, the palengke where Lipa shops for produce, food, and daily needs. Our facade photo is from 2014, so it may look different today.
- (b) Look at the rounded arches repeating along the front, with rows of windows above them. Count the arches, and notice how the stairs break up the line.

The reference photos date from 2010 to 2014. The in-world price boards are labelled as sample prices.

## 3. Lomi King
- (a) This is Lomi King, one of Lipa's lomi houses. Lomi is part of the city's food culture, and sharing a hot bowl is a social way to eat. Our photo is from 2015, so the front may have changed.
- (b) Look at the bold orange sign band above the entrance. Its bright colors pull your eye to the name first. Then follow the menu boards down to the doorway.

## 4. Cafe de Lipa (Tibig/STAR branch)
- (a) This is Cafe de Lipa, linked to kapeng barako, the strong coffee Batangas is known for. Coffee links Lipa's farming past with today's cafe culture. This model shows the Tibig/STAR branch.
- (b) Look at the glass storefront glowing warm under the dark fascia and the lit yellow letters. Notice how the light spills out onto the outdoor seating.

Only the Tibig/STAR photo is used; the other two streetfront photos are not confirmed as the same branch. The dialogue spells "Cafe" without the accent (byte slicing); the site name and InfoPanel keep "Café".

## 5. Monastery of Our Lady of Mount Carmel
- (a) Hi, I'm a volunteer guide and a pilgrim, not a nun. This is the Monastery of Our Lady of Mount Carmel in Lipa, a Carmelite community founded on May 31, 1946.
- (h1) In 1948, Teresita Castillo reported apparitions of Mary here, drawing pilgrims to Lipa. In 1951, a commission of Filipino bishops found no supernatural character in the events.
- (h2) The Holy See has since reaffirmed that 1951 judgment. In 2015, Archbishop Ramon Arguelles declared the events worthy of belief. The Holy See rejected that, and he later withdrew it.
- (b) Look at the entry arch and the tall arched windows above it, repeating the same shape. The stepped top of the front wall gives the facade its clear outline.

Panel text: "A Carmelite monastery founded on May 31, 1946, a place of prayer and pilgrimage in Lipa."

In-world history panels (three, in the prayer garden): "1946 - Founding" / "Carmelite community founded on May 31, 1946."; "1948 - Reported apparitions" / "Teresita Castillo reported apparitions of Mary. The reports drew pilgrims to Lipa."; "1951 and 2015 - Church rulings" / "1951: bishops found no supernatural basis. 2015: Arguelles' declaration was rejected by the Holy See."

The shrine tablets read "THE TEN COMMANDMENTS", as in `Outdoor_Shrine_Structure.jpg`.

## 6. The Outlets at LIMA Estate and Aboitiz Pitch
- (a) This is The Outlets at LIMA Estate, called The Outlets at Lipa until 2025. Its outdoor shops beside the Aboitiz Pitch stand for modern shopping, dining, and an economy tied to growing industry.
- (b) Look at the orange timber block against the white walls and dark glass. Follow the long canopy along the covered walkway, then find the slatted sign by the road.

The source press release writes "The Outlets @LIMA Estate"; the site name stays "The Outlets at LIMA Estate" (details document). In-world: estate model plinth "A small model of the estate. LIMA Estate spans Lipa and Malvar."; map panel footer "Schematic map, not to scale. The estate spans Lipa and Malvar." The pitch's own renaming is not confirmed.

## 7. The Farm at San Benito
- (a) This is The Farm at San Benito, a wellness resort in Lipa with gardens, a lagoon, and activities like yoga. It shows Lipa's wellness tourism today. Visits involve a booking or paid services.
- (b) Look at the round thatched pavilion beside the straight-edged villa. Its curve and rough texture contrast with the flat walls. Then follow the patterned path.

Listings give the barangay as Tipacan (Marriott) and Tipakan (the details document); no line names a barangay.

## 8. Mount Malarayat Golf and Country Club
- (a) This is Mount Malarayat Golf and Country Club in Barangay Dagatan, Lipa, a place for golf, hotel stays, and leisure with a view of the mountains. Access depends on membership or a booking.
- (b) Look at the big hipped roof on the clubhouse, then find the smaller entry gable and the wing roof. Their red-brown color stands out against the green lawn.

## 9. Tagbakin, Barangay Halang
- (a) This is Tagbakin, a sitio in Barangay Halang on Lipa's lakeside. The city calls Halang one of its developed tourist spots, and says the waters off Tagbakin have long teemed with tawilis.
- (b) Look along the dock and count its repeating posts. The dock leads your eye across the water to the volcano, past the grey lakeside building with stepped roofs.

The shoreline building is described only by its form. The in-world map board reads "Tagbakin sits on the shore of Taal Lake in Barangay Halang, Lipa City. Halang is one of the city's developed tourist spots."
