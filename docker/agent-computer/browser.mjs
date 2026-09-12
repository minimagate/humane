import { chromium } from "playwright";
import dns from "node:dns/promises";

const rawUrl = process.argv[2];
let url;
try {
  url = new URL(rawUrl);
} catch {
  throw new Error("Provide a valid public HTTP(S) URL.");
}
await publicUrl(url);

const browser = await chromium.launchPersistentContext("/workspace/.browser", { headless: true });
try {
  const page = browser.pages()[0] || await browser.newPage();
  await page.route("**/*", async (route) => {
    try {
      await publicUrl(new URL(route.request().url()));
      await route.continue();
    } catch {
      await route.abort();
    }
  });
  await page.goto(url.toString(), { waitUntil: "domcontentloaded", timeout: 20_000 });
  const title = await page.title();
  const body = await page.locator("body").innerText({ timeout: 5_000 });
  process.stdout.write(`Source: ${page.url()}\nTitle: ${title}\n\n${body.slice(0, 12_000)}`);
} finally {
  await browser.close();
}

async function publicUrl(url) {
  if (![ "http:", "https:" ].includes(url.protocol) || url.username || url.password) throw new Error("Only public HTTP(S) URLs without credentials are allowed.");
  if (url.port && ![ "80", "443" ].includes(url.port)) throw new Error("Only standard web ports are allowed.");
  if (blockedHostname(url.hostname)) throw new Error("Local and private hosts are blocked.");

  const addresses = await dns.lookup(url.hostname, { all: true, verbatim: true });
  if (addresses.length === 0 || addresses.some((entry) => privateAddress(entry.address))) throw new Error("Local and private hosts are blocked.");
}

function blockedHostname(hostname) {
  const normalized = hostname.toLowerCase();
  return normalized === "localhost" || normalized.endsWith(".localhost") || normalized.endsWith(".local") || normalized.endsWith(".internal");
}

function privateAddress(address) {
  const normalized = address.toLowerCase();
  if (normalized === "::1" || normalized === "::" || normalized.startsWith("fe80:") || normalized.startsWith("fc") || normalized.startsWith("fd")) return true;
  const octets = normalized.split(".").map(Number);
  if (octets.length !== 4 || octets.some(Number.isNaN)) return false;
  const [ first, second ] = octets;
  return first === 0 || first === 10 || first === 127 || first >= 224 || (first === 169 && second === 254) || (first === 172 && second >= 16 && second <= 31) || (first === 192 && second === 168);
}
