import { useState, useCallback, useMemo } from "react";
import { Plus } from "lucide-react";
import { useExperiments, useDeleteExperiment } from "@/hooks/use-experiments";
import { filterExperiments, EMPTY_FILTERS, type ExplorerFilters } from "@/lib/filter-experiments";
import { ExplorerTable } from "./explorer-table";
import { FilterBar } from "./filter-bar";
import { BulkActionsBar } from "./bulk-actions-bar";
import { CreateExperimentDialog } from "@/components/experiments/create-experiment-dialog";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";
import { EmptyState } from "@/components/shared/empty-state";
import { Button } from "@/components/ui/button";

export function ExplorerPage() {
  const { data: experiments, isLoading, error } = useExperiments();
  const deleteExperiment = useDeleteExperiment();

  const [filters, setFilters] = useState<ExplorerFilters>(EMPTY_FILTERS);
  const [expandedIds, setExpandedIds] = useState<Set<string>>(new Set());
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [createOpen, setCreateOpen] = useState(false);

  const filtered = useMemo(
    () => (experiments ? filterExperiments(experiments, filters) : []),
    [experiments, filters],
  );

  const owners = useMemo(() => {
    if (!experiments) return [];
    return [...new Set(experiments.map((e) => e.owner))].sort();
  }, [experiments]);

  const versions = useMemo(() => {
    if (!experiments) return [];
    return [...new Set(experiments.map((e) => e.version))].sort();
  }, [experiments]);

  const handleToggleExpand = useCallback((id: string) => {
    setExpandedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  }, []);

  const handleToggleSelect = useCallback((id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  }, []);

  const handleSelectAll = useCallback(() => {
    setSelectedIds((prev) => {
      const allSelected = filtered.length > 0 && filtered.every((e) => prev.has(e.id));
      if (allSelected) {
        return new Set<string>();
      }
      return new Set(filtered.map((e) => e.id));
    });
  }, [filtered]);

  const handleBulkDelete = useCallback(async () => {
    const ids = [...selectedIds];
    const results = await Promise.allSettled(
      ids.map((id) => deleteExperiment.mutateAsync(id)),
    );
    const failedIds = new Set(
      ids.filter((_, idx) => results[idx]?.status === "rejected"),
    );
    setSelectedIds(failedIds);
  }, [selectedIds, deleteExperiment]);

  const handleClearSelection = useCallback(() => {
    setSelectedIds(new Set());
  }, []);

  if (isLoading) return <LoadingSkeleton />;
  if (error) return <ErrorAlert message={error.message} />;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Experiments</h1>
        <Button onClick={() => setCreateOpen(true)}>
          <Plus className="mr-2 h-4 w-4" />
          New Experiment
        </Button>
      </div>

      <FilterBar
        filters={filters}
        onFiltersChange={setFilters}
        owners={owners}
        versions={versions}
      />

      {selectedIds.size > 0 && (
        <BulkActionsBar
          selectedCount={selectedIds.size}
          onDelete={() => void handleBulkDelete()}
          onClearSelection={handleClearSelection}
        />
      )}

      {filtered.length > 0 ? (
        <ExplorerTable
          experiments={filtered}
          expandedIds={expandedIds}
          selectedIds={selectedIds}
          onToggleExpand={handleToggleExpand}
          onToggleSelect={handleToggleSelect}
          onSelectAll={handleSelectAll}
        />
      ) : (
        <EmptyState
          title="No experiments found"
          description={
            filters.search || filters.owner || filters.version || filters.privacy
              ? "Try adjusting your filters"
              : "Create your first experiment"
          }
        />
      )}

      <CreateExperimentDialog open={createOpen} onOpenChange={setCreateOpen} />
    </div>
  );
}
