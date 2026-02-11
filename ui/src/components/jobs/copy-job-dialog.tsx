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
import { useCopyJob } from "@/hooks/use-jobs";
import { toast } from "sonner";
import type { JobResponse } from "@/types/job";

interface CopyJobDialogProps {
  readonly expId: string;
  readonly job: JobResponse;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function CopyJobDialog({ expId, job, open, onOpenChange }: CopyJobDialogProps) {
  const [destExpId, setDestExpId] = useState(expId);
  const [destJobId, setDestJobId] = useState("");
  const [description, setDescription] = useState(job.description);
  const copyJob = useCopyJob(expId, job.job_id);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    copyJob.mutate(
      { dest_exp_id: destExpId.trim(), dest_job_id: destJobId.trim(), description: description.trim() },
      {
        onSuccess: (data) => {
          toast.success(`Job copied as ${data.exp_id}${data.job_id}`);
          onOpenChange(false);
          setDestJobId("");
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
            <DialogTitle>Copy Job {job.job_id}</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="dest-exp-id">Destination Experiment</Label>
              <Input
                id="dest-exp-id"
                value={destExpId}
                onChange={(e) => setDestExpId(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="dest-job-id">Destination Job ID</Label>
              <Input
                id="dest-job-id"
                value={destJobId}
                onChange={(e) => setDestJobId(e.target.value)}
                placeholder="e.g. b"
                maxLength={1}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="copy-job-description">Description</Label>
              <Input
                id="copy-job-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
              />
            </div>
          </div>
          <DialogFooter className="mt-4">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={copyJob.isPending}>
              {copyJob.isPending ? "Copying..." : "Copy"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
