import { describe, it, expect, beforeEach } from "vitest";
import { renderWithProviders, screen, waitFor, userEvent } from "../../test-utils";
import { setUsername } from "@/lib/user-store";
import { ExplorerPage } from "@/components/explorer/explorer-page";

describe("ExplorerPage", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders experiments in a table", async () => {
    renderWithProviders(<ExplorerPage />);
    await waitFor(() => {
      expect(screen.getByText("aaaa")).toBeInTheDocument();
    });
    expect(screen.getByText("xqgt")).toBeInTheDocument();
    expect(screen.getByText("xqjc")).toBeInTheDocument();
  });

  it("shows expand buttons for each experiment", async () => {
    renderWithProviders(<ExplorerPage />);
    await waitFor(() => {
      expect(screen.getByLabelText("Expand aaaa")).toBeInTheDocument();
    });
  });

  it("expands experiment to show jobs", async () => {
    const user = userEvent.setup();
    renderWithProviders(<ExplorerPage />);
    await waitFor(() => {
      expect(screen.getByLabelText("Expand aaaa")).toBeInTheDocument();
    });
    await user.click(screen.getByLabelText("Expand aaaa"));
    // Jobs are lazy-loaded; wait for them
    await waitFor(() => {
      expect(screen.getByText("Job A")).toBeInTheDocument();
    });
  });

  it("filters experiments by search", async () => {
    const user = userEvent.setup();
    renderWithProviders(<ExplorerPage />);
    await waitFor(() => {
      expect(screen.getByText("aaaa")).toBeInTheDocument();
    });
    await user.type(screen.getByLabelText("Search"), "control");
    expect(screen.queryByText("aaaa")).not.toBeInTheDocument();
    expect(screen.getByText("xqgt")).toBeInTheDocument();
  });

  it("shows New Experiment button", async () => {
    renderWithProviders(<ExplorerPage />);
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /new experiment/i })).toBeInTheDocument();
    });
  });

  it("shows bulk actions when experiments selected", async () => {
    const user = userEvent.setup();
    renderWithProviders(<ExplorerPage />);
    await waitFor(() => {
      expect(screen.getByLabelText("Select aaaa")).toBeInTheDocument();
    });
    await user.click(screen.getByLabelText("Select aaaa"));
    expect(screen.getByText("1 selected")).toBeInTheDocument();
  });

  it("select-all selects all visible experiments", async () => {
    const user = userEvent.setup();
    renderWithProviders(<ExplorerPage />);
    await waitFor(() => {
      expect(screen.getByLabelText("Select all")).toBeInTheDocument();
    });
    await user.click(screen.getByLabelText("Select all"));
    expect(screen.getByText("3 selected")).toBeInTheDocument();
  });
});
