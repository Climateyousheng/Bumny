import { describe, it, expect } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import {
  useNavTree,
  useWindow,
  useWindowHelp,
  useRegister,
  usePartitions,
  useVariables,
  useWindowVariables,
} from "@/hooks/use-bridge";

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return function Wrapper({ children }: { readonly children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

describe("useNavTree", () => {
  it("fetches navigation tree", async () => {
    const { result } = renderHook(() => useNavTree(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toBeDefined();
    expect(result.current.data!.length).toBeGreaterThan(0);
    expect(result.current.data![0]!.name).toBe("modsel");
  });
});

describe("useWindow", () => {
  it("fetches window definition when winId is provided", async () => {
    const { result } = renderHook(() => useWindow("atmos_Domain_Horiz"), {
      wrapper: createWrapper(),
    });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data!.win_id).toBe("atmos_Domain_Horiz");
    expect(result.current.data!.components.length).toBeGreaterThan(0);
  });

  it("does not fetch when winId is null", () => {
    const { result } = renderHook(() => useWindow(null), { wrapper: createWrapper() });
    expect(result.current.fetchStatus).toBe("idle");
  });
});

describe("useWindowHelp", () => {
  it("fetches help text", async () => {
    const { result } = renderHook(() => useWindowHelp("atmos_Domain_Horiz"), {
      wrapper: createWrapper(),
    });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data!.win_id).toBe("atmos_Domain_Horiz");
    expect(result.current.data!.text).toBeTruthy();
  });

  it("does not fetch when winId is null", () => {
    const { result } = renderHook(() => useWindowHelp(null), { wrapper: createWrapper() });
    expect(result.current.fetchStatus).toBe("idle");
  });
});

describe("useRegister", () => {
  it("fetches variable register", async () => {
    const { result } = renderHook(() => useRegister(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data!.length).toBe(2);
  });
});

describe("usePartitions", () => {
  it("fetches partition definitions", async () => {
    const { result } = renderHook(() => usePartitions(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data!.length).toBe(1);
    expect(result.current.data![0]!.key).toBe("a");
  });
});

describe("useVariables", () => {
  it("fetches and selects variables", async () => {
    const { result } = renderHook(() => useVariables("xqgt", "a"), {
      wrapper: createWrapper(),
    });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual({ OCAAA: "1", NCOLSAG: "96" });
  });
});

describe("useWindowVariables", () => {
  it("fetches window-scoped variables", async () => {
    const { result } = renderHook(
      () => useWindowVariables("xqgt", "a", "atmos_Domain_Horiz"),
      { wrapper: createWrapper() },
    );
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual({ OCAAA: "1", NCOLSAG: "96" });
  });

  it("does not fetch when winId is null", () => {
    const { result } = renderHook(() => useWindowVariables("xqgt", "a", null), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
  });
});
