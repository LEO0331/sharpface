"use client";

import { useEffect, useRef } from "react";
import { shortcutFor, type Shortcut } from "@/lib/shortcuts";

// Calls handler for recognised shortcuts; handler returns true when it used the key.
export function useShortcuts(handler: (shortcut: Shortcut) => boolean | void) {
  const latest = useRef(handler);
  useEffect(() => { latest.current = handler; });
  useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      const shortcut = shortcutFor(event);
      if (shortcut && latest.current(shortcut)) event.preventDefault();
    }
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, []);
}
