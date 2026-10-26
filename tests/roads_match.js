// roads_match.js: proves the ROADS table in src/ReplicatedStorage/LipaShared/RoadData.luau is identical to ROADS in builders/world.luau.
// world.luau is never run (it wipes all terrain), so RoadData holds a verbatim copy and this test keeps the two in step.
// Usage: node tests/roads_match.js   (exit 0 = identical, exit 1 = mismatch or unreadable). No dependencies.
const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");

// Returns the text between the braces of `local <name> = { ... }`, matching nested braces and skipping -- comments.
function tableBody(src, name) {
  const m = new RegExp("local\\s+" + name + "\\s*=\\s*\\{").exec(src);
  if (!m) return null;
  let depth = 1;
  let i = m.index + m[0].length;
  const start = i;
  while (i < src.length && depth > 0) {
    if (src.startsWith("--", i)) {
      while (i < src.length && src[i] !== "\n") i++;
      continue;
    }
    if (src[i] === "{") depth++;
    else if (src[i] === "}") depth--;
    i++;
  }
  return depth === 0 ? src.slice(start, i - 1) : null;
}

// Parses road entries of the form { name = "X", w = 12, joinStart = true, pts = { { 0, -100 }, ... } }.
function parseRoads(src, name) {
  const body = tableBody(src, name);
  if (body === null) return null;
  const clean = body.replace(/--[^\n]*/g, "");
  const roads = [];
  const re = /\{\s*name\s*=\s*"([^"]+)"\s*,\s*w\s*=\s*(\d+)\s*,\s*(joinStart\s*=\s*true\s*,\s*)?pts\s*=\s*\{((?:\s*\{\s*-?\d+\s*,\s*-?\d+\s*\}\s*,?)+)\s*\}\s*\}/g;
  let m;
  while ((m = re.exec(clean))) {
    const pts = [...m[4].matchAll(/\{\s*(-?\d+)\s*,\s*(-?\d+)\s*\}/g)].map((p) => [Number(p[1]), Number(p[2])]);
    roads.push({ name: m[1], w: Number(m[2]), joinStart: !!m[3], pts });
  }
  // every "name =" in the body must have been parsed, so a malformed entry cannot hide
  const declared = (clean.match(/name\s*=/g) || []).length;
  if (declared !== roads.length) return null;
  return roads;
}

// Returns an array of human-readable differences (empty = identical).
function diff(a, b) {
  const out = [];
  if (a === null) return ["world.luau ROADS could not be parsed"];
  if (b === null) return ["RoadData.luau ROADS could not be parsed"];
  if (a.length !== b.length) out.push("road count " + a.length + " vs " + b.length);
  for (let i = 0; i < Math.min(a.length, b.length); i++) {
    if (JSON.stringify(a[i]) !== JSON.stringify(b[i])) out.push("road " + (i + 1) + ": " + JSON.stringify(a[i]) + " vs " + JSON.stringify(b[i]));
  }
  return out;
}

function read(rel) {
  try {
    return fs.readFileSync(path.join(ROOT, rel), "utf8");
  } catch (e) {
    return null;
  }
}

const worldSrc = read("builders/world.luau");
const dataSrc = read("src/ReplicatedStorage/LipaShared/RoadData.luau");
if (worldSrc === null || dataSrc === null) {
  console.log("FAIL: cannot read " + (worldSrc === null ? "builders/world.luau" : "RoadData.luau"));
  process.exit(1);
}
const world = parseRoads(worldSrc, "ROADS");
const data = parseRoads(dataSrc, "ROADS");
let failed = false;

// 1. the real comparison
const d = diff(world, data);
if (d.length === 0) console.log("PASS: RoadData ROADS identical to world.luau ROADS (" + world.length + " roads)");
else {
  failed = true;
  console.log("FAIL: RoadData ROADS differs from world.luau ROADS");
  d.forEach((x) => console.log("  " + x));
}

// 2. sanity: the parser found the roads we know exist
if (world && world.length === 8 && world[0].name === "A_to_Carmel") console.log("PASS: parser read world.luau (" + world.length + " roads, first " + world[0].name + ")");
else {
  failed = true;
  console.log("FAIL: parser did not read world.luau ROADS as expected");
}

// 3. negative cases on in-memory copies: each mutation must be reported as a mismatch
if (world) {
  const mutations = {
    "changed width": (r) => (r[0].w = 99),
    "dropped joinStart": (r) => (r[1].joinStart = false),
    "moved a point": (r) => (r[2].pts[1][0] += 1),
    "removed a road": (r) => r.pop(),
    "renamed a road": (r) => (r[3].name = "X"),
  };
  for (const [label, mutate] of Object.entries(mutations)) {
    const copy = JSON.parse(JSON.stringify(world));
    mutate(copy);
    if (diff(world, copy).length > 0) console.log("PASS: negative case detected (" + label + ")");
    else {
      failed = true;
      console.log("FAIL: negative case NOT detected (" + label + ")");
    }
  }
}
process.exit(failed ? 1 : 0);
