import { useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatVariableValue, type VariableDiff } from "@/lib/diff-utils";

interface VariableDiffTableProps {
  readonly diffs: readonly VariableDiff[];
  readonly jobALabel: string;
  readonly jobBLabel: string;
}

const STATUS_BADGE: Record<VariableDiff["status"], { label: string; className: string; variant?: "secondary" }> = {
  added: { label: "added", className: "bg-green-100 text-green-800 border-green-200" },
  removed: { label: "removed", className: "bg-red-100 text-red-800 border-red-200" },
  changed: { label: "changed", className: "bg-yellow-100 text-yellow-800 border-yellow-200" },
  unchanged: { label: "unchanged", className: "", variant: "secondary" },
};

export function VariableDiffTable({ diffs, jobALabel, jobBLabel }: VariableDiffTableProps) {
  const [showAll, setShowAll] = useState(false);

  const changedCount = diffs.filter((d) => d.status !== "unchanged").length;
  const visibleDiffs = showAll ? diffs : diffs.filter((d) => d.status !== "unchanged");

  return (
    <div>
      <div className="mb-2 flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {changedCount} of {diffs.length} variables differ
        </p>
        <Button
          variant="outline"
          size="sm"
          onClick={() => setShowAll((prev) => !prev)}
        >
          {showAll ? "Show changes only" : "Show all variables"}
        </Button>
      </div>

      {visibleDiffs.length === 0 ? (
        <p className="py-8 text-center text-muted-foreground">No differences found</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-40">Variable</TableHead>
              <TableHead>{jobALabel}</TableHead>
              <TableHead>{jobBLabel}</TableHead>
              <TableHead className="w-28">Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {visibleDiffs.map((diff) => {
              const badge = STATUS_BADGE[diff.status];
              return (
                <TableRow key={diff.name}>
                  <TableCell className="font-mono text-sm">{diff.name}</TableCell>
                  <TableCell
                    className={
                      diff.status === "removed" || diff.status === "changed"
                        ? "bg-red-50 dark:bg-red-950/20"
                        : ""
                    }
                  >
                    {formatVariableValue(diff.valueA) || (
                      <span className="text-muted-foreground italic">--</span>
                    )}
                  </TableCell>
                  <TableCell
                    className={
                      diff.status === "added" || diff.status === "changed"
                        ? "bg-green-50 dark:bg-green-950/20"
                        : ""
                    }
                  >
                    {formatVariableValue(diff.valueB) || (
                      <span className="text-muted-foreground italic">--</span>
                    )}
                  </TableCell>
                  <TableCell>
                    <Badge variant={badge.variant} className={badge.className}>
                      {badge.label}
                    </Badge>
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
