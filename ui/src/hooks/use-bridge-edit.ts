import { useState, useCallback, useMemo } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useLockStatus, useAcquireLock, useReleaseLock } from "@/hooks/use-locks";
import * as api from "@/lib/api-client";
import type { VariableValues } from "@/types/bridge";

export function useBridgeEdit(expId: string, jobId: string) {
  const [isEditing, setIsEditing] = useState(false);
  const [draftChanges, setDraftChanges] = useState<Record<string, string | string[]>>({});

  const lockStatus = useLockStatus(expId, jobId);
  const acquireLock = useAcquireLock(expId, jobId);
  const releaseLock = useReleaseLock(expId, jobId);

  const queryClient = useQueryClient();

  const saveMutation = useMutation({
    mutationFn: () => api.updateBridgeVariables(expId, jobId, draftChanges),
    onSuccess: () => {
      setDraftChanges({});
      void queryClient.invalidateQueries({ queryKey: ["bridge", "variables"] });
      void queryClient.invalidateQueries({ queryKey: ["bridge", "windows"] });
    },
  });

  const isDirty = useMemo(
    () => Object.keys(draftChanges).length > 0,
    [draftChanges],
  );

  const startEditing = useCallback(
    async (force?: boolean) => {
      await acquireLock.mutateAsync(force ?? false);
      setIsEditing(true);
    },
    [acquireLock],
  );

  const stopEditing = useCallback(async () => {
    await releaseLock.mutateAsync();
    setIsEditing(false);
    setDraftChanges({});
  }, [releaseLock]);

  const updateDraft = useCallback(
    (variable: string, value: string | string[]) => {
      setDraftChanges((prev) => ({ ...prev, [variable]: value }));
    },
    [],
  );

  const updateDraftArray = useCallback(
    (variable: string, index: number, value: string) => {
      setDraftChanges((prev) => {
        const existing = prev[variable];
        const arr = Array.isArray(existing) ? [...existing] : [];
        arr[index] = value;
        return { ...prev, [variable]: arr };
      });
    },
    [],
  );

  const save = useCallback(async () => {
    await saveMutation.mutateAsync();
  }, [saveMutation]);

  const resetDraft = useCallback(() => {
    setDraftChanges({});
  }, []);

  const mergeVariables = useCallback(
    (serverVars: VariableValues): VariableValues => ({
      ...serverVars,
      ...draftChanges,
    }),
    [draftChanges],
  );

  return {
    isEditing,
    isDirty,
    draftChanges,
    lockStatus,
    startEditing,
    stopEditing,
    updateDraft,
    updateDraftArray,
    save,
    resetDraft,
    mergeVariables,
    isSaving: saveMutation.isPending,
    isAcquiring: acquireLock.isPending,
  };
}
