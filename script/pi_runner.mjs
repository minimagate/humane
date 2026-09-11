import path from "node:path";
import process from "node:process";
import {
  createAgentSession,
  DefaultResourceLoader,
  ModelRuntime,
  SessionManager,
  SettingsManager,
} from "@earendil-works/pi-coding-agent";

const input = JSON.parse(await readStdin());
const agentSkillsDirectory = path.join(input.agent_directory, ".agents", "skills");
const settingsManager = SettingsManager.inMemory({ compaction: { enabled: false } });
const loader = new DefaultResourceLoader({
  cwd: input.agent_directory,
  agentDir: input.agent_dir,
  settingsManager,
  agentsFilesOverride: (current) => ({
    agentsFiles: current.agentsFiles.filter((file) => file.path === path.join(input.agent_directory, "AGENTS.md")),
  }),
  skillsOverride: (current) => ({
    skills: current.skills.filter((skill) => skill.filePath.startsWith(`${agentSkillsDirectory}${path.sep}`)),
    diagnostics: current.diagnostics,
  }),
});
await loader.reload();

const modelRuntime = await ModelRuntime.create({
  authPath: path.join(input.agent_dir, "auth.json"),
  modelsPath: null,
  refreshOnCreate: false,
});
await modelRuntime.setRuntimeApiKey("openai", process.env.OPENAI_API_KEY);
const model = modelRuntime.getModel("openai", input.model);
if (!model) throw new Error(`Pi does not know the configured model: ${input.model}`);

const { session } = await createAgentSession({
  cwd: input.agent_directory,
  agentDir: input.agent_dir,
  modelRuntime,
  model,
  resourceLoader: loader,
  sessionManager: SessionManager.inMemory(),
  settingsManager,
});

let content = "";
session.subscribe((event) => {
  if (event.type === "message_update" && event.assistantMessageEvent.type === "text_delta") {
    content += event.assistantMessageEvent.delta;
    process.stdout.write(`${JSON.stringify({ type: "delta", content: event.assistantMessageEvent.delta })}\n`);
  }
});

await session.prompt(input.prompt);
session.dispose();
process.stdout.write(JSON.stringify({ type: "complete", content: content.trim() }) + "\n");

async function readStdin() {
  let text = "";
  for await (const chunk of process.stdin) text += chunk;
  return text;
}
