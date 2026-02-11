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
import { useCreateExperiment } from "@/hooks/use-experiments";
import { toast } from "sonner";

interface CreateExperimentDialogProps {
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function CreateExperimentDialog({ open, onOpenChange }: CreateExperimentDialogProps) {
  const [initial, setInitial] = useState("");
  const [description, setDescription] = useState("");
  const [privacy, setPrivacy] = useState("N");
  const createExperiment = useCreateExperiment();

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    createExperiment.mutate(
      { initial: initial.trim(), description: description.trim(), privacy },
      {
        onSuccess: (data) => {
          toast.success(`Experiment ${data.id} created`);
          onOpenChange(false);
          setInitial("");
          setDescription("");
          setPrivacy("N");
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
            <DialogTitle>Create Experiment</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="initial">Initial Experiment ID</Label>
              <Input
                id="initial"
                value={initial}
                onChange={(e) => setInitial(e.target.value)}
                placeholder="e.g. xqgt"
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Input
                id="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Experiment description"
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="privacy">Privacy</Label>
              <select
                id="privacy"
                value={privacy}
                onChange={(e) => setPrivacy(e.target.value)}
                className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm"
              >
                <option value="N">Public</option>
                <option value="Y">Private</option>
              </select>
            </div>
          </div>
          <DialogFooter className="mt-4">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={createExperiment.isPending}>
              {createExperiment.isPending ? "Creating..." : "Create"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
