import { Trash, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

interface BulkActionsBarProps {
  readonly selectedCount: number;
  readonly onDelete: () => void;
  readonly onClearSelection: () => void;
}

export function BulkActionsBar({ selectedCount, onDelete, onClearSelection }: BulkActionsBarProps) {
  return (
    <div className="flex items-center gap-3 rounded-md bg-muted px-4 py-2">
      <span className="text-sm font-medium">{selectedCount} selected</span>
      <AlertDialog>
        <AlertDialogTrigger asChild>
          <Button variant="destructive" size="sm">
            <Trash className="mr-1 h-3 w-3" />
            Delete
          </Button>
        </AlertDialogTrigger>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete experiments</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete {selectedCount} experiment
              {selectedCount > 1 ? "s" : ""}? This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={onDelete}>Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
      <Button variant="ghost" size="sm" onClick={onClearSelection} aria-label="Clear selection">
        <X className="h-3 w-3" />
      </Button>
    </div>
  );
}
