import { Link } from "react-router-dom";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { ExperimentRowActions } from "./experiment-row-actions";
import type { ExperimentResponse } from "@/types/experiment";

interface ExperimentTableProps {
  readonly experiments: readonly ExperimentResponse[];
}

export function ExperimentTable({ experiments }: ExperimentTableProps) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>ID</TableHead>
          <TableHead>Owner</TableHead>
          <TableHead>Description</TableHead>
          <TableHead>Version</TableHead>
          <TableHead>Privacy</TableHead>
          <TableHead className="w-[50px]" />
        </TableRow>
      </TableHeader>
      <TableBody>
        {experiments.map((exp) => (
          <TableRow key={exp.id}>
            <TableCell>
              <Link to={`/experiments/${exp.id}`} className="font-mono font-medium text-primary hover:underline">
                {exp.id}
              </Link>
            </TableCell>
            <TableCell>{exp.owner}</TableCell>
            <TableCell className="max-w-xs truncate">{exp.description}</TableCell>
            <TableCell>{exp.version}</TableCell>
            <TableCell>
              <Badge variant={exp.privacy === "Y" ? "destructive" : "secondary"}>
                {exp.privacy === "Y" ? "Private" : "Public"}
              </Badge>
            </TableCell>
            <TableCell>
              <ExperimentRowActions experiment={exp} />
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
