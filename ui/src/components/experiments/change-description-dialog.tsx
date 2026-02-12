import { useState, useEffect } from "react";
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
import { useUpdateExperiment } from "@/hooks/use-experiments";
import { toast } from "sonner";

interface ChangeExpDescriptionDialogProps {
  readonly expId: string;
  readonly currentDescription: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function ChangeExpDescriptionDialog({
  expId,
  currentDescription,
  open,
  onOpenChange,
}: ChangeExpDescriptionDialogProps) {
  const [description, setDescription] = useState(currentDescription);
  const updateExperiment = useUpdateExperiment(expId);

  useEffect(() => {
    if (open) setDescription(currentDescription);
  }, [open, currentDescription]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    updateExperiment.mutate(
      { description: description.trim() },
      {
        onSuccess: () => {
          toast.success("Description updated");
          onOpenChange(false);
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
            <DialogTitle>Change Description — {expId}</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-2">
            <Label htmlFor="exp-description">Description</Label>
            <Input
              id="exp-description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
            />
          </div>
          <DialogFooter className="mt-4">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={updateExperiment.isPending}>
              {updateExperiment.isPending ? "Saving..." : "Save"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
