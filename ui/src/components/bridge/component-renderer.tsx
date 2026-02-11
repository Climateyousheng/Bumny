import type { PanComponent, VariableValues } from "@/types/bridge";
import { evaluate } from "@/lib/expression-evaluator";
import { TextDisplay } from "./components/text-display";
import { EntryDisplay } from "./components/entry-display";
import { CheckDisplay } from "./components/check-display";
import { BasradDisplay } from "./components/basrad-display";
import { TableDisplay } from "./components/table-display";
import { PushNextButton } from "./components/push-next-button";

interface ComponentRendererProps {
  readonly component: PanComponent;
  readonly variables: VariableValues;
  readonly allVariables: VariableValues;
  readonly onNavigate: (winId: string) => void;
}

export function ComponentRenderer({
  component,
  variables,
  allVariables,
  onNavigate,
}: ComponentRendererProps) {
  switch (component.kind) {
    case "text":
      return <TextDisplay component={component} />;

    case "entry":
      return <EntryDisplay component={component} variables={variables} />;

    case "check":
      return <CheckDisplay component={component} variables={variables} />;

    case "basrad":
      return <BasradDisplay component={component} variables={variables} />;

    case "table":
      return <TableDisplay component={component} variables={variables} />;

    case "pushnext":
      return <PushNextButton component={component} onNavigate={onNavigate} />;

    case "gap":
      return <div className="h-2" />;

    case "block":
      return (
        <div className="ml-4 space-y-2">
          {component.children.map((child, i) => (
            <ComponentRenderer
              key={i}
              component={child}
              variables={variables}
              allVariables={allVariables}
              onNavigate={onNavigate}
            />
          ))}
        </div>
      );

    case "case": {
      const active = evaluateSafe(component.expression, allVariables);
      return (
        <div className={active ? undefined : "opacity-40 pointer-events-none"}>
          {component.children.map((child, i) => (
            <ComponentRenderer
              key={i}
              component={child}
              variables={variables}
              allVariables={allVariables}
              onNavigate={onNavigate}
            />
          ))}
        </div>
      );
    }

    case "invisible": {
      const visible = evaluateSafe(component.expression, allVariables);
      if (!visible) return null;
      return (
        <>
          {component.children.map((child, i) => (
            <ComponentRenderer
              key={i}
              component={child}
              variables={variables}
              allVariables={allVariables}
              onNavigate={onNavigate}
            />
          ))}
        </>
      );
    }

    case "element":
    case "elementautonum":
      // These are children of table, rendered there directly
      return null;

    default:
      return null;
  }
}

function evaluateSafe(expression: string, variables: VariableValues): boolean {
  try {
    return evaluate(expression, variables);
  } catch {
    return true;
  }
}
