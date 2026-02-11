import { useQuery } from "@tanstack/react-query";
import { queryKeys } from "@/lib/query-keys";
import * as api from "@/lib/api-client";

export function useNavTree() {
  return useQuery({
    queryKey: queryKeys.bridge.nav,
    queryFn: api.getNavTree,
    staleTime: Infinity,
  });
}

export function useWindow(winId: string | null, expId?: string, jobId?: string) {
  return useQuery({
    queryKey: queryKeys.bridge.window(winId ?? "", expId, jobId),
    queryFn: () => api.getWindow(winId!, expId, jobId),
    enabled: winId !== null,
  });
}

export function useWindowHelp(winId: string | null) {
  return useQuery({
    queryKey: queryKeys.bridge.windowHelp(winId ?? ""),
    queryFn: () => api.getWindowHelp(winId!),
    enabled: winId !== null,
    staleTime: Infinity,
  });
}

export function useRegister() {
  return useQuery({
    queryKey: queryKeys.bridge.register,
    queryFn: api.getRegister,
    staleTime: Infinity,
  });
}

export function usePartitions() {
  return useQuery({
    queryKey: queryKeys.bridge.partitions,
    queryFn: api.getPartitions,
    staleTime: Infinity,
  });
}

export function useWindowVariables(expId: string, jobId: string, winId: string | null) {
  return useQuery({
    queryKey: queryKeys.bridge.windowVariables(expId, jobId, winId ?? ""),
    queryFn: () => api.getWindowVariables(expId, jobId, winId!),
    enabled: winId !== null,
    select: (data) => data.variables,
  });
}
