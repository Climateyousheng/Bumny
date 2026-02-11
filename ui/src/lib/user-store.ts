const STORAGE_KEY = "umui-username";

export function getUsername(): string {
  if (typeof window === "undefined") return "";
  return localStorage.getItem(STORAGE_KEY) ?? "";
}

export function setUsername(username: string): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, username);
}

export function clearUsername(): void {
  if (typeof window === "undefined") return;
  localStorage.removeItem(STORAGE_KEY);
}
