import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Lock, Unlock } from "lucide-react";
import { useLockStatus, useAcquireLock, useReleaseLock } from "@/hooks/use-locks";
import { useUser } from "@/hooks/use-user";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";
import { toast } from "sonner";

interface LockStatusCardProps {
  readonly expId: string;
  readonly jobId: string;
}

export function LockStatusCard({ expId, jobId }: LockStatusCardProps) {
  const { username } = useUser();
  const { data: lockStatus, isLoading, error } = useLockStatus(expId, jobId);
  const acquireLock = useAcquireLock(expId, jobId);
  const releaseLock = useReleaseLock(expId, jobId);

  function handleAcquire() {
    acquireLock.mutate(false, {
      onSuccess: (result) => {
        if (result.success) {
          toast.success("Lock acquired");
        } else {
          toast.error(result.message);
        }
      },
      onError: (err) => {
        toast.error(err.message);
      },
    });
  }

  function handleRelease() {
    releaseLock.mutate(undefined, {
      onSuccess: (result) => {
        if (result.success) {
          toast.success("Lock released");
        } else {
          toast.error(result.message);
        }
      },
      onError: (err) => {
        toast.error(err.message);
      },
    });
  }

  if (isLoading) return <LoadingSkeleton />;
  if (error) return <ErrorAlert message={error.message} />;
  if (!lockStatus) return null;

  const isLockedByMe = lockStatus.locked && lockStatus.owner === username;
  const isLockedByOther = lockStatus.locked && lockStatus.owner !== username;

  return (
    <Card>
      <CardHeader>
        <CardTitle>Lock Status</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center gap-3">
          {lockStatus.locked ? (
            <>
              <Badge variant="destructive" className="gap-1">
                <Lock className="h-3 w-3" />
                Locked
              </Badge>
              <span className="text-sm text-muted-foreground">by {lockStatus.owner}</span>
            </>
          ) : (
            <Badge variant="secondary" className="gap-1">
              <Unlock className="h-3 w-3" />
              Available
            </Badge>
          )}
        </div>
        <div className="flex gap-2">
          {!lockStatus.locked && (
            <Button onClick={handleAcquire} disabled={acquireLock.isPending} size="sm">
              <Lock className="mr-2 h-3 w-3" />
              {acquireLock.isPending ? "Acquiring..." : "Acquire Lock"}
            </Button>
          )}
          {isLockedByMe && (
            <Button onClick={handleRelease} disabled={releaseLock.isPending} variant="outline" size="sm">
              <Unlock className="mr-2 h-3 w-3" />
              {releaseLock.isPending ? "Releasing..." : "Release Lock"}
            </Button>
          )}
          {isLockedByOther && (
            <p className="text-sm text-muted-foreground">
              This job is locked by {lockStatus.owner}. You cannot edit it until the lock is released.
            </p>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
