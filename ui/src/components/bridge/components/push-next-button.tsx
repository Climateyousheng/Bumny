import { Button } from "@/components/ui/button";
import type { PushNextComponent } from "@/types/bridge";

interface PushNextButtonProps {
  readonly component: PushNextComponent;
  readonly onNavigate: (winId: string) => void;
}

export function PushNextButton({ component, onNavigate }: PushNextButtonProps) {
  return (
    <Button
      variant="outline"
      size="sm"
      onClick={() => onNavigate(component.target_window)}
    >
      {component.label}
    </Button>
  );
}
