# humane

A personal AI team built with Rails, Hotwire, and the Pi agent harness.

Each agent has a private runtime directory containing `AGENTS.md` and Pi-compatible skills at `.agents/skills/<name>/SKILL.md`. Conversation history lives in SQLite; Pi sessions are in-memory, so the app adds no separate memory system.

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

## Verify

```sh
bin/rails test
bin/rubocop
bin/rails zeitwerk:check
```
