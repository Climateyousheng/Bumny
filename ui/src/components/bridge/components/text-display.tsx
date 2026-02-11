import type { TextComponent } from "@/types/bridge";

interface TextDisplayProps {
  readonly component: TextComponent;
}

export function TextDisplay({ component }: TextDisplayProps) {
  return (
    <p className="text-sm">{component.text}</p>
  );
}
