import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderWithProviders, screen, userEvent } from "../../test-utils";
import { setUsername } from "@/lib/user-store";
import { ExplorerTable } from "@/components/explorer/explorer-table";
import { buildExperiment } from "../../mocks/fixtures";

const experiments = [
  buildExperiment({ id: "aaaa", owner: "hadsm", description: "Standard atmosphere" }),
  buildExperiment({ id: "xqgt", owner: "nd20983", description: "Control run" }),
];

describe("ExplorerTable", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders experiment rows with expand buttons", () => {
    renderWithProviders(
      <ExplorerTable
        experiments={experiments}
        expandedIds={new Set()}
        selectedIds={new Set()}
        onToggleExpand={vi.fn()}
        onToggleSelect={vi.fn()}
        onSelectAll={vi.fn()}
      />,
    );
    expect(screen.getByText("aaaa")).toBeInTheDocument();
    expect(screen.getByText("xqgt")).toBeInTheDocument();
    expect(screen.getByLabelText("Expand aaaa")).toBeInTheDocument();
    expect(screen.getByLabelText("Expand xqgt")).toBeInTheDocument();
  });

  it("calls onToggleExpand when expand button clicked", async () => {
    const user = userEvent.setup();
    const onToggleExpand = vi.fn();
    renderWithProviders(
      <ExplorerTable
        experiments={experiments}
        expandedIds={new Set()}
        selectedIds={new Set()}
        onToggleExpand={onToggleExpand}
        onToggleSelect={vi.fn()}
        onSelectAll={vi.fn()}
      />,
    );
    await user.click(screen.getByLabelText("Expand aaaa"));
    expect(onToggleExpand).toHaveBeenCalledWith("aaaa");
  });

  it("shows collapse label when expanded", () => {
    renderWithProviders(
      <ExplorerTable
        experiments={experiments}
        expandedIds={new Set(["aaaa"])}
        selectedIds={new Set()}
        onToggleExpand={vi.fn()}
        onToggleSelect={vi.fn()}
        onSelectAll={vi.fn()}
      />,
    );
    expect(screen.getByLabelText("Collapse aaaa")).toBeInTheDocument();
    expect(screen.getByLabelText("Expand xqgt")).toBeInTheDocument();
  });

  it("toggles selection via checkbox", async () => {
    const user = userEvent.setup();
    const onToggleSelect = vi.fn();
    renderWithProviders(
      <ExplorerTable
        experiments={experiments}
        expandedIds={new Set()}
        selectedIds={new Set()}
        onToggleExpand={vi.fn()}
        onToggleSelect={onToggleSelect}
        onSelectAll={vi.fn()}
      />,
    );
    await user.click(screen.getByLabelText("Select aaaa"));
    expect(onToggleSelect).toHaveBeenCalledWith("aaaa");
  });

  it("select-all checkbox calls onSelectAll", async () => {
    const user = userEvent.setup();
    const onSelectAll = vi.fn();
    renderWithProviders(
      <ExplorerTable
        experiments={experiments}
        expandedIds={new Set()}
        selectedIds={new Set()}
        onToggleExpand={vi.fn()}
        onToggleSelect={vi.fn()}
        onSelectAll={onSelectAll}
      />,
    );
    await user.click(screen.getByLabelText("Select all"));
    expect(onSelectAll).toHaveBeenCalled();
  });

  it("shows privacy badges", () => {
    const exps = [
      buildExperiment({ id: "pub1", privacy: "N" }),
      buildExperiment({ id: "prv1", privacy: "Y" }),
    ];
    renderWithProviders(
      <ExplorerTable
        experiments={exps}
        expandedIds={new Set()}
        selectedIds={new Set()}
        onToggleExpand={vi.fn()}
        onToggleSelect={vi.fn()}
        onSelectAll={vi.fn()}
      />,
    );
    expect(screen.getByText("Public")).toBeInTheDocument();
    expect(screen.getByText("Private")).toBeInTheDocument();
  });
});
