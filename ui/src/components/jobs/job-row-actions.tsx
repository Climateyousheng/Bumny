import { useState } from "react";
import { Link } from "react-router-dom";
import { MoreHorizontal, Copy, Trash, FileCode } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { CopyJobDialog } from "./copy-job-dialog";
import { DeleteJobDialog } from "./delete-job-dialog";
import type { JobResponse } from "@/types/job";

interface JobRowActionsProps {
  readonly expId: string;
  readonly job: JobResponse;
}

export function JobRowActions({ expId, job }: JobRowActionsProps) {
  const [copyOpen, setCopyOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon" className="h-8 w-8" aria-label="Actions">
            <MoreHorizontal className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem asChild>
            <Link to={`/experiments/${expId}/jobs/${job.job_id}/bridge`}>
              <FileCode className="mr-2 h-4 w-4" />
              Open Bridge
            </Link>
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem onClick={() => setCopyOpen(true)}>
            <Copy className="mr-2 h-4 w-4" />
            Copy
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => setDeleteOpen(true)} className="text-destructive">
            <Trash className="mr-2 h-4 w-4" />
            Delete
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
      <CopyJobDialog expId={expId} job={job} open={copyOpen} onOpenChange={setCopyOpen} />
      <DeleteJobDialog expId={expId} job={job} open={deleteOpen} onOpenChange={setDeleteOpen} />
    </>
  );
}
