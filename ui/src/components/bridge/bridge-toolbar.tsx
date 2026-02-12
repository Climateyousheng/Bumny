import { useState } from "react";
import { Lock, Unlock, Save, RotateCcw, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import type { LockStatusResponse } from "@/types/lock";

interface BridgeToolbarProps {
  readonly lockStatus: LockStatusResponse | undefined;
  readonly isEditing: boolean;
  readonly isDirty: boolean;
  readonly isSaving: boolean;
  readonly isAcquiring: boolean;
  readonly onStartEditing: (force?: boolean) => Promise<void>;
  readonly onStopEditing: () => Promise<void>;
  readonly onSave: () => Promise<void>;
  readonly onReset: () => void;
}

export function BridgeToolbar({
  lockStatus,
  isEditing,
  isDirty,
  isSaving,
  isAcquiring,
  onStartEditing,
  onStopEditing,
  onSave,
  onReset,
}: BridgeToolbarProps) {
  const [forceConfirmOpen, setForceConfirmOpen] = useState(false);

  const isLocked = lockStatus?.locked ?? false;
  const lockOwner = lockStatus?.owner ?? null;

  const handleStartEditing = async () => {
    if (isLocked && lockOwner) {
      setForceConfirmOpen(true);
      return;
    }
    await onStartEditing();
  };

  const handleForceAcquire = async () => {
    setForceConfirmOpen(false);
    await onStartEditing(true);
  };

  return (
    <>
      <div className="flex items-center gap-2 border-b px-4 py-2">
        {/* Lock status */}
        {isLocked ? (
          <Badge variant="destructive" className="gap-1">
            <Lock className="h-3 w-3" />
            Locked by {lockOwner}
          </Badge>
        ) : (
          <Badge variant="secondary" className="gap-1">
            <Unlock className="h-3 w-3" />
            Available
          </Badge>
        )}

        <div className="flex-1" />

        {/* Edit controls */}
        {isEditing ? (
          <>
            <Button
              variant="outline"
              size="sm"
              disabled={!isDirty}
              onClick={onReset}
            >
              <RotateCcw className="mr-1 h-3 w-3" />
              Reset
            </Button>
            <Button
              size="sm"
              disabled={!isDirty || isSaving}
              onClick={() => void onSave()}
            >
              {isSaving ? (
                <Loader2 className="mr-1 h-3 w-3 animate-spin" />
              ) : (
                <Save className="mr-1 h-3 w-3" />
              )}
              Save
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => void onStopEditing()}
            >
              Stop Editing
            </Button>
          </>
        ) : (
          <Button
            size="sm"
            disabled={isAcquiring}
            onClick={() => void handleStartEditing()}
          >
            {isAcquiring && <Loader2 className="mr-1 h-3 w-3 animate-spin" />}
            Start Editing
          </Button>
        )}
      </div>

      {/* Force acquire confirmation */}
      <AlertDialog open={forceConfirmOpen} onOpenChange={setForceConfirmOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Force acquire lock?</AlertDialogTitle>
            <AlertDialogDescription>
              This job is currently locked by <strong>{lockOwner}</strong>. Force
              acquiring will override their lock. They may lose unsaved changes.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={() => void handleForceAcquire()}>
              Force Acquire
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
