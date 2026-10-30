# NPC Guide Dialogue: Lipa City Landmarks (APPROVED, Slice 12)

Status: **approved 2026-10-17**. The user delegated the open decisions: names and details visible in the reference photos are taken as truth, and anything else was decided from the sources below. This text is loaded into `src/ReplicatedStorage/LipaShared/SiteData.luau` (`dialogue`, `panelText`) and into the in-world labels built by `builders/site05.luau`, `site06.luau` and `site09.luau`. If a line here changes, change SiteData and re-run `tests/SiteData_Test.luau`.

Voice: plain, friendly student guide. Each site has four lines in order: (a) what the place is, (b) what it represents today, (c) one art or architecture observation that describes what is **built on the model**, (d) a "Look at..." prompt pointing at the model. Carmel has six lines so the founding, the 1948 reports, the 1951 finding and the 2015 developments each get their own line.

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
| Lomi King sign, menu banner, parking sign | Read from the group's Lomi King Architectural Blueprint Board and a January 2026 Google Street View view (rebuild 2026-10-31); earlier read from `Lomi_King_Front_Oblique_2015.jpg` |
| "% THE OUTLETS" slatted entrance sign | Read from `Outlets_Entrance_Sign.jpg` |
| Plaza Independencia, Metropolitan Cathedral of San Sebastian | From the user's reference folder and details document. `lipa.gov.ph/city/` no longer carries a plaza description (it now shows a news item), so the plaza sentence stays general. |

Pages that returned HTTP 403 and could not be opened: the Inquirer (`newsinfo.inquirer.net/1593317`), BusinessWorld (`bworldonline.com/?p=474580`), Esquire Philippines. Not opened and not relied on for any claim: Wikipedia "Lipa Cathedral", The Poor Traveler, PIA, Traveloka, Primer, Wikivoyage, Architizer, Outlook Traveller, Benjie Layug.

## 1. Plaza Independencia and Metropolitan Cathedral of San Sebastian
- (a) Welcome to the Metropolitan Cathedral of San Sebastian in Lipa. Down the steps from this forecourt is Plaza Independencia, the city's open square.
- (b) Today the plaza is where Lipa gathers for events and everyday socializing, and the cathedral anchors the city's religious life.
- (c) The tower narrows tier by tier as it rises to a ribbed cupola. Paired columns repeat across the front, and warm yellow walls sit against mauve-grey trim and red roofs.
- (d) Look at the bell tower on the model and count its tiers. Then find the triangular pediment and the paired columns on the front.

The earlier draft's (c)/(d) described the rear apse from an aerial photo, which a player in the plaza cannot see. The sources disagree on the cathedral's style, so no style is named.

Revised in Slice 14 (the user left the wording to the assistant) after the model was rebuilt from 2023-2025 photos: the facade has paired round columns, not pilasters; the walls are butter yellow, not cream; and the guide stands on the forecourt above Plaza Independencia, which is down a flight of steps (28 Dec 2025 drone photos). No new facts were added.

## 2. Candido B. Lopez Memorial Public Market
- (a) This is the Candido B. Lopez Memorial Public Market, the palengke in Lipa where people shop for produce, food, and daily needs.
- (b) It shows everyday Lipa through food vendors, produce, coffee, and small businesses. The facade photo dates from 2014, so it may look different today.
- (c) The long front repeats rounded arches along the ground floor, and the rows of windows above repeat the same rhythm. The building feels steady and orderly.
- (d) Look at the arched openings along the front. Count how many repeat, and notice how the stairs break up the line.

The reference photos date from 2010 to 2014. The in-world price boards are labelled as sample prices.

## 3. Lomi King
- (a) This is Lomi King, one of Lipa's lomi houses, where people sit down together for a hot bowl of lomi noodles.
- (b) Lomi is part of Lipa's food culture, and sharing a bowl is a social way to eat together. Our model follows a 2026 Street View image and a drawn board, so details may differ.
- (c) The front is a bold orange sign band, with a menu banner and globe lamps below. The bright colors pull the eye to the name before anything else.
- (d) Look at the sign band above the entrance on the model. Follow the menu boards down to the doorway.

## 4. Cafe de Lipa (Tibig/STAR branch)
- (a) This is Cafe de Lipa, a coffee shop linked to kapeng barako, the strong coffee Batangas is known for.
- (b) Coffee links Lipa's farming past with today's cafe culture. This model shows the Tibig/STAR branch. The interior is a representative display, not a copy.
- (c) The glass front glows warm against the dark fascia, and lit yellow letters spell the name above it, so the cafe looks inviting from the street.
- (d) Look at the glass storefront on the model. Notice how the warm light spills out onto the outdoor seating.

