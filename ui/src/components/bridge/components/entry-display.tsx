import type { EntryComponent } from "@/types/bridge";
import type { VariableValues } from "@/types/bridge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface EntryDisplayProps {
  readonly component: EntryComponent;
  readonly variables: VariableValues;
}

function resolveVariable(variables: VariableValues, name: string): string {
  const val = variables[name];
  if (val === undefined) return "";
  if (Array.isArray(val)) return val[0] ?? "";
  return val;
}

export function EntryDisplay({ component, variables }: EntryDisplayProps) {
  const value = resolveVariable(variables, component.variable);

  return (
    <div className="flex items-center gap-3">
      <Label className="min-w-[180px] text-sm">{component.label}</Label>
      <Input
        value={value}
        readOnly
        className="max-w-xs font-mono text-sm"
        style={{ width: `${Math.max(component.width, 6)}ch` }}
      />
    </div>
  );
}
