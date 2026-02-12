import { useReleaseLock } from "@/hooks/use-locks";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { toast } from "sonner";

interface ForceCloseDialogProps {
  readonly expId: string;
  readonly jobId: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function ForceCloseDialog({ expId, jobId, open, onOpenChange }: ForceCloseDialogProps) {
  const releaseLock = useReleaseLock(expId, jobId);

  function handleConfirm() {
    releaseLock.mutate(undefined, {
      onSuccess: () => {
        toast.success(`Lock released for job ${jobId}`);
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
      title={`Force close job ${jobId}?`}
      description="This will release the lock on this job, even if another user holds it. They may lose unsaved changes."
      confirmLabel="Force Close"
      onConfirm={handleConfirm}
      destructive
    />
  );
}
