/**
 * pistack — pi extension port of Cursor pstack workflows.
 *
 * - Workflow slash commands (/how, /tdd, …) inject pstack SKILL.md inline (no name collision)
 * - resources_discover exposes only skills not already in ~/.pi/agent/skills or ~/.agents/skills
 *
 * Skills directory: extensions/pistack/skills (run scripts/sync-pistack-skills.sh)
 * or PISTACK_SKILLS_DIR, or latest Cursor pstack plugin cache (pstack/<hash>/skills)
 */

import {
	existsSync,
	mkdirSync,
	readFileSync,
	readdirSync,
	rmSync,
	symlinkSync,
} from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const EXTENSION_DIR = dirname(fileURLToPath(import.meta.url));
const DISCOVER_CACHE_DIR = join(EXTENSION_DIR, ".skills-discover-cache");

const GLOBAL_SKILL_ROOTS = [
	join(homedir(), ".pi/agent/skills"),
	join(homedir(), ".agents/skills"),
] as const;

const PISTACK_WORKFLOW_COMMANDS = [
	{
		name: "how",
		skill: "how",
		description: "Explain how a subsystem works (pstack)",
	},
	{
		name: "why",
		skill: "why",
		description: "Why it works this way — history and rationale (pstack)",
	},
	{
		name: "tdd",
		skill: "tdd",
		description: "Test-driven fix when a cheap local test exists (pstack)",
	},
	{
		name: "interrogate",
		skill: "interrogate",
		description: "Stress-test a plan or design (pstack)",
	},
	{
		name: "unslop",
		skill: "unslop",
		description: "Remove AI slop from code or prose (pstack)",
	},
	{
		name: "architect",
		skill: "architect",
		description: "Architecture sketch before cross-module change (pstack)",
	},
	{
		name: "arena",
		skill: "arena",
		description: "Parallel model review arena (pstack)",
	},
	{
		name: "reflect",
		skill: "reflect",
		description: "Reflect on approach and tradeoffs (pstack)",
	},
	{
		name: "figure-it-out",
		skill: "figure-it-out",
		description: "Structured problem decomposition (pstack)",
	},
	{
		name: "poteto-mode",
		skill: "poteto-mode",
		description: "Poteto rigorous agent mode (pstack)",
	},
	{
		name: "automate-me",
		skill: "automate-me",
		description: "Turn a repeated workflow into automation (pstack)",
	},
	{
		name: "show-me-your-work",
		skill: "show-me-your-work",
		description: "Long decision trail for handoff (pstack)",
	},
] as const;

function directoryHasSkillMarkdown(dir: string): boolean {
	return existsSync(join(dir, "how", "SKILL.md"));
}

function resolveCursorPstackCacheSkillsDir(): string | null {
	const cacheRoot = join(
		homedir(),
		".cursor/plugins/cache/cursor-public/pstack",
	);
	if (!existsSync(cacheRoot)) {
		return null;
	}

	const versions = readdirSync(cacheRoot, { withFileTypes: true })
		.filter((entry) => entry.isDirectory())
		.map((entry) => entry.name)
		.sort();

	for (let index = versions.length - 1; index >= 0; index -= 1) {
		const skillsDir = join(cacheRoot, versions[index]!, "skills");
		if (directoryHasSkillMarkdown(skillsDir)) {
			return skillsDir;
		}
	}

	return null;
}

export function resolvePistackSkillsDir(): string | null {
	const fromEnv = process.env.PISTACK_SKILLS_DIR;
	if (fromEnv && directoryHasSkillMarkdown(fromEnv)) {
		return fromEnv;
	}

	const bundled = join(EXTENSION_DIR, "skills");
	if (directoryHasSkillMarkdown(bundled)) {
		return bundled;
	}

	return resolveCursorPstackCacheSkillsDir();
}

function collectGlobalSkillNames(): Set<string> {
	const names = new Set<string>();
	for (const root of GLOBAL_SKILL_ROOTS) {
		if (!existsSync(root)) {
			continue;
		}
		for (const entry of readdirSync(root, { withFileTypes: true })) {
			if (entry.isDirectory() || entry.isSymbolicLink()) {
				names.add(entry.name);
			}
		}
	}
	return names;
}

function stripYamlFrontmatter(content: string): string {
	if (!content.startsWith("---")) {
		return content.trim();
	}
	const endIndex = content.indexOf("---", 3);
	if (endIndex === -1) {
		return content.trim();
	}
	return content.slice(endIndex + 3).trim();
}

