import { useState, useCallback } from "react";
import { useParams, Link } from "react-router-dom";
import { ChevronLeft } from "lucide-react";
import { useNavTree } from "@/hooks/use-bridge";
import { BridgeLayout } from "./bridge-layout";
import { NavTree } from "./nav-tree";
import { WindowPanel } from "./window-panel";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";

export function BridgePage() {
  const { expId, jobId } = useParams<{ expId: string; jobId: string }>();
  const { data: navTree, isLoading, error } = useNavTree();

  const [expandedNodes, setExpandedNodes] = useState<Set<string>>(new Set());
  const [selectedWindowId, setSelectedWindowId] = useState<string | null>(null);

  const handleToggle = useCallback((name: string) => {
    setExpandedNodes((prev) => {
      const next = new Set(prev);
      if (next.has(name)) {
        next.delete(name);
      } else {
        next.add(name);
      }
      return next;
    });
  }, []);

  const handleSelect = useCallback((name: string) => {
    setSelectedWindowId(name);
  }, []);

  if (isLoading) return <LoadingSkeleton />;
  if (error) return <ErrorAlert message={error.message} />;
  if (!navTree) return <ErrorAlert message="Navigation tree not found" />;

  const sidebar = (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <Link
          to={`/experiments/${expId}/jobs/${jobId}`}
          className="text-muted-foreground hover:text-foreground"
        >
          <ChevronLeft className="h-4 w-4" />
        </Link>
        <h1 className="text-sm font-semibold">
          <span className="font-mono">{expId}</span> / <span className="font-mono">{jobId}</span>
        </h1>
      </div>
      <NavTree
        nodes={navTree}
        expandedNodes={expandedNodes}
        selectedWindowId={selectedWindowId}
        onToggle={handleToggle}
        onSelect={handleSelect}
      />
    </div>
  );

  const content = selectedWindowId ? (
    <WindowPanel
      winId={selectedWindowId}
      expId={expId!}
      jobId={jobId!}
      onNavigate={handleSelect}
    />
  ) : (
    <div className="flex h-full items-center justify-center text-muted-foreground">
      <p className="text-sm">Select a window from the navigation tree.</p>
    </div>
  );

  return <BridgeLayout sidebar={sidebar} content={content} />;
}
