import { useState } from "react";
import { MoreHorizontal, Copy, Trash } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { CopyExperimentDialog } from "./copy-experiment-dialog";
import { DeleteExperimentDialog } from "./delete-experiment-dialog";
import type { ExperimentResponse } from "@/types/experiment";

interface ExperimentRowActionsProps {
  readonly experiment: ExperimentResponse;
}

export function ExperimentRowActions({ experiment }: ExperimentRowActionsProps) {
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
      <CopyExperimentDialog experiment={experiment} open={copyOpen} onOpenChange={setCopyOpen} />
      <DeleteExperimentDialog experiment={experiment} open={deleteOpen} onOpenChange={setDeleteOpen} />
    </>
  );
}
