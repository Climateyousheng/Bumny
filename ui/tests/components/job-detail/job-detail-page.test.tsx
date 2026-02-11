import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { JobDetailPage } from "@/components/job-detail/job-detail-page";

function renderWithRoute(expId: string, jobId: string) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername="testuser">
        <MemoryRouter initialEntries={[`/experiments/${expId}/jobs/${jobId}`]}>
          <Routes>
            <Route path="/experiments/:expId/jobs/:jobId" element={<JobDetailPage />} />
          </Routes>
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>,
  );
}

describe("JobDetailPage", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("displays job details", async () => {
    renderWithRoute("xqgt", "a");
    await waitFor(() => {
      expect(screen.getByText("Job Details")).toBeInTheDocument();
    });
  });

  it("displays lock status card", async () => {
    renderWithRoute("xqgt", "a");
    await waitFor(() => {
      expect(screen.getByText("Lock Status")).toBeInTheDocument();
    });
  });

  it("shows acquire lock button when unlocked", async () => {
    renderWithRoute("xqgt", "a");
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /acquire lock/i })).toBeInTheDocument();
    });
  });
});
