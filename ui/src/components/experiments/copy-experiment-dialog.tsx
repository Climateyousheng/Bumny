import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useCopyExperiment } from "@/hooks/use-experiments";
import { toast } from "sonner";
import type { ExperimentResponse } from "@/types/experiment";

interface CopyExperimentDialogProps {
  readonly experiment: ExperimentResponse;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function CopyExperimentDialog({ experiment, open, onOpenChange }: CopyExperimentDialogProps) {
  const [initial, setInitial] = useState("");
  const [description, setDescription] = useState(experiment.description);
  const copyExperiment = useCopyExperiment(experiment.id);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    copyExperiment.mutate(
      { initial: initial.trim(), description: description.trim() },
      {
        onSuccess: (data) => {
          toast.success(`Experiment copied as ${data.id}`);
          onOpenChange(false);
          setInitial("");
        },
        onError: (err) => {
          toast.error(err.message);
        },
      },
    );
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <form onSubmit={handleSubmit}>
          <DialogHeader>
            <DialogTitle>Copy Experiment {experiment.id}</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="copy-initial">Initial for New Experiment</Label>
              <Input
                id="copy-initial"
                value={initial}
                onChange={(e) => setInitial(e.target.value)}
                placeholder="e.g. xqgt"
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="copy-description">Description</Label>
              <Input
                id="copy-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                required
              />
            </div>
          </div>
          <DialogFooter className="mt-4">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={copyExperiment.isPending}>
              {copyExperiment.isPending ? "Copying..." : "Copy"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
