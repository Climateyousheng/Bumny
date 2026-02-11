import type { TableComponent, ElementComponent, ElementAutoNumComponent, VariableValues } from "@/types/bridge";

interface TableDisplayProps {
  readonly component: TableComponent;
  readonly variables: VariableValues;
}

function resolveArrayVariable(variables: VariableValues, name: string): string[] {
  const val = variables[name];
  if (val === undefined) return [];
  if (Array.isArray(val)) return val;
  return [val];
}

export function TableDisplay({ component, variables }: TableDisplayProps) {
  const rowCount = parseInt(component.rows, 10) || 0;
  const columns = component.children.filter(
    (c): c is ElementComponent | ElementAutoNumComponent =>
      c.kind === "element" || c.kind === "elementautonum",
  );

  return (
    <div className="space-y-2">
      {component.header && (
        <p className="text-sm font-medium">{component.header}</p>
      )}
      <div className="overflow-x-auto">
        <table className="border-collapse text-sm">
          <thead>
            <tr>
              {columns.map((col, i) => (
                <th key={i} className="border px-3 py-1 text-left font-medium">
                  {col.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {Array.from({ length: rowCount }, (_, rowIdx) => (
              <tr key={rowIdx}>
                {columns.map((col, colIdx) => (
                  <td key={colIdx} className="border px-3 py-1 font-mono">
                    {col.kind === "element"
                      ? (resolveArrayVariable(variables, col.variable)[rowIdx] ?? "")
                      : String(parseInt(col.start, 10) + rowIdx)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
