import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import type { FieldDiff } from "@/lib/diff-utils";

interface FieldDiffTableProps {
  readonly diffs: readonly FieldDiff[];
  readonly jobALabel: string;
  readonly jobBLabel: string;
}

export function FieldDiffTable({ diffs, jobALabel, jobBLabel }: FieldDiffTableProps) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-40">Field</TableHead>
          <TableHead>{jobALabel}</TableHead>
          <TableHead>{jobBLabel}</TableHead>
          <TableHead className="w-28">Status</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {diffs.map((diff) => (
          <TableRow key={diff.field}>
            <TableCell className="font-medium">{diff.field}</TableCell>
            <TableCell className={diff.status === "changed" ? "bg-red-50 dark:bg-red-950/20" : ""}>
              {diff.valueA || <span className="text-muted-foreground italic">empty</span>}
            </TableCell>
            <TableCell className={diff.status === "changed" ? "bg-green-50 dark:bg-green-950/20" : ""}>
              {diff.valueB || <span className="text-muted-foreground italic">empty</span>}
            </TableCell>
            <TableCell>
              {diff.status === "changed" ? (
                <Badge className="bg-yellow-100 text-yellow-800 border-yellow-200">changed</Badge>
              ) : (
                <Badge variant="secondary">unchanged</Badge>
              )}
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
