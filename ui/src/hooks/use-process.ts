import { useMutation } from "@tanstack/react-query";
import * as api from "@/lib/api-client";
import type { SubmitRequest } from "@/types/process";

export function useProcessJob() {
  return useMutation({
    mutationFn: ({ expId, jobId }: { expId: string; jobId: string }) =>
      api.processJob(expId, jobId),
  });
}

export function useSubmitJob() {
  return useMutation({
    mutationFn: ({
      expId,
      jobId,
      request,
    }: {
      expId: string;
      jobId: string;
      request: SubmitRequest;
    }) => api.submitJob(expId, jobId, request),
  });
}
