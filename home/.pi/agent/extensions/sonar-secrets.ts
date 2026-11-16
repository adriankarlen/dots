// Managed by `sonar integrate pi` \u2014 do not edit by hand.
import { existsSync } from 'node:fs';

import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { execFile } from 'node:child_process';
import { homedir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HOOK_TIMEOUT_MS = 60000;
const UNICODE_SPACES = /[\u00A0\u2000-\u200A\u202F\u205F\u3000]/g;

function runHook<T>(subcommand: string, payload: unknown, timeout: number = HOOK_TIMEOUT_MS, cwd?: string): Promise<T> {
  return new Promise((resolvePromise, reject) => {
    const child = execFile('sonar', ['hook', ...subcommand.split(' ')], { timeout, cwd }, (error, stdout) => {
      if (error) return reject(error);
      try {
        resolvePromise(JSON.parse(stdout) as T);
      } catch (parseError) {
        reject(parseError);
      }
    });
    child.stdin?.end(JSON.stringify(payload));
  });
}

function resolveToCwd(path: string, cwd: string): string {
  let normalized = path.replace(UNICODE_SPACES, ' ');
  if (normalized.startsWith('@')) normalized = normalized.slice(1);
  if (normalized === '~') {
    normalized = homedir();
  } else if (normalized.startsWith('~/')) {
    normalized = join(homedir(), normalized.slice(2));
  } else if (/^file:\/\//.test(normalized)) {
    normalized = fileURLToPath(normalized);
  }
  return resolve(cwd, normalized);
}

const SECRETS_NOTICE_BLOCKED_TEMPLATE = "[SonarQube] Message blocked: {reason}\nBlocked as a precaution — original content was not sent. Let the user know that SonarQube blocked this message.";
const SECRETS_ERROR_SCANNING_TEMPLATE = "could not verify this message for secrets ({reason})";

function blockedMessage(reason: string): string {
  return SECRETS_NOTICE_BLOCKED_TEMPLATE.replace('{reason}', () => reason);
}
const NARROW_NO_BREAK_SPACE = '\u202F';
const CURLY_APOSTROPHE = '\u2019';
const NO_BYPASS_SENTENCE =
  'Do not attempt to access this file another way (e.g. via bash) \u2014 inform the user of the block and ask before taking any other action. Scan only specific files with sonar analyze secrets <files>. Do not scan whole trees with . or a repository-root path.';

interface PreToolUseDecision {
  block: boolean;
  reason?: string;
}

interface ChatMessageDecision {
  block: boolean;
  reason?: string;
  redactedText?: string;
  secretsFound?: number;
}

function isValidDecision(value: { block?: unknown; redactedText?: unknown } | null): boolean {
  return (
    typeof value?.block === 'boolean' &&
    (value.redactedText === undefined || typeof value.redactedText === 'string')
  );
}

async function runDecisionHook<T>(subcommand: string, payload: unknown): Promise<T> {
  const answer = await runHook<{ block?: unknown; redactedText?: unknown } | null>(subcommand, payload);
  if (!isValidDecision(answer)) throw new Error('unexpected answer from sonar hook ' + subcommand);
  return answer as T;
}

function describeError(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function resolveReadPath(path: string, cwd: string): string {
  const resolved = resolveToCwd(path, cwd);
  const nfd = resolved.normalize('NFD');
  const candidates = [
    resolved,
    resolved.replace(/ (AM|PM)\./gi, NARROW_NO_BREAK_SPACE + '$1.'),
    nfd,
    resolved.replace(/'/g, CURLY_APOSTROPHE),
    nfd.replace(/'/g, CURLY_APOSTROPHE),
  ];
  return candidates.find((candidate) => existsSync(candidate)) ?? resolved;
}

async function protectText(text: string, sessionID: string): Promise<string> {
  if (!text) return text;
  try {
    const decision = await runDecisionHook<ChatMessageDecision>('pi-chat-message', { text, sessionID });
    if (decision.block) return blockedMessage(decision.reason!);
    return decision.redactedText ?? text;
  } catch (error) {
    return blockedMessage(SECRETS_ERROR_SCANNING_TEMPLATE.replace('{reason}', () => describeError(error)));
  }
}

export default function (pi: ExtensionAPI) {
  pi.on('tool_call', async (event, ctx) => {
    if (event.toolName !== 'read') return;
    const path = (event.input as { path?: string }).path;
    if (!path) return;
    try {
      const decision = await runDecisionHook<PreToolUseDecision>('pi-pre-tool-use', {
        tool: 'read',
        filePath: resolveReadPath(path, ctx.cwd),
        sessionID: ctx.sessionManager.getSessionId(),
      });
      if (decision.block) {
        return { block: true, reason: (decision.reason ?? 'Sonar blocked this file read.') + ' ' + NO_BYPASS_SENTENCE };
      }
    } catch (error) {
      return {
        block: true,
        reason:
          'Sonar could not verify ' + path + ' for secrets (' + describeError(error) + '). Blocking as a precaution. ' + NO_BYPASS_SENTENCE,
      };
    }
  });

  pi.on('message_end', async (event, ctx) => {
    const message = event.message;
    try {
      if (message?.role !== 'user') return;
      const sessionID = ctx.sessionManager.getSessionId();
      if (typeof message.content === 'string') {
        return { message: { ...message, content: await protectText(message.content, sessionID) } };
      }
      const content = await Promise.all(
        message.content.map(async (part) =>
          part.type === 'text' ? { ...part, text: await protectText(part.text, sessionID) } : part,
        ),
      );
      return { message: { ...message, content } };
    } catch (error) {
      return { message: { ...message, content: blockedMessage(SECRETS_ERROR_SCANNING_TEMPLATE.replace('{reason}', () => describeError(error))) } };
    }
  });
}
