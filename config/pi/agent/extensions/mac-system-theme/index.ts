/**
 * Syncs pi theme with macOS system appearance (dark/light mode).
 * Switches between catppuccin-mocha (dark) and catppuccin-latte (light).
 *
 * Required because pi runs inside tmux, which does not propagate
 * terminal color scheme changes — so pi's built-in auto-sync
 * ("light/dark" theme format) causes partial rendering issues.
 */

import { exec } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const execAsync = promisify(exec);

async function isDarkMode(): Promise<boolean> {
	try {
		const { stdout } = await execAsync(
			"defaults read -g AppleInterfaceStyle",
		);
		return stdout.trim() === "Dark";
	} catch {
		return false;
	}
}

function themeForMode(dark: boolean): string {
	return dark ? "catppuccin-mocha" : "catppuccin-latte";
}

export default function (pi: ExtensionAPI) {
	let intervalId: ReturnType<typeof setInterval> | null = null;

	pi.on("session_start", async (_event, ctx) => {
		let currentTheme = themeForMode(await isDarkMode());
		ctx.ui.setTheme(currentTheme);

		intervalId = setInterval(async () => {
			const newTheme = themeForMode(await isDarkMode());
			if (newTheme !== currentTheme) {
				currentTheme = newTheme;
				ctx.ui.setTheme(currentTheme);
			}
		}, 500);
	});

	pi.on("session_shutdown", () => {
		if (intervalId) {
			clearInterval(intervalId);
			intervalId = null;
		}
	});
}
