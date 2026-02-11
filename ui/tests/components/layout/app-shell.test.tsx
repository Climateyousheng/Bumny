import { describe, it, expect, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { AppShell } from "@/components/layout/app-shell";

function renderShell() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername="testuser">
        <MemoryRouter initialEntries={["/"]}>
          <Routes>
            <Route element={<AppShell />}>
              <Route index element={<div>Child Content</div>} />
            </Route>
          </Routes>
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>,
  );
}

describe("AppShell", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders the header", () => {
    renderShell();
    expect(screen.getByText("UMUI")).toBeInTheDocument();
  });

  it("renders child content via Outlet", () => {
    renderShell();
    expect(screen.getByText("Child Content")).toBeInTheDocument();
  });

  it("does not show user prompt when username is set", () => {
    renderShell();
    expect(screen.queryByText("Welcome to UMUI")).not.toBeInTheDocument();
  });
});
