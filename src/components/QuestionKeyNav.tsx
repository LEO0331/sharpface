"use client";

import { useRouter } from "next/navigation";
import { useShortcuts } from "./useShortcuts";

// Keyboard previous/next on question pages.
export function QuestionKeyNav({ previousId, nextId }: { previousId?: string; nextId?: string }) {
  const router = useRouter();
  useShortcuts((shortcut) => {
    const id = shortcut === "previous" ? previousId : shortcut === "next" ? nextId : undefined;
    if (!id) return false;
    router.push(`/questions/${id}`);
    return true;
  });
  return null;
}
