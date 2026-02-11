import { useState } from "react";
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
import { Button } from "@/components/ui/button";
import { JobRowActions } from "./job-row-actions";
import { CreateJobDialog } from "./create-job-dialog";
import { EmptyState } from "@/components/shared/empty-state";
import { Plus } from "lucide-react";
import type { JobResponse } from "@/types/job";

interface JobTableProps {
  readonly expId: string;
  readonly jobs: readonly JobResponse[];
}

export function JobTable({ expId, jobs }: JobTableProps) {
  const [createOpen, setCreateOpen] = useState(false);

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <Button size="sm" onClick={() => setCreateOpen(true)}>
          <Plus className="mr-2 h-3 w-3" />
          New Job
        </Button>
      </div>
      {jobs.length > 0 ? (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Job ID</TableHead>
              <TableHead>Description</TableHead>
              <TableHead>Version</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="w-[50px]" />
            </TableRow>
          </TableHeader>
          <TableBody>
            {jobs.map((job) => (
              <TableRow key={job.job_id}>
                <TableCell>
                  <Link
                    to={`/experiments/${expId}/jobs/${job.job_id}`}
                    className="font-mono font-medium text-primary hover:underline"
                  >
                    {job.job_id}
                  </Link>
                </TableCell>
                <TableCell className="max-w-xs truncate">{job.description}</TableCell>
                <TableCell>{job.version}</TableCell>
                <TableCell>
                  <Badge variant={job.opened ? "default" : "secondary"}>
                    {job.opened ? "Locked" : "Available"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <JobRowActions expId={expId} job={job} />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <EmptyState title="No jobs" description="Create a job to get started" />
      )}
      <CreateJobDialog expId={expId} open={createOpen} onOpenChange={setCreateOpen} />
    </div>
  );
}
