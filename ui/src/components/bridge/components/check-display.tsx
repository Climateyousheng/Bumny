import type { CheckComponent, VariableValues } from "@/types/bridge";
import { Label } from "@/components/ui/label";

interface CheckDisplayProps {
  readonly component: CheckComponent;
  readonly variables: VariableValues;
}

export function CheckDisplay({ component, variables }: CheckDisplayProps) {
  const val = variables[component.variable];
  const resolved = Array.isArray(val) ? (val[0] ?? "") : (val ?? "");
  const checked = resolved === component.on_value;

  return (
    <div className="flex items-center gap-3">
      <input
        type="checkbox"
        checked={checked}
        disabled
        className="h-4 w-4"
        aria-label={component.label}
      />
      <Label className="text-sm">{component.label}</Label>
    </div>
  );
}
