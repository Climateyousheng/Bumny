import type { CheckComponent, VariableValues } from "@/types/bridge";
import { Label } from "@/components/ui/label";

interface CheckDisplayProps {
  readonly component: CheckComponent;
  readonly variables: VariableValues;
  readonly isEditing?: boolean;
  readonly onChange?: (variable: string, value: string) => void;
}

export function CheckDisplay({ component, variables, isEditing, onChange }: CheckDisplayProps) {
  const val = variables[component.variable];
  const resolved = Array.isArray(val) ? (val[0] ?? "") : (val ?? "");
  const checked = resolved === component.on_value;

  const handleChange = () => {
    if (!onChange) return;
    const newValue = checked ? component.off_value : component.on_value;
    onChange(component.variable, newValue);
  };

  return (
    <div className="flex items-center gap-3">
      <input
        type="checkbox"
        checked={checked}
        disabled={!isEditing}
        onChange={isEditing ? handleChange : undefined}
        className="h-4 w-4"
        aria-label={component.label}
      />
      <Label className="text-sm">{component.label}</Label>
    </div>
  );
}
