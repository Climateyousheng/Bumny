import { Link } from "react-router-dom";
import { useJobs } from "@/hooks/use-jobs";
import { Badge } from "@/components/ui/badge";
import { TableRow, TableCell } from "@/components/ui/table";
import { JobRowActions } from "@/components/jobs/job-row-actions";

interface ExplorerJobRowsProps {
  readonly expId: string;
  readonly colSpan: number;
}

export function ExplorerJobRows({ expId, colSpan }: ExplorerJobRowsProps) {
  const { data: jobs, isLoading, error } = useJobs(expId);

  if (isLoading) {
    return (
      <TableRow>
        <TableCell colSpan={colSpan} className="pl-12 text-muted-foreground text-sm">
          Loading jobs...
        </TableCell>
      </TableRow>
    );
  }

  if (error) {
    return (
      <TableRow>
        <TableCell colSpan={colSpan} className="pl-12 text-destructive text-sm">
          Failed to load jobs
        </TableCell>
      </TableRow>
    );
  }

  if (!jobs || jobs.length === 0) {
    return (
      <TableRow>
        <TableCell colSpan={colSpan} className="pl-12 text-muted-foreground text-sm">
          No jobs
        </TableCell>
      </TableRow>
    );
  }

  return (
    <>
      {jobs.map((job) => (
        <TableRow key={job.job_id} className="bg-muted/30">
          <TableCell />
          <TableCell />
          <TableCell className="font-mono pl-8">
            <Link
              to={`/experiments/${expId}/jobs/${job.job_id}`}
              className="text-primary hover:underline"
            >
              {job.job_id}
            </Link>
          </TableCell>
          <TableCell />
          <TableCell className="truncate max-w-[300px]">{job.description}</TableCell>
          <TableCell>{job.version}</TableCell>
          <TableCell>
            {job.opened.trim().length > 0 ? (
              <Badge variant="destructive">Locked</Badge>
            ) : (
              <Badge variant="secondary">Available</Badge>
            )}
          </TableCell>
          <TableCell>
            <JobRowActions expId={expId} job={job} />
          </TableCell>
        </TableRow>
      ))}
    </>
  );
}
