import type { EntryComponent } from "@/types/bridge";
import type { VariableValues } from "@/types/bridge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface EntryDisplayProps {
  readonly component: EntryComponent;
  readonly variables: VariableValues;
  readonly isEditing?: boolean;
  readonly onChange?: (variable: string, value: string) => void;
}

function resolveVariable(variables: VariableValues, name: string): string {
  const val = variables[name];
  if (val === undefined) return "";
  if (Array.isArray(val)) return val[0] ?? "";
  return val;
}

export function EntryDisplay({ component, variables, isEditing, onChange }: EntryDisplayProps) {
  const value = resolveVariable(variables, component.variable);

  return (
    <div className="flex items-center gap-3">
      <Label className="min-w-[180px] text-sm">{component.label}</Label>
      <Input
        value={value}
        readOnly={!isEditing}
        onChange={
          isEditing && onChange
            ? (e) => onChange(component.variable, e.target.value)
            : undefined
        }
        className="max-w-xs font-mono text-sm"
        style={{ width: `${Math.max(component.width, 6)}ch` }}
      />
    </div>
  );
}
