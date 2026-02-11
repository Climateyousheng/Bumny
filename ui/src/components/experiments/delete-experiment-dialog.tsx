import { useDeleteExperiment } from "@/hooks/use-experiments";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { toast } from "sonner";
import type { ExperimentResponse } from "@/types/experiment";

interface DeleteExperimentDialogProps {
  readonly experiment: ExperimentResponse;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function DeleteExperimentDialog({ experiment, open, onOpenChange }: DeleteExperimentDialogProps) {
  const deleteExperiment = useDeleteExperiment();

  function handleConfirm() {
    deleteExperiment.mutate(experiment.id, {
      onSuccess: () => {
        toast.success(`Experiment ${experiment.id} deleted`);
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
      title={`Delete experiment ${experiment.id}?`}
      description={`This will permanently delete experiment "${experiment.id}" and all its jobs. This action cannot be undone.`}
      confirmLabel="Delete"
      onConfirm={handleConfirm}
      destructive
    />
  );
}
