import { describe, it, expect, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import type { ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { useExperiments, useExperiment, useCreateExperiment } from "@/hooks/use-experiments";

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

describe("useExperiments", () => {
  it("fetches experiment list", async () => {
    const { result } = renderHook(() => useExperiments(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(3);
  });
});

describe("useExperiment", () => {
  it("fetches a single experiment", async () => {
    const { result } = renderHook(() => useExperiment("xqgt"), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe("xqgt");
  });
});

describe("useCreateExperiment", () => {
  it("creates an experiment", async () => {
    const { result } = renderHook(() => useCreateExperiment(), { wrapper: createWrapper() });
    result.current.mutate({ initial: "test", description: "New" });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe("newx");
  });
});
