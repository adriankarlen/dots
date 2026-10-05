/**
 * herdr-permission-blocked — stopgap bridge for gotgenes/pi-packages#658.
 * Source: https://github.com/gotgenes/pi-packages/issues/658
 *
 * @gotgenes/pi-permission-system does not tell herdr it is waiting on a human,
 * so herdr keeps reporting `working` while the dialog is open. This maps its
 * public channels onto the convention herdr's own pi integration listens for:
 *
 *   permissions:ui_prompt  →  herdr:blocked { active: true,  label }
 *   permissions:decision   →  herdr:blocked { active: false }
 *
 * Every reported prompt is owed exactly one clear, or herdr's counter wedges.
 * Inert with either side missing.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function field(data: unknown, key: string): unknown {
  return data !== null && typeof data === "object"
    ? (data as Record<string, unknown>)[key]
    : undefined;
}

function stringField(data: unknown, key: string): string | null {
  const value = field(data, key);
  return typeof value === "string" && value.length > 0 ? value : null;
}

function labelFor(uiPrompt: unknown): string {
  const forwarding = field(uiPrompt, "forwarding");
  const surface = stringField(uiPrompt, "surface");
  const label =
    forwarding !== null && typeof forwarding === "object"
      ? "Permission Required (Subagent)"
      : "Permission Required";
  return surface === null ? label : `${label}: ${surface}`;
}

export default function herdrPermissionBlockedExtension(pi: ExtensionAPI): void {
  /** requestId → label of every prompt currently waiting on a human. */
  const pending = new Map<string, string>();
  let unpairable = 0;

  function report(active: boolean, label?: string): void {
    try {
      pi.events.emit("herdr:blocked", label === undefined ? { active } : { active, label });
    } catch {
      // A failing listener must never affect enforcement.
    }
  }

  pi.events.on("permissions:ui_prompt", (data: unknown) => {
    const id = stringField(data, "requestId");
    // The forwarding lifecycle re-prompts an id whose first report is still
    // outstanding; one decision can only ever settle one report.
    if (id !== null && pending.has(id)) return;
    const label = labelFor(data);
    pending.set(id ?? `unpairable:${++unpairable}`, label);
    report(true, label);
  });

  pi.events.on("permissions:decision", (data: unknown) => {
    const id = stringField(data, "requestId");
    // A prompt is answered on its own id even when the dialog itself fails, so
    // an unpaired decision belongs to a request that never prompted, whatever
    // its resolution says. Only an id-less payload can be one of ours.
    const retire =
      id === null ? pending.keys().next().value : pending.has(id) ? id : undefined;

    if (retire === undefined) return;
    pending.delete(retire);
    report(false);
  });
}
