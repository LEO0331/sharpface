export type Shortcut = "concepts" | "approach" | "answer" | "reviewed" | "bookmarked" | "previous" | "next";

const keys: Record<string, Shortcut> = {
  k: "concepts", a: "approach", f: "answer", r: "reviewed", b: "bookmarked",
  p: "previous", arrowleft: "previous", n: "next", arrowright: "next",
};
export const shortcutHint = "Shortcuts: K concepts · A approach · F answer · R reviewed · B bookmark · ← / → previous / next";

type KeyEventLike = { key: string; ctrlKey?: boolean; metaKey?: boolean; altKey?: boolean; target?: unknown };

// Maps a keydown to a shortcut; ignores modified keys and typing in form fields.
export function shortcutFor(event: KeyEventLike): Shortcut | undefined {
  if (event.ctrlKey || event.metaKey || event.altKey) return undefined;
  const target = event.target as { tagName?: string; isContentEditable?: boolean } | null | undefined;
  if (target && (target.isContentEditable || ["INPUT", "SELECT", "TEXTAREA"].includes(target.tagName ?? ""))) return undefined;
  return keys[event.key.toLowerCase()];
}
