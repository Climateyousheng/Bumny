import type { NavNodeResponse } from "@/types/bridge";
import { NavTreeNode } from "./nav-tree-node";

interface NavTreeProps {
  readonly nodes: readonly NavNodeResponse[];
  readonly expandedNodes: ReadonlySet<string>;
  readonly selectedWindowId: string | null;
  readonly onToggle: (name: string) => void;
  readonly onSelect: (name: string) => void;
}

export function NavTree({
  nodes,
  expandedNodes,
  selectedWindowId,
  onToggle,
  onSelect,
}: NavTreeProps) {
  return (
    <nav aria-label="Navigation tree" className="space-y-0.5">
      {nodes.map((node) => (
        <NavTreeNode
          key={node.name}
          node={node}
          expandedNodes={expandedNodes}
          selectedWindowId={selectedWindowId}
          onToggle={onToggle}
          onSelect={onSelect}
        />
      ))}
    </nav>
  );
}
