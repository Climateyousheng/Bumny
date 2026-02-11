import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { ExperimentDetailPage } from "@/components/experiment-detail/experiment-detail-page";

function renderWithRoute(expId: string) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername="nd20983">
        <MemoryRouter initialEntries={[`/experiments/${expId}`]}>
          <Routes>
            <Route path="/experiments/:expId" element={<ExperimentDetailPage />} />
          </Routes>
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>,
  );
}

describe("ExperimentDetailPage", () => {
  beforeEach(() => {
    setUsername("nd20983");
  });

  it("displays experiment details", async () => {
    renderWithRoute("xqgt");
    await waitFor(() => {
      expect(screen.getByText("Experiment Details")).toBeInTheDocument();
    });
    expect(screen.getByText("nd20983")).toBeInTheDocument();
  });

  it("displays jobs table", async () => {
    renderWithRoute("xqgt");
    await waitFor(() => {
      expect(screen.getByText("Jobs")).toBeInTheDocument();
    });
  });

  it("shows edit button for owner", async () => {
    renderWithRoute("xqgt");
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /edit/i })).toBeInTheDocument();
    });
  });
});
