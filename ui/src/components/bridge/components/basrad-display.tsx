import type { BasradComponent, VariableValues } from "@/types/bridge";
import { Label } from "@/components/ui/label";

interface BasradDisplayProps {
  readonly component: BasradComponent;
  readonly variables: VariableValues;
}

export function BasradDisplay({ component, variables }: BasradDisplayProps) {
  const val = variables[component.variable];
  const resolved = Array.isArray(val) ? (val[0] ?? "") : (val ?? "");

  return (
    <fieldset className="space-y-2" disabled>
      <legend className="text-sm font-medium">{component.label}</legend>
      <div className={component.orientation === "h" ? "flex gap-4" : "space-y-1"}>
        {component.options.map(([label, value]) => (
          <div key={value} className="flex items-center gap-2">
            <input
              type="radio"
              checked={resolved === value}
              disabled
              className="h-4 w-4"
              name={component.variable}
              value={value}
              aria-label={label}
            />
            <Label className="text-sm">{label}</Label>
          </div>
        ))}
      </div>
    </fieldset>
  );
}
