import { ChevronRight, ChevronDown, FileText, Folder, Link2 } from "lucide-react";
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
  // Follow-on windows are hidden — only reachable via pushnext buttons
  if (node.node_type === "follow_on") {
    return null;
  }

  // Filter out follow-on children so they don't affect layout
  const visibleChildren = node.children.filter(
    (c) => c.node_type !== "follow_on",
  );

  // Panels and shared panels are clickable (open a window)
  const isClickable =
    node.node_type === "panel" || node.node_type === "shared";
  const hasVisibleChildren = visibleChildren.length > 0;
  const isExpanded = expandedNodes.has(node.name);
  const isSelected = selectedWindowId === node.name;

  // Pure leaf: clickable panel with no visible sub-panels
  if (isClickable && !hasVisibleChildren) {
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
        {node.node_type === "shared" ? (
          <Link2 className="h-3.5 w-3.5 shrink-0 text-blue-500" />
        ) : (
          <FileText className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
        )}
        <span className={`truncate ${node.node_type === "shared" ? "text-blue-600 dark:text-blue-400" : ""}`}>
          {node.label}
        </span>
      </button>
    );
  }

  // Panel with sub-panels: clickable AND expandable
  if (isClickable && hasVisibleChildren) {
    return (
      <div>
        <div
          className={`flex w-full items-center gap-1.5 rounded px-2 py-1 text-left text-sm hover:bg-accent ${
            isSelected ? "bg-accent font-medium" : ""
          }`}
          style={{ paddingLeft: `${depth * 16 + 8}px` }}
        >
          <button
            type="button"
            className="shrink-0"
            onClick={() => onToggle(node.name)}
            aria-expanded={isExpanded}
            aria-label={isExpanded ? "Collapse" : "Expand"}
          >
            {isExpanded ? (
              <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
            ) : (
              <ChevronRight className="h-3.5 w-3.5 text-muted-foreground" />
            )}
          </button>
          <button
            type="button"
            className="flex min-w-0 flex-1 items-center gap-1.5"
            onClick={() => onSelect(node.name)}
            aria-current={isSelected ? "page" : undefined}
          >
            <FileText className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
            <span className="truncate">{node.label}</span>
          </button>
        </div>
        {isExpanded && (
          <div role="group">
            {visibleChildren.map((child) => (
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

  // Branch node: expandable only (not clickable)
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
          {visibleChildren.map((child) => (
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
