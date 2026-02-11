import { HelpCircle } from "lucide-react";
import { Button } from "@/components/ui/button";

interface WindowHeaderProps {
  readonly title: string;
  readonly onHelpClick: () => void;
}

export function WindowHeader({ title, onHelpClick }: WindowHeaderProps) {
  return (
    <div className="flex items-center justify-between border-b pb-3">
      <h2 className="text-lg font-semibold">{title}</h2>
      <Button variant="ghost" size="icon" onClick={onHelpClick} aria-label="Show help">
        <HelpCircle className="h-4 w-4" />
      </Button>
    </div>
  );
}
