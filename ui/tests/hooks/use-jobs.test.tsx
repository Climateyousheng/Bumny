import { describe, it, expect, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import type { ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { useJobs, useJob, useCreateJob } from "@/hooks/use-jobs";

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return function Wrapper({ children }: { readonly children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <UserProvider initialUsername="testuser">{children}</UserProvider>
      </QueryClientProvider>
    );
  };
}

beforeEach(() => {
  setUsername("testuser");
});

describe("useJobs", () => {
  it("fetches job list for an experiment", async () => {
    const { result } = renderHook(() => useJobs("xqgt"), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(2);
  });
});

describe("useJob", () => {
  it("fetches a single job", async () => {
    const { result } = renderHook(() => useJob("xqgt", "a"), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.job_id).toBe("a");
  });
});

describe("useCreateJob", () => {
  it("creates a job", async () => {
    const { result } = renderHook(() => useCreateJob("xqgt"), { wrapper: createWrapper() });
    result.current.mutate({ job_id: "c", description: "New" });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.job_id).toBe("c");
  });
});