function buildPistackSkillMessage(
	skillsDir: string,
	skillName: string,
	userArgs: string,
): string | null {
	const skillPath = join(skillsDir, skillName, "SKILL.md");
	if (!existsSync(skillPath)) {
		return null;
	}
	const raw = readFileSync(skillPath, "utf8");
	const body = stripYamlFrontmatter(raw);
	const skillBlock = [
		`<skill name="${skillName}" location="${skillPath}">`,
		body,
		"</skill>",
	].join("\n");
	if (!userArgs) {
		return skillBlock;
	}
	return `${userArgs}\n\n${skillBlock}`;
}

/** Skills not shadowed by global ~/.pi/agent/skills or ~/.agents/skills */
export function buildExclusiveDiscoverSkillsDir(skillsDir: string): string | null {
	const globalNames = collectGlobalSkillNames();
	const exclusive = readdirSync(skillsDir, { withFileTypes: true })
		.filter((entry) => entry.isDirectory())
		.map((entry) => entry.name)
		.filter((name) => !globalNames.has(name));

	if (exclusive.length === 0) {
		return null;
	}

	if (existsSync(DISCOVER_CACHE_DIR)) {
		rmSync(DISCOVER_CACHE_DIR, { recursive: true, force: true });
	}
	mkdirSync(DISCOVER_CACHE_DIR, { recursive: true });

	for (const name of exclusive) {
		const target = join(skillsDir, name);
		const link = join(DISCOVER_CACHE_DIR, name);
		try {
			symlinkSync(target, link);
		} catch {
			// ignore broken symlink races on reload
		}
	}

	return DISCOVER_CACHE_DIR;
}

function registerWorkflowCommands(pi: ExtensionAPI): void {
	for (const workflow of PISTACK_WORKFLOW_COMMANDS) {
		pi.registerCommand(workflow.name, {
			description: workflow.description,
			handler: async (args, ctx) => {
				if (!ctx.isIdle()) {
					ctx.ui.notify(
						`Agent busy — retry /${workflow.name} when idle`,
						"warning",
					);
					return;
				}

				const skillsDir = resolvePistackSkillsDir();
				if (!skillsDir) {
					ctx.ui.notify(
						"pistack: run ./scripts/sync-pistack-skills.sh from pi-stack",
						"error",
					);
					return;
				}

				const trimmedArgs = args.trim();
				const message = buildPistackSkillMessage(
					skillsDir,
					workflow.skill,
					trimmedArgs,
				);
				if (!message) {
					ctx.ui.notify(
						`pistack: missing ${workflow.skill}/SKILL.md`,
						"error",
					);
					return;
				}

				pi.sendUserMessage(message);
			},
		});
	}
}

export default function pistackExtension(pi: ExtensionAPI): void {
	let warnedMissingSkills = false;

	pi.on("resources_discover", async () => {
		const skillsDir = resolvePistackSkillsDir();
		if (!skillsDir) {
			return {};
		}
		const discoverDir = buildExclusiveDiscoverSkillsDir(skillsDir);
		if (!discoverDir) {
			return {};
		}
		return { skillPaths: [discoverDir] };
	});

	pi.on("session_start", async (_event, ctx) => {
		const skillsDir = resolvePistackSkillsDir();
		if (skillsDir || warnedMissingSkills) {
			return;
		}
		warnedMissingSkills = true;
		ctx.ui.notify(
			"pistack: no skills dir — run ./scripts/sync-pistack-skills.sh from pi-stack",
			"warning",
		);
	});

	registerWorkflowCommands(pi);

	pi.registerCommand("pistack", {
		description: "List pistack workflow commands and skills path",
		handler: async (_args, ctx) => {
			const skillsDir = resolvePistackSkillsDir();
			const globalNames = collectGlobalSkillNames();
			const lines = [
				"pistack (pi port of Cursor pstack)",
				skillsDir ? `skills: ${skillsDir}` : "skills: NOT FOUND",
				"",
				"Workflows (inline pstack SKILL.md — not shadowed by global skills):",
				...PISTACK_WORKFLOW_COMMANDS.map(
					(workflow) => `  /${workflow.name}`,
				),
				"",
				"Principles (via /skill:principle-* when not in global skills):",
				skillsDir
					? readdirSync(skillsDir, { withFileTypes: true })
							.filter((e) => e.isDirectory() && e.name.startsWith("principle-"))
							.filter((e) => !globalNames.has(e.name))
							.map((e) => `  /skill:${e.name}`)
							.join("\n") || "  (none — all collide with global skills)"
					: "",
			];
			ctx.ui.notify(lines.join("\n"), "info");
		},
	});
}
