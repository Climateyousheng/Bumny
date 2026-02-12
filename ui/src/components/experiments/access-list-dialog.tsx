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

interface AccessListDialogProps {
  readonly expId: string;
  readonly currentAccessList: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function AccessListDialog({
  expId,
  currentAccessList,
  open,
  onOpenChange,
}: AccessListDialogProps) {
  const [accessList, setAccessList] = useState(currentAccessList);
  const updateExperiment = useUpdateExperiment(expId);

  useEffect(() => {
    if (open) setAccessList(currentAccessList);
  }, [open, currentAccessList]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    updateExperiment.mutate(
      { access_list: accessList.trim() },
      {
        onSuccess: () => {
          toast.success("Access list updated");
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
            <DialogTitle>Access List — {expId}</DialogTitle>
          </DialogHeader>
          <div className="mt-4 space-y-2">
            <Label htmlFor="access-list">Usernames (comma-separated)</Label>
            <textarea
              id="access-list"
              value={accessList}
              onChange={(e) => setAccessList(e.target.value)}
              rows={4}
              className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
              placeholder="user1, user2, user3"
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