Only the Tibig/STAR photo is used; the other two streetfront photos are not confirmed as the same branch. The dialogue spells "Cafe" without the accent (byte slicing); the site name and InfoPanel keep "Café".

## 5. Monastery of Our Lady of Mount Carmel
- (a) Hi, I'm a volunteer guide and a pilgrim, not a nun. This is the Monastery of Our Lady of Mount Carmel in Lipa, a Carmelite community founded on May 31, 1946.
- (b1) In 1948, Teresita Castillo reported apparitions of Mary here. The reports drew pilgrims to Lipa, and local devotion grew around them.
- (b2) In 1951, a commission of Filipino bishops found no supernatural character in the events. The Holy See has since reaffirmed that judgment.
- (b3) In 2015, Archbishop Ramon Arguelles declared the events worthy of belief. The Holy See rejected that declaration, and he later withdrew it.
- (c) The entry arch and the tall arched windows repeat in a steady rhythm, and the stepped top of the front wall gives the facade a clear shape.
- (d) Look at the entry arch on the model. Find the arched windows above it and notice how they repeat the same shape.

Panel text: "A Carmelite monastery founded on May 31, 1946, a place of prayer and pilgrimage in Lipa."

In-world history panels (three, in the prayer garden): "1946 - Founding" / "Carmelite community founded on May 31, 1946."; "1948 - Reported apparitions" / "Teresita Castillo reported apparitions of Mary. The reports drew pilgrims to Lipa."; "1951 and 2015 - Church rulings" / "1951: bishops found no supernatural basis. 2015: Arguelles' declaration was rejected by the Holy See."

The shrine tablets read "THE TEN COMMANDMENTS", as in `Outdoor_Shrine_Structure.jpg`.

## 6. The Outlets at LIMA Estate and Aboitiz Pitch
- (a) This is The Outlets at LIMA Estate, an outdoor shopping street with a covered walkway, beside the Aboitiz Pitch. LIMA Estate spans Lipa and Malvar.
- (b) It was called The Outlets at Lipa until it was renamed in 2025. It stands for modern shopping, dining, and an economy tied to growing industry.
- (c) Warm orange timber cladding sits against white walls and dark glass. A deep overhang and canopy cast shade and run in a long horizontal line along the shops.
- (d) Look at the orange shop block on the model. Follow the canopy along the covered walkway, then find the slatted sign by the road.

The source press release writes "The Outlets @LIMA Estate"; the site name stays "The Outlets at LIMA Estate" (details document). In-world: estate model plinth "A small model of the estate. LIMA Estate spans Lipa and Malvar."; map panel footer "Schematic map, not to scale. The estate spans Lipa and Malvar." The pitch's own renaming is not confirmed.

## 7. The Farm at San Benito
- (a) This is The Farm at San Benito, a wellness resort in Lipa with gardens, a lagoon, and places to stay.
- (b) It represents Lipa's wellness tourism today, with gardens, dining, and organized activities like yoga. Visits involve a booking or paid services.
- (c) A round thatched cone roof sits beside the straight-edged villa. Its curve and rough texture contrast with the flat, geometric walls, so each makes the other stand out.
- (d) Look at the thatched pavilion on the model. Then follow the patterned path and notice where it leads your eye.

Listings give the barangay as Tipacan (Marriott) and Tipakan (the details document); no line names a barangay.

## 8. Mount Malarayat Golf and Country Club
- (a) This is Mount Malarayat Golf and Country Club, in Barangay Dagatan, Lipa. It has a golf course with a view of the mountains.
- (b) Today it is a place for golf, hotel stays, and leisure. Access depends on membership or a booking.
- (c) One large hipped roof dominates the clubhouse. A smaller gabled entry and a lower side wing have roofs of their own, and the red-brown roofs stand out against the green lawn.
- (d) Look at the big roof on the clubhouse model. Find the entry gable and the wing roof, then notice the repeated windows and columns below.

## 9. Tagbakin, Barangay Halang
- (a) This is Tagbakin, a sitio in Barangay Halang, on Lipa's lakeside.
- (b) The city calls Halang one of its developed tourist spots, and says the waters off Tagbakin have long teemed with tawilis, a well-known local fish.
- (c) A long dock leads the eye across the water toward the volcano. Beside it, a grey building with stepped roofs and a row of windows stands against the curve of the shore.
- (d) Look along the dock on the model and count the posts that repeat. Then find the volcano beyond the water and the windows on the lakeside building.

The shoreline building is described only by its form. The in-world map board reads "Tagbakin sits on the shore of Taal Lake in Barangay Halang, Lipa City. Halang is one of the city's developed tourist spots."
