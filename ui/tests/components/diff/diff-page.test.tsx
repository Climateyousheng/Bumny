import { describe, it, expect } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { DiffPage } from "@/components/diff/diff-page";

function renderDiff(expId = "xqgt") {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername="testuser">
        <MemoryRouter initialEntries={[`/experiments/${expId}/diff`]}>
          <Routes>
            <Route
              path="/experiments/:expId/diff"
              element={<DiffPage />}
            />
          </Routes>
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>,
  );
}

describe("DiffPage", () => {
  it("renders job selectors with jobs loaded", async () => {
    renderDiff();

    await waitFor(() => {
      expect(screen.getByLabelText("Job A")).toBeInTheDocument();
      expect(screen.getByLabelText("Job B")).toBeInTheDocument();
    });
  });

  it("auto-selects first two jobs and shows diff tables", async () => {
    renderDiff();

    await waitFor(() => {
      expect(screen.getByText("Job Fields")).toBeInTheDocument();
      expect(screen.getByText("Basis Variables")).toBeInTheDocument();
    });
  });

  it("shows changed badge for different variable values", async () => {
    renderDiff();

    // Job a has OCAAA=1, Job b has OCAAA=2 (per mock handlers)
    await waitFor(() => {
      const badges = screen.getAllByText("changed");
      expect(badges.length).toBeGreaterThanOrEqual(1);
    });
  });

  it("shows added badge when variable exists only in one job", async () => {
    renderDiff();

    // Job b has EXTRA_VAR=yes, Job a does not
    await waitFor(() => {
      expect(screen.getByText("added")).toBeInTheDocument();
    });
  });

  it("allows toggling show all variables", async () => {
    renderDiff();

    await waitFor(() => {
      expect(screen.getByText("Show all variables")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("Show all variables"));

    expect(screen.getByText("Show changes only")).toBeInTheDocument();
  });

  it("has a back link to experiment detail", async () => {
    renderDiff();

    await waitFor(() => {
      expect(screen.getByRole("link", { name: /back/i })).toHaveAttribute(
        "href",
        "/experiments/xqgt",
      );
    });
  });
});
