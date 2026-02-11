import { describe, it, expect } from "vitest";
import { renderWithProviders, screen, waitFor, userEvent } from "../../test-utils";
import { BridgePage } from "@/components/bridge/bridge-page";

describe("BridgePage", () => {
  it("renders loading state initially", () => {
    renderWithProviders(<BridgePage />, {
      initialEntries: ["/experiments/xqgt/jobs/a/bridge"],
    });
    expect(screen.getByLabelText("Loading")).toBeInTheDocument();
  });

  it("renders navigation tree after loading", async () => {
    renderWithProviders(<BridgePage />, {
      initialEntries: ["/experiments/xqgt/jobs/a/bridge"],
    });
    await waitFor(() => {
      expect(screen.getByText("Model Selection")).toBeInTheDocument();
    });
  });

  it("shows placeholder when no window selected", async () => {
    renderWithProviders(<BridgePage />, {
      initialEntries: ["/experiments/xqgt/jobs/a/bridge"],
    });
    await waitFor(() => {
      expect(screen.getByText("Select a window from the navigation tree.")).toBeInTheDocument();
    });
  });

  it("expands tree node on click", async () => {
    renderWithProviders(<BridgePage />, {
      initialEntries: ["/experiments/xqgt/jobs/a/bridge"],
    });
    await waitFor(() => {
      expect(screen.getByText("Model Selection")).toBeInTheDocument();
    });
    await userEvent.click(screen.getByText("Model Selection"));
    expect(screen.getByText("General details")).toBeInTheDocument();
  });

  it("selects window and shows content", async () => {
    renderWithProviders(<BridgePage />, {
      initialEntries: ["/experiments/xqgt/jobs/a/bridge"],
    });
    await waitFor(() => {
      expect(screen.getByText("Model Selection")).toBeInTheDocument();
    });
    // Expand tree
    await userEvent.click(screen.getByText("Model Selection"));
    // Select leaf
    await userEvent.click(screen.getByText("General details"));
    // Window panel should load
    await waitFor(() => {
      expect(screen.getByText("Horizontal")).toBeInTheDocument();
    });
  });
});
