import { Type } from "@earendil-works/pi-ai";
import { mkdir, readdir, readFile, realpath, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { spawn } from "node:child_process";

const MAX_FILE_BYTES = 200_000;

export function computerTools(computerDirectory) {
  return [
    {
      name: "computer_list",
      label: "List computer files",
      description: "List files in this agent's private computer workspace.",
      promptSnippet: "List files in your private computer workspace",
      parameters: Type.Object({ path: Type.Optional(Type.String({ maxLength: 1_000, description: "Relative directory path, default ." })) }),
      execute: async (_id, params) => toolResult(() => listFiles(computerDirectory, params.path || "."), { path: params.path || "." }),
    },
    {
      name: "computer_read",
      label: "Read computer file",
      description: "Read a UTF-8 text file from this agent's private computer workspace.",
      promptSnippet: "Read a private computer file",
      parameters: Type.Object({ path: Type.String({ minLength: 1, maxLength: 1_000, description: "Relative file path" }) }),
      execute: async (_id, params) => toolResult(() => readText(computerDirectory, params.path), { path: params.path }),
    },
    {
      name: "computer_write",
      label: "Write computer file",
      description: "Write a UTF-8 text file in this agent's private computer workspace. Paths outside the workspace are blocked.",
      promptSnippet: "Write a private computer file",
      parameters: Type.Object({
        path: Type.String({ minLength: 1, maxLength: 1_000, description: "Relative file path" }),
        content: Type.String({ maxLength: MAX_FILE_BYTES, description: "File contents" }),
      }),
      execute: async (_id, params) => toolResult(() => writeText(computerDirectory, params.path, params.content), { path: params.path }),
    },
    {
      name: "computer_exec",
      label: "Run isolated command",
      description: "Run a command in this agent's isolated computer. It has no network access and can only write its private workspace.",
      promptSnippet: "Run a network-isolated terminal command in your private computer",
      promptGuidelines: ["Use computer_exec for local work only. It cannot access the network."],
      parameters: Type.Object({ command: Type.String({ minLength: 1, maxLength: 4_000, description: "Shell command to run in the private workspace" }) }),
      execute: async (_id, params) => toolResult(() => runComputer(computerDirectory, "exec", params.command), { command: params.command }),
    },
    {
      name: "computer_browser",
      label: "Open isolated browser",
      description: "Open a public web page in this agent's isolated browser and return readable text. It requires a configured restricted egress network.",
      promptSnippet: "Open a public web page in your isolated browser",
      parameters: Type.Object({ url: Type.String({ minLength: 1, maxLength: 2_000, description: "Public HTTP(S) URL" }) }),
      execute: async (_id, params) => toolResult(() => runComputer(computerDirectory, "browser", params.url), { url: params.url }),
    },
  ];
}

async function listFiles(root, relativePath) {
  const directory = await existingWorkspacePath(root, relativePath);
  const entries = await readdir(directory, { withFileTypes: true });
  return entries.slice(0, 100).map((entry) => `${entry.isDirectory() ? "dir" : "file"} ${entry.name}`).join("\n") || "The directory is empty.";
}

async function readText(root, relativePath) {
  const file = await existingWorkspacePath(root, relativePath);
  const details = await stat(file);
  if (!details.isFile()) throw new Error("That path is not a file.");
  if (details.size > MAX_FILE_BYTES) throw new Error("That file is too large to read.");

  return readFile(file, "utf8");
}

async function writeText(root, relativePath, content) {
  const file = workspacePath(root, relativePath);
  await mkdir(path.dirname(file), { recursive: true });
  await existingWorkspacePath(root, path.relative(root, path.dirname(file)) || ".");
  await writeFile(file, content, "utf8");
  return `Wrote ${Buffer.byteLength(content)} bytes to ${relativePath}.`;
}

async function existingWorkspacePath(root, relativePath) {
  await mkdir(root, { recursive: true });
  const rootPath = await realpath(root);
  const candidate = workspacePath(rootPath, relativePath);
  const resolved = await realpath(candidate);
  if (!within(rootPath, resolved)) throw new Error("Paths outside the private workspace are blocked.");

  return resolved;
}

function workspacePath(root, relativePath) {
  if (path.isAbsolute(relativePath)) throw new Error("Use a relative workspace path.");

  const candidate = path.resolve(root, relativePath);
  if (!within(root, candidate)) throw new Error("Paths outside the private workspace are blocked.");

  return candidate;
}

function within(root, candidate) {
  return candidate === root || candidate.startsWith(`${root}${path.sep}`);
}

function runComputer(computerDirectory, action, value) {
  return new Promise((resolve, reject) => {
    const child = spawn("node", [ "script/agent_computer.mjs", action, computerDirectory, value ], {
      cwd: process.cwd(),
      env: process.env,
      stdio: [ "ignore", "pipe", "pipe" ],
    });
    let output = "";
    let error = "";
    child.stdout.on("data", (chunk) => { output += chunk; });
    child.stderr.on("data", (chunk) => { error += chunk; });
    const timeout = setTimeout(() => child.kill("SIGKILL"), 35_000);

    child.on("error", reject);
    child.on("close", (code) => {
      clearTimeout(timeout);
      if (code === 0) resolve(output.slice(0, 20_000).trim() || "Command completed.");
      else reject(new Error((error || "The isolated computer could not complete the request.").trim().slice(0, 1_000)));
    });
  });
}

async function toolResult(operation, details) {
  try {
    return { content: [{ type: "text", text: await operation() }], details };
  } catch (error) {
    return { content: [{ type: "text", text: `Computer tool error: ${error.message}` }], details: { ...details, error: true } };
  }
}
