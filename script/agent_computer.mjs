import { spawn } from "node:child_process";
import { mkdir, realpath } from "node:fs/promises";
import path from "node:path";
import process from "node:process";

const [ action, workspace, value ] = process.argv.slice(2);
if (!action || !workspace || !value || ![ "exec", "browser" ].includes(action)) throw new Error("Usage: agent_computer.mjs <exec|browser> <workspace> <value>");

await mkdir(workspace, { recursive: true });
const workspacePath = await realpath(workspace);
const image = process.env.HUMANE_COMPUTER_IMAGE || "humane-agent-computer:latest";
const user = process.env.HUMANE_COMPUTER_USER || `${process.getuid?.() || 1000}:${process.getgid?.() || 1000}`;
const common = [
  "run", "--rm", "--init",
  "--cap-drop", "ALL",
  "--security-opt", "no-new-privileges",
  "--pids-limit", "128",
  "--memory", "512m",
  "--cpus", "1",
  "--read-only",
  "--tmpfs", "/tmp:rw,noexec,nosuid,size=128m",
  "--mount", `type=bind,src=${workspacePath},dst=/workspace`,
  "--workdir", "/workspace",
  "--user", user,
  "--env", "HOME=/tmp",
];

if (action === "exec") {
  await docker([ ...common, "--network", "none", image, "bash", "-lc", value ]);
} else {
  const network = process.env.HUMANE_COMPUTER_NETWORK;
  if (!network) throw new Error("Browser access requires HUMANE_COMPUTER_NETWORK, a restricted egress-only Docker network.");
  await docker([ ...common, "--network", network, image, "node", "/opt/humane/browser.mjs", value ]);
}

function docker(args) {
  return new Promise((resolve, reject) => {
    const child = spawn("docker", args, { stdio: [ "ignore", "pipe", "pipe" ] });
    child.stdout.pipe(process.stdout);
    child.stderr.pipe(process.stderr);
    child.on("error", () => reject(new Error("Docker is unavailable. Start Docker and build the Humane computer image.")));
    child.on("close", (code) => code === 0 ? resolve() : reject(new Error("The isolated computer failed.")));
  });
}
