import { useDeleteJob } from "@/hooks/use-jobs";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { toast } from "sonner";
import type { JobResponse } from "@/types/job";

interface DeleteJobDialogProps {
  readonly expId: string;
  readonly job: JobResponse;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function DeleteJobDialog({ expId, job, open, onOpenChange }: DeleteJobDialogProps) {
  const deleteJob = useDeleteJob(expId);

  function handleConfirm() {
    deleteJob.mutate(job.job_id, {
      onSuccess: () => {
        toast.success(`Job ${job.job_id} deleted`);
        onOpenChange(false);
      },
      onError: (err) => {
        toast.error(err.message);
      },
    });
  }

  return (
    <ConfirmDialog
      open={open}
      onOpenChange={onOpenChange}
      title={`Delete job ${job.job_id}?`}
      description={`This will permanently delete job "${job.job_id}" from experiment "${expId}". This action cannot be undone.`}
      confirmLabel="Delete"
      onConfirm={handleConfirm}
      destructive
    />
  );
}
