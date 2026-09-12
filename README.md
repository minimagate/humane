# humane

A personal AI team built with Rails, Hotwire, and the Pi agent harness.

Each agent has a private runtime directory containing `AGENTS.md`, Pi-compatible skills at `.agents/skills/<name>/SKILL.md`, private Pi session JSONL files, and a private `computer/` workspace. Conversation history and long-term agent memories live in SQLite.

## Agent capabilities

- **Resumable context:** an active conversation keeps its Pi session. After 30 idle minutes it starts a fresh Pi session and bootstraps it with the stored topic and summary, recent earlier messages, the current exchange, and only the most relevant memories.
- **Durable memories:** after an assistant reply, a background job asks OpenAI for structured memory proposals. Memories are per-agent, source-linked, prioritized, confidence-scored, reviewable at the agent's **Memories** page, and supplied as explicitly non-instructional reference context.
- **Web research:** Pi receives `web_search` and `web_fetch` tools. Set `BRAVE_SEARCH_API_KEY` to enable search; opening public pages works without it. Private hosts, credentials, and non-standard ports are blocked.
- **Private computer:** Pi receives private file tools plus `computer_exec` and `computer_browser`. Files stay below `storage/agents/<id>/computer`. Terminal work is network-isolated in Docker; browser work requires a deliberately configured, restricted egress network.

Pi's built-in host shell and filesystem tools are disabled. The Rails process is never used as the agent terminal.

## Run locally

```sh
bundle install
npm install
bin/rails db:prepare
cp .env.local.example .env.local
# Add OPENAI_API_KEY to .env.local
bin/rails server
```

In a second terminal during frontend work, run `bin/rails tailwindcss:watch`.

Open `http://127.0.0.1:3000`, create an agent, and send it a message. Replies use OpenAI `gpt-5.6-luna` through Pi and stream into the chat through Turbo Streams.

### Optional web search

Add a Brave Search API key to `.env.local`:

```sh
BRAVE_SEARCH_API_KEY=...
```

### Agent computers

Build the isolated runtime image once:

```sh
docker build -t humane-agent-computer:latest docker/agent-computer
```

`computer_exec` starts the image without network access and mounts only the agent's private workspace. The browser uses a persistent profile inside that same workspace. To enable `computer_browser`, set `HUMANE_COMPUTER_NETWORK` to a Docker network that provides restricted, public-web-only egress. Do not use the default bridge network for browser access.

## Verify

```sh
bin/rails test
bin/rubocop
bin/rails zeitwerk:check
```
