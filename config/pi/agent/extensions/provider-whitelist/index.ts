import { readFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ALL_PROVIDERS = [
  "anthropic",
  "openai",
  "openai-codex",
  "claude-agent-sdk",
  "google",
  "deepseek",
  "openrouter",
  "bedrock",
  "azure",
  "ollama",
  "groq",
  "mistral",
  "fireworks",
  "together",
  "perplexity",
  "cohere",
  "replicate",
  "vertex",
  "huggingface",
  "anyscale",
  "cloudflare",
  "lepton",
  "modal",
  "cerebras",
  "lambda",
  "sambanova",
  "xai",
];

export default function (pi: ExtensionAPI) {
  const agentDir =
    process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");

  let enabledProviders: string[] = [];
  try {
    const settings = JSON.parse(
      readFileSync(join(agentDir, "settings.json"), "utf8"),
    );
    enabledProviders = settings.enabledProviders || [];
  } catch {
    // No settings or parse error — do nothing, allow all providers
    return;
  }

  if (enabledProviders.length === 0) return;

  const enabled = new Set(enabledProviders.map((p) => p.toLowerCase()));

  for (const provider of ALL_PROVIDERS) {
    if (!enabled.has(provider.toLowerCase())) {
      pi.unregisterProvider(provider);
    }
  }
}
