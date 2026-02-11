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
import { useCreateJob } from "@/hooks/use-jobs";
import { toast } from "sonner";

interface CreateJobDialogProps {
  readonly expId: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function CreateJobDialog({ expId, open, onOpenChange }: CreateJobDialogProps) {
  const [jobId, setJobId] = useState("");
  const [description, setDescription] = useState("");
  const createJob = useCreateJob(expId);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    createJob.mutate(
      { job_id: jobId.trim(), description: description.trim() },
      {
        onSuccess: (data) => {
          toast.success(`Job ${data.job_id} created`);
          onOpenChange(false);
          setJobId("");
          setDescription("");
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
            <DialogTitle>Create Job</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="job-id">Job ID</Label>
              <Input
                id="job-id"
                value={jobId}
                onChange={(e) => setJobId(e.target.value)}
                placeholder="e.g. a"
                maxLength={1}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="job-description">Description</Label>
              <Input
                id="job-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Job description"
              />
            </div>
          </div>
          <DialogFooter className="mt-4">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={createJob.isPending}>
              {createJob.isPending ? "Creating..." : "Create"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
