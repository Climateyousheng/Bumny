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
import { useUpdateJob } from "@/hooks/use-jobs";
import { toast } from "sonner";

interface ChangeJobDescriptionDialogProps {
  readonly expId: string;
  readonly jobId: string;
  readonly currentDescription: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function ChangeJobDescriptionDialog({
  expId,
  jobId,
  currentDescription,
  open,
  onOpenChange,
}: ChangeJobDescriptionDialogProps) {
  const [description, setDescription] = useState(currentDescription);
  const updateJob = useUpdateJob(expId, jobId);

  useEffect(() => {
    if (open) setDescription(currentDescription);
  }, [open, currentDescription]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    updateJob.mutate(
      { description: description.trim() },
      {
        onSuccess: () => {
          toast.success("Job description updated");
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
            <DialogTitle>Change Description — Job {jobId}</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-2">
            <Label htmlFor="job-description">Description</Label>
            <Input
              id="job-description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
            />
          </div>
          <DialogFooter className="mt-4">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={updateJob.isPending}>
              {updateJob.isPending ? "Saving..." : "Save"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
