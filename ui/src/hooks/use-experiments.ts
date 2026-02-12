import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { queryKeys } from "@/lib/query-keys";
import * as api from "@/lib/api-client";
import type { CreateExperimentRequest, UpdateExperimentRequest, CopyExperimentRequest } from "@/types/experiment";

export function useExperiments() {
  return useQuery({
    queryKey: queryKeys.experiments.all,
    queryFn: api.listExperiments,
    select: (data) => data.experiments,
  });
}

export function useExperiment(
  expId: string,
  options?: { readonly enabled?: boolean },
) {
  return useQuery({
    queryKey: queryKeys.experiments.detail(expId),
    queryFn: () => api.getExperiment(expId),
    enabled: options?.enabled,
  });
}

export function useCreateExperiment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: CreateExperimentRequest) => api.createExperiment(body),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.experiments.all });
    },
  });
}

export function useUpdateExperiment(expId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: UpdateExperimentRequest) => api.updateExperiment(expId, body),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.experiments.detail(expId) });
      void queryClient.invalidateQueries({ queryKey: queryKeys.experiments.all });
    },
  });
}

export function useDeleteExperiment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (expId: string) => api.deleteExperiment(expId),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.experiments.all });
    },
  });
}

export function useCopyExperiment(expId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: CopyExperimentRequest) => api.copyExperiment(expId, body),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.experiments.all });
    },
  });
}
