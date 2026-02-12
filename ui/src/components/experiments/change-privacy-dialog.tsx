import { useState, useEffect } from "react";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { useUpdateExperiment } from "@/hooks/use-experiments";
import { toast } from "sonner";

interface ChangePrivacyDialogProps {
  readonly expId: string;
  readonly currentPrivacy: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function ChangePrivacyDialog({
  expId,
  currentPrivacy,
  open,
  onOpenChange,
}: ChangePrivacyDialogProps) {
  const [privacy, setPrivacy] = useState(currentPrivacy);
  const updateExperiment = useUpdateExperiment(expId);

  useEffect(() => {
    if (open) setPrivacy(currentPrivacy);
  }, [open, currentPrivacy]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    updateExperiment.mutate(
      { privacy },
      {
        onSuccess: () => {
          toast.success(`Privacy set to ${privacy === "Y" ? "Private" : "Public"}`);
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
            <DialogTitle>Change Privacy — {expId}</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-3">
            <Label>Privacy</Label>
            <div className="flex gap-4">
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="radio"
                  name="privacy"
                  value="N"
                  checked={privacy === "N"}
                  onChange={() => setPrivacy("N")}
                />
                Public
              </label>
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="radio"
                  name="privacy"
                  value="Y"
                  checked={privacy === "Y"}
                  onChange={() => setPrivacy("Y")}
                />
                Private
              </label>
            </div>
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
