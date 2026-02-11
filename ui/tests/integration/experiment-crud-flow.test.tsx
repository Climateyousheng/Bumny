import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { ExperimentListPage } from "@/components/experiments/experiment-list-page";
import { ExperimentDetailPage } from "@/components/experiment-detail/experiment-detail-page";

function renderApp(initialEntries = ["/"]) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername="nd20983">
        <MemoryRouter initialEntries={initialEntries}>
          <Routes>
            <Route index element={<ExperimentListPage />} />
            <Route path="/experiments/:expId" element={<ExperimentDetailPage />} />
          </Routes>
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>,
  );
}

describe("Experiment CRUD flow", () => {
  beforeEach(() => {
    setUsername("nd20983");
  });

  it("lists experiments and navigates to detail", async () => {
    renderApp();

    // Wait for experiment list to load
    await waitFor(() => {
      expect(screen.getByText("aaaa")).toBeInTheDocument();
    });
    expect(screen.getByText("xqgt")).toBeInTheDocument();
    expect(screen.getByText("xqjc")).toBeInTheDocument();
  });

  it("creates a new experiment via dialog", async () => {
    const user = userEvent.setup();
    renderApp();

    await waitFor(() => {
      expect(screen.getByText("Experiments")).toBeInTheDocument();
    });

    // Open create dialog
    await user.click(screen.getByRole("button", { name: /new experiment/i }));
    expect(screen.getByText("Create Experiment")).toBeInTheDocument();

    // Fill form
    await user.type(screen.getByLabelText("Initial Experiment ID"), "test");
    await user.type(screen.getByLabelText("Description"), "Integration test experiment");
    await user.click(screen.getByRole("button", { name: "Create" }));

    // Dialog should close
    await waitFor(() => {
      expect(screen.queryByText("Create Experiment")).not.toBeInTheDocument();
    });
  });

  it("searches and filters experiments", async () => {
    const user = userEvent.setup();
    renderApp();

    await waitFor(() => {
      expect(screen.getByText("aaaa")).toBeInTheDocument();
    });

    // Search for "control" — should only show xqgt
    await user.type(screen.getByLabelText("Search"), "Control");
    expect(screen.queryByText("aaaa")).not.toBeInTheDocument();
    expect(screen.getByText("xqgt")).toBeInTheDocument();
  });

  it("shows experiment detail with edit button for owner", async () => {
    renderApp(["/experiments/xqgt"]);

    await waitFor(() => {
      expect(screen.getByText("Experiment Details")).toBeInTheDocument();
    });

    // Owner should see edit button
    expect(screen.getByRole("button", { name: /edit/i })).toBeInTheDocument();
    expect(screen.getByText("nd20983")).toBeInTheDocument();
  });

  it("opens edit form on experiment detail", async () => {
    const user = userEvent.setup();
    renderApp(["/experiments/xqgt"]);

    await waitFor(() => {
      expect(screen.getByRole("button", { name: /edit/i })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: /edit/i }));
    expect(screen.getByText("Edit Experiment")).toBeInTheDocument();
    expect(screen.getByLabelText("Description")).toBeInTheDocument();
  });

  it("shows delete confirmation dialog", async () => {
    const user = userEvent.setup();
    renderApp();

    await waitFor(() => {
      expect(screen.getByText("xqgt")).toBeInTheDocument();
    });

    // Find the row with xqgt and click its actions menu
    const rows = screen.getAllByRole("row");
    const xqgtRow = rows.find((row) => within(row).queryByText("xqgt"));
    expect(xqgtRow).toBeDefined();

    const actionsBtn = within(xqgtRow!).getByRole("button", { name: "Actions" });
    await user.click(actionsBtn);

    // Click delete in dropdown
    await user.click(screen.getByText("Delete"));

    // Confirm dialog appears
    await waitFor(() => {
      expect(screen.getByText(/delete experiment xqgt/i)).toBeInTheDocument();
    });
  });
});
