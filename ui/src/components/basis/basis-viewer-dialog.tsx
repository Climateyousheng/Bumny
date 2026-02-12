import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { ErrorAlert } from "@/components/shared/error-alert";
import { BasisViewer } from "./basis-viewer";
import { useBasisRaw } from "@/hooks/use-basis";

interface BasisViewerDialogProps {
  readonly expId: string;
  readonly jobId: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function BasisViewerDialog({
  expId,
  jobId,
  open,
  onOpenChange,
}: BasisViewerDialogProps) {
  const { data, isLoading, error } = useBasisRaw(expId, jobId, {
    enabled: open,
  });

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl max-h-[90vh]">
        <DialogHeader>
          <DialogTitle>
            Raw Basis — {expId}/{jobId}
          </DialogTitle>
        </DialogHeader>

        {error && <ErrorAlert message={error.message} />}

        <BasisViewer
          content={data?.content ?? ""}
          lineCount={data?.line_count ?? 0}
          loading={isLoading}
        />
      </DialogContent>
    </Dialog>
  );
}
