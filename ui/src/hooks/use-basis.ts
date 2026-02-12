import { useQuery } from "@tanstack/react-query";
import { queryKeys } from "@/lib/query-keys";
import * as api from "@/lib/api-client";

export function useBasisRaw(
  expId: string,
  jobId: string,
  options?: { readonly enabled?: boolean },
) {
  return useQuery({
    queryKey: queryKeys.basis.raw(expId, jobId),
    queryFn: () => api.getBasisRaw(expId, jobId),
    enabled: options?.enabled,
    staleTime: Infinity,
  });
}
