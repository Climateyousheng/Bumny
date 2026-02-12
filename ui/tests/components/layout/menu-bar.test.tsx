import { describe, it, expect, vi } from "vitest";
import { renderWithProviders, screen, userEvent } from "../../test-utils";
import { MenuBar } from "@/components/layout/menu-bar";

describe("MenuBar", () => {
  it("renders all five menu triggers", () => {
    renderWithProviders(<MenuBar />);
    expect(screen.getByRole("menuitem", { name: "File" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Search" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Experiment" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Job" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Help" })).toBeInTheDocument();
  });

  it("calls onCreateExperiment when clicking Experiment > New", async () => {
    const onCreateExperiment = vi.fn();
    renderWithProviders(<MenuBar onCreateExperiment={onCreateExperiment} />);

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));
    await userEvent.click(screen.getByRole("menuitem", { name: /new/i }));

    expect(onCreateExperiment).toHaveBeenCalledOnce();
  });

  it("disables Job > New when not on experiment page", async () => {
    renderWithProviders(<MenuBar />, { initialEntries: ["/"] });

    await userEvent.click(screen.getByRole("menuitem", { name: "Job" }));

    const newJobItem = screen.getByRole("menuitem", { name: /new/i });
    expect(newJobItem).toHaveAttribute("data-disabled");
  });
});
