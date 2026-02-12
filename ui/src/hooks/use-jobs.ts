import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { queryKeys } from "@/lib/query-keys";
import * as api from "@/lib/api-client";
import type { CreateJobRequest, UpdateJobRequest, CopyJobRequest } from "@/types/job";

export function useJobs(expId: string) {
  return useQuery({
    queryKey: queryKeys.jobs.all(expId),
    queryFn: () => api.listJobs(expId),
    select: (data) => data.jobs,
  });
}

export function useJob(
  expId: string,
  jobId: string,
  options?: { readonly enabled?: boolean },
) {
  return useQuery({
    queryKey: queryKeys.jobs.detail(expId, jobId),
    queryFn: () => api.getJob(expId, jobId),
    enabled: options?.enabled,
  });
}

export function useCreateJob(expId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: CreateJobRequest) => api.createJob(expId, body),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.jobs.all(expId) });
    },
  });
}

export function useUpdateJob(expId: string, jobId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: UpdateJobRequest) => api.updateJob(expId, jobId, body),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.jobs.detail(expId, jobId) });
      void queryClient.invalidateQueries({ queryKey: queryKeys.jobs.all(expId) });
    },
  });
}

export function useDeleteJob(expId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (jobId: string) => api.deleteJob(expId, jobId),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.jobs.all(expId) });
    },
  });
}

export function useCopyJob(expId: string, jobId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: CopyJobRequest) => api.copyJob(expId, jobId, body),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.jobs.all(expId) });
    },
  });
}
