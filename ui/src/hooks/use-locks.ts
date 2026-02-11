import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { queryKeys } from "@/lib/query-keys";
import * as api from "@/lib/api-client";

export function useLockStatus(expId: string, jobId: string) {
  return useQuery({
    queryKey: queryKeys.locks.detail(expId, jobId),
    queryFn: () => api.checkLock(expId, jobId),
    refetchInterval: 30_000,
  });
}

export function useAcquireLock(expId: string, jobId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (force: boolean = false) => api.acquireLock(expId, jobId, force),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.locks.detail(expId, jobId) });
    },
  });
}

export function useReleaseLock(expId: string, jobId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => api.releaseLock(expId, jobId),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.locks.detail(expId, jobId) });
    },
  });
}
