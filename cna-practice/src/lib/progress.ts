export type Progress = { reviewed: string[]; bookmarked: string[]; lastViewed?: string };
const key = "cna-practice-progress-v1";
const empty: Progress = { reviewed: [], bookmarked: [] };

export function readProgress(): Progress {
  if (typeof window === "undefined") return empty;
  try {
    const value = JSON.parse(localStorage.getItem(key) ?? "null") as Partial<Progress> | null;
    return value && Array.isArray(value.reviewed) && Array.isArray(value.bookmarked)
      ? { reviewed: value.reviewed, bookmarked: value.bookmarked, lastViewed: value.lastViewed }
      : empty;
  } catch { return empty; }
}
export function saveProgress(value: Progress): void {
  if (typeof window !== "undefined") localStorage.setItem(key, JSON.stringify(value));
}
