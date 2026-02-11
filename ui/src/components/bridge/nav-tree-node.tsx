import { ChevronRight, ChevronDown, FileText, Folder } from "lucide-react";
import type { NavNodeResponse } from "@/types/bridge";

interface NavTreeNodeProps {
  readonly node: NavNodeResponse;
  readonly expandedNodes: ReadonlySet<string>;
  readonly selectedWindowId: string | null;
  readonly onToggle: (name: string) => void;
  readonly onSelect: (name: string) => void;
  readonly depth?: number;
}

export function NavTreeNode({
  node,
  expandedNodes,
  selectedWindowId,
  onToggle,
  onSelect,
  depth = 0,
}: NavTreeNodeProps) {
  const isLeaf = node.children.length === 0;
  const isExpanded = expandedNodes.has(node.name);
  const isSelected = selectedWindowId === node.name;

  if (isLeaf) {
    return (
      <button
        type="button"
        className={`flex w-full items-center gap-1.5 rounded px-2 py-1 text-left text-sm hover:bg-accent ${
          isSelected ? "bg-accent font-medium" : ""
        }`}
        style={{ paddingLeft: `${depth * 16 + 8}px` }}
        onClick={() => onSelect(node.name)}
        aria-current={isSelected ? "page" : undefined}
      >
        <FileText className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
        <span className="truncate">{node.label}</span>
      </button>
    );
  }

  return (
    <div>
      <button
        type="button"
        className="flex w-full items-center gap-1.5 rounded px-2 py-1 text-left text-sm hover:bg-accent"
        style={{ paddingLeft: `${depth * 16 + 8}px` }}
        onClick={() => onToggle(node.name)}
        aria-expanded={isExpanded}
      >
        {isExpanded ? (
          <ChevronDown className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
        ) : (
          <ChevronRight className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
        )}
        <Folder className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
        <span className="truncate font-medium">{node.label}</span>
      </button>
      {isExpanded && (
        <div role="group">
          {node.children.map((child) => (
            <NavTreeNode
              key={child.name}
              node={child}
              expandedNodes={expandedNodes}
              selectedWindowId={selectedWindowId}
              onToggle={onToggle}
              onSelect={onSelect}
              depth={depth + 1}
            />
          ))}
        </div>
      )}
    </div>
  );
}
