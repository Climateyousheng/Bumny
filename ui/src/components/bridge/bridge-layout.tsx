import type { ReactNode } from "react";

interface BridgeLayoutProps {
  readonly sidebar: ReactNode;
  readonly content: ReactNode;
}

export function BridgeLayout({ sidebar, content }: BridgeLayoutProps) {
  return (
    <div className="grid h-[calc(100vh-4rem)] grid-cols-[280px_1fr] gap-0">
      <aside className="overflow-y-auto border-r p-3">{sidebar}</aside>
      <main className="overflow-y-auto p-6">{content}</main>
    </div>
  );
}
