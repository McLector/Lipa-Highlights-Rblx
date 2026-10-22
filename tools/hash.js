// hash.js: Studio-vs-disk comparison. Prints "<name> <bytes> <newlines> <djb2>" for each file, with CRLF folded to LF first.
// Usage: node tools/hash.js tests/qa_check.luau src/StarterPlayer/StarterPlayerScripts/GuideClient.client.luau
// In Studio, print the same four numbers for the script's Source (LF-normalised) and compare; they must be identical.
//   local s = inst.Source:gsub("\r\n", "\n"); local x = 5381
//   for i = 1, #s do x = (x * 33 + s:byte(i)) % 4294967296 end
//   local _, nl = s:gsub("\n", ""); print(inst.Name, #s, nl, x)
const fs = require("fs");
const path = require("path");
if (process.argv.length < 3) {
  console.error("usage: node tools/hash.js <file> [file...]");
  process.exit(2);
}
let failed = false;
for (const f of process.argv.slice(2)) {
  try {
    const text = fs.readFileSync(f, "utf8").replace(/\r\n/g, "\n");
    const bytes = Buffer.from(text, "utf8");
    let h = 5381;
    for (const b of bytes) h = (h * 33 + b) >>> 0;
    console.log(path.basename(f), bytes.length, (text.match(/\n/g) || []).length, h);
  } catch (e) {
    console.error("cannot read " + f + ": " + e.message);
    failed = true;
  }
}
process.exit(failed ? 1 : 0);
