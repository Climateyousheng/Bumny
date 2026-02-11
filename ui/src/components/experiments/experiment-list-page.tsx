import { useState } from "react";
import { useExperiments } from "@/hooks/use-experiments";
import { ExperimentTable } from "./experiment-table";
import { CreateExperimentDialog } from "./create-experiment-dialog";
import { SearchInput } from "@/components/shared/search-input";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";
import { EmptyState } from "@/components/shared/empty-state";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";

export function ExperimentListPage() {
  const { data: experiments, isLoading, error } = useExperiments();
  const [search, setSearch] = useState("");
  const [createOpen, setCreateOpen] = useState(false);

  const filtered = experiments?.filter(
    (exp) =>
      exp.id.toLowerCase().includes(search.toLowerCase()) ||
      exp.owner.toLowerCase().includes(search.toLowerCase()) ||
      exp.description.toLowerCase().includes(search.toLowerCase()),
  );

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
      <SearchInput value={search} onChange={setSearch} placeholder="Search experiments..." />
      {filtered && filtered.length > 0 ? (
        <ExperimentTable experiments={filtered} />
      ) : (
        <EmptyState title="No experiments found" description={search ? "Try a different search term" : "Create your first experiment"} />
      )}
      <CreateExperimentDialog open={createOpen} onOpenChange={setCreateOpen} />
    </div>
  );
}
