import { Type } from "@earendil-works/pi-ai";
import dns from "node:dns/promises";
import http from "node:http";
import https from "node:https";

const MAX_FETCH_BYTES = 1_000_000;
const MAX_FETCH_CHARACTERS = 12_000;

export function webTools() {
  return [
    {
      name: "web_search",
      label: "Web search",
      description: "Search the public web. Use it for current or sourced information, then open useful results before making factual claims.",
      promptSnippet: "Search the public web",
      promptGuidelines: ["For up-to-date factual claims, search first and cite the URLs you used."],
      parameters: Type.Object({
        query: Type.String({ minLength: 1, maxLength: 500, description: "The search query" }),
        count: Type.Optional(Type.Integer({ minimum: 1, maximum: 10, description: "Maximum results, default 5" })),
      }),
      executionMode: "parallel",
      execute: async (_toolCallId, params) => toolResult(() => search(params.query, params.count || 5), { query: params.query }),
    },
    {
      name: "web_fetch",
      label: "Open web page",
      description: "Open a public HTTP(S) page and return its readable text. Internal, local, and private-network destinations are blocked.",
      promptSnippet: "Open a public web page",
      promptGuidelines: ["Use web_fetch on a search result before relying on it. Never request private or local URLs."],
      parameters: Type.Object({
        url: Type.String({ minLength: 1, maxLength: 2_000, description: "A public http or https URL" }),
      }),
      executionMode: "parallel",
      execute: async (_toolCallId, params) => toolResult(() => fetchPage(params.url), { url: params.url }),
    },
  ];
}

async function search(query, count) {
  const apiKey = process.env.BRAVE_SEARCH_API_KEY;
  if (!apiKey) throw new Error("Web search is unavailable because BRAVE_SEARCH_API_KEY is not configured.");

  const url = new URL("https://api.search.brave.com/res/v1/web/search");
  url.searchParams.set("q", query);
  url.searchParams.set("count", String(count));

  const response = await fetch(url, {
    headers: { "Accept": "application/json", "X-Subscription-Token": apiKey },
    signal: AbortSignal.timeout(15_000),
  });
  if (!response.ok) throw new Error(`Web search returned ${response.status}.`);

  const payload = await response.json();
  const results = Array.isArray(payload.web?.results) ? payload.web.results : [];
  if (results.length === 0) return "No web results found.";

  return results.map((result, index) => [
    `${index + 1}. ${clean(result.title)}`,
    `URL: ${result.url}`,
    clean(result.description),
  ].filter(Boolean).join("\n")).join("\n\n");
}

async function fetchPage(rawUrl, redirects = 0) {
  if (redirects > 3) throw new Error("The page redirected too many times.");

  const { url, address } = await publicUrl(rawUrl);
  const response = await requestPage(url, address);

  if ([ 301, 302, 303, 307, 308 ].includes(response.status)) {
    const location = Array.isArray(response.headers.location) ? response.headers.location[0] : response.headers.location;
    if (!location) throw new Error("The page redirected without a location.");

    return fetchPage(new URL(location, url).toString(), redirects + 1);
  }

  if (!response.ok) throw new Error(`The page returned ${response.status}.`);
  const contentType = response.headers["content-type"] || "";
  if (!/(text\/html|text\/plain|application\/json|application\/xml|text\/xml)/i.test(contentType)) {
    throw new Error("The page did not return readable text.");
  }

  const contentLength = Number(response.headers["content-length"]);
  if (Number.isFinite(contentLength) && contentLength > MAX_FETCH_BYTES) throw new Error("The page is too large to open.");

  return [`Source: ${url}`, cleanHtml(response.body).slice(0, MAX_FETCH_CHARACTERS)].join("\n\n");
}

async function publicUrl(rawUrl) {
  let url;
  try {
    url = new URL(rawUrl);
  } catch {
    throw new Error("Provide a valid public HTTP(S) URL.");
  }

  if (![ "http", "https" ].includes(url.protocol.slice(0, -1)) || url.username || url.password) {
    throw new Error("Only public HTTP(S) URLs without credentials are allowed.");
  }
  if (url.port && ![ "80", "443" ].includes(url.port)) throw new Error("Only standard web ports are allowed.");
  if (blockedHostname(url.hostname)) throw new Error("Local and private hosts are blocked.");

  const addresses = await dns.lookup(url.hostname, { all: true, verbatim: true });
  if (addresses.length === 0 || addresses.some((entry) => privateAddress(entry.address))) {
    throw new Error("Local and private hosts are blocked.");
  }

  return { url, address: addresses[0].address };
}

function requestPage(url, address) {
  return new Promise((resolve, reject) => {
    const client = url.protocol === "https:" ? https : http;
    const request = client.request({
      protocol: url.protocol,
      hostname: address,
      port: url.port || undefined,
      path: `${url.pathname}${url.search}`,
      method: "GET",
      headers: {
        "Host": url.host,
        "User-Agent": "HumaneAgent/1.0 (+https://github.com/michelangelogubinelli/humane)",
      },
      servername: url.hostname,
      timeout: 15_000,
    }, (response) => {
      const chunks = [];
      let bytes = 0;
      response.on("data", (chunk) => {
        bytes += chunk.length;
        if (bytes > MAX_FETCH_BYTES) {
          response.destroy(new Error("The page is too large to open."));
          return;
        }
        chunks.push(chunk);
      });
      response.on("end", () => resolve({ status: response.statusCode || 0, headers: response.headers, body: Buffer.concat(chunks).toString("utf8") }));
      response.on("error", reject);
    });
    request.on("timeout", () => request.destroy(new Error("The page took too long to open.")));
    request.on("error", reject);
    request.end();
  });
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

function cleanHtml(text) {
  return clean(text.replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, " ").replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " "));
}

function clean(text) {
  return String(text || "").replace(/\s+/g, " ").trim();
}

async function toolResult(operation, details) {
  try {
    return { content: [{ type: "text", text: await operation() }], details };
  } catch (error) {
    return { content: [{ type: "text", text: `Web tool error: ${error.message}` }], details: { ...details, error: true } };
  }
}
