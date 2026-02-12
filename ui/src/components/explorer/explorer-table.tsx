import { Link } from "react-router-dom";
import { ChevronRight, ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ExperimentRowActions } from "@/components/experiments/experiment-row-actions";
import { ExplorerJobRows } from "./explorer-job-rows";
import type { ExperimentResponse } from "@/types/experiment";

const COL_COUNT = 8;

interface ExplorerTableProps {
  readonly experiments: readonly ExperimentResponse[];
  readonly expandedIds: ReadonlySet<string>;
  readonly selectedIds: ReadonlySet<string>;
  readonly onToggleExpand: (id: string) => void;
  readonly onToggleSelect: (id: string) => void;
  readonly onSelectAll: () => void;
}

export function ExplorerTable({
  experiments,
  expandedIds,
  selectedIds,
  onToggleExpand,
  onToggleSelect,
  onSelectAll,
}: ExplorerTableProps) {
  const allSelected = experiments.length > 0 && experiments.every((e) => selectedIds.has(e.id));

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-10">
            <input
              type="checkbox"
              checked={allSelected}
              onChange={onSelectAll}
              aria-label="Select all"
              className="h-4 w-4 rounded border-gray-300"
            />
          </TableHead>
          <TableHead className="w-10" />
          <TableHead>ID</TableHead>
          <TableHead>Owner</TableHead>
          <TableHead>Description</TableHead>
          <TableHead>Version</TableHead>
          <TableHead>Privacy</TableHead>
          <TableHead className="w-10" />
        </TableRow>
      </TableHeader>
      <TableBody>
        {experiments.map((exp) => {
          const isExpanded = expandedIds.has(exp.id);
          const isSelected = selectedIds.has(exp.id);

          return (
            <ExplorerExperimentRow
              key={exp.id}
              experiment={exp}
              isExpanded={isExpanded}
              isSelected={isSelected}
              onToggleExpand={() => onToggleExpand(exp.id)}
              onToggleSelect={() => onToggleSelect(exp.id)}
            />
          );
        })}
      </TableBody>
    </Table>
  );
}

interface ExplorerExperimentRowProps {
  readonly experiment: ExperimentResponse;
  readonly isExpanded: boolean;
  readonly isSelected: boolean;
  readonly onToggleExpand: () => void;
  readonly onToggleSelect: () => void;
}

function ExplorerExperimentRow({
  experiment,
  isExpanded,
  isSelected,
  onToggleExpand,
  onToggleSelect,
}: ExplorerExperimentRowProps) {
  return (
    <>
      <TableRow data-state={isSelected ? "selected" : undefined}>
        <TableCell>
          <input
            type="checkbox"
            checked={isSelected}
            onChange={onToggleSelect}
            aria-label={`Select ${experiment.id}`}
            className="h-4 w-4 rounded border-gray-300"
          />
        </TableCell>
        <TableCell>
          <Button
            variant="ghost"
            size="icon"
            className="h-6 w-6"
            onClick={onToggleExpand}
            aria-label={isExpanded ? `Collapse ${experiment.id}` : `Expand ${experiment.id}`}
          >
            {isExpanded ? (
              <ChevronDown className="h-4 w-4" />
            ) : (
              <ChevronRight className="h-4 w-4" />
            )}
          </Button>
        </TableCell>
        <TableCell className="font-mono">
          <Link
            to={`/experiments/${experiment.id}`}
            className="text-primary hover:underline"
          >
            {experiment.id}
          </Link>
        </TableCell>
        <TableCell>{experiment.owner}</TableCell>
        <TableCell className="truncate max-w-[300px]">{experiment.description}</TableCell>
        <TableCell>{experiment.version}</TableCell>
        <TableCell>
          {experiment.privacy === "Y" ? (
            <Badge variant="outline">Private</Badge>
          ) : (
            <Badge variant="secondary">Public</Badge>
          )}
        </TableCell>
        <TableCell>
          <ExperimentRowActions experiment={experiment} />
        </TableCell>
      </TableRow>
      {isExpanded && <ExplorerJobRows expId={experiment.id} colSpan={COL_COUNT} />}
    </>
  );
}
