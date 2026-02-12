import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { BridgePage } from "@/components/bridge/bridge-page";

function renderBridge(expId = "xqgt", jobId = "a") {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername="testuser">
        <MemoryRouter initialEntries={[`/experiments/${expId}/jobs/${jobId}/bridge`]}>
          <Routes>
            <Route
              path="/experiments/:expId/jobs/:jobId/bridge"
              element={<BridgePage />}
            />
          </Routes>
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>,
  );
}

describe("Bridge edit flow", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders bridge page with nav tree", async () => {
    renderBridge();
    await waitFor(() => {
      expect(screen.getByText("Model Selection")).toBeInTheDocument();
    });
  });

  it("selects a window and shows its components", async () => {
    const user = userEvent.setup();
    renderBridge();

    await waitFor(() => {
      expect(screen.getByText("Model Selection")).toBeInTheDocument();
    });

    // Expand the "Model Selection" node to see children
    await user.click(screen.getByText("Model Selection"));

    // Click the "General details" panel
    await waitFor(() => {
      expect(screen.getByText("General details")).toBeInTheDocument();
    });
    await user.click(screen.getByText("General details"));

    // Window content should load
    await waitFor(() => {
      expect(screen.getByText("Select area option")).toBeInTheDocument();
    });
  });

  it("starts editing, changes a value, saves, and stops editing", async () => {
    const user = userEvent.setup();
    renderBridge();

    // Wait for page to load
    await waitFor(() => {
      expect(screen.getByText("Model Selection")).toBeInTheDocument();
    });

    // Navigate to a panel that has entry components
    await user.click(screen.getByText("Model Selection"));
    await waitFor(() => {
      expect(screen.getByText("General details")).toBeInTheDocument();
    });
    await user.click(screen.getByText("General details"));

    // Wait for window components to load (MSW returns entry with NCOLSAG=96)
    await waitFor(() => {
      expect(screen.getByDisplayValue("96")).toBeInTheDocument();
    });

    // Verify lock toolbar shows "Available"
    expect(screen.getByText("Available")).toBeInTheDocument();

    // Start editing (acquires lock)
    await user.click(screen.getByRole("button", { name: /start editing/i }));

    // After lock acquired, editing controls should appear
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /save/i })).toBeInTheDocument();
    });

    // The entry input should now be editable (not readonly)
    const input = screen.getByDisplayValue("96");
    expect(input).not.toHaveAttribute("readonly");

    // Change the value
    await user.clear(input);
    await user.type(input, "192");

    // Save should be enabled now (dirty)
    const saveBtn = screen.getByRole("button", { name: /save/i });
    expect(saveBtn).not.toBeDisabled();

    // Click save
    await user.click(saveBtn);

    // Save completes - button becomes disabled again (no more dirty changes)
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /save/i })).toBeDisabled();
    });

    // Stop editing
    await user.click(screen.getByRole("button", { name: /stop editing/i }));

    // Start Editing button should reappear
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /start editing/i })).toBeInTheDocument();
    });
  });
});
