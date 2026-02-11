import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { NavTree } from "@/components/bridge/nav-tree";
import { buildNavNode } from "../../mocks/fixtures";

const tree = [
  buildNavNode({
    name: "modsel",
    label: "Model Selection",
    node_type: "node",
    children: [
      buildNavNode({ name: "personal_gen", label: "General details", node_type: "panel" }),
      buildNavNode({
        name: "atmos",
        label: "Atmosphere",
        node_type: "node",
        children: [
          buildNavNode({ name: "atmos_Domain_Horiz", label: "Horizontal", node_type: "panel" }),
        ],
      }),
    ],
  }),
];

describe("NavTree", () => {
  it("renders root nodes", () => {
    render(
      <NavTree
        nodes={tree}
        expandedNodes={new Set()}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={vi.fn()}
      />,
    );
    expect(screen.getByText("Model Selection")).toBeInTheDocument();
  });

  it("hides children when collapsed", () => {
    render(
      <NavTree
        nodes={tree}
        expandedNodes={new Set()}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={vi.fn()}
      />,
    );
    expect(screen.queryByText("General details")).not.toBeInTheDocument();
  });

  it("shows children when expanded", () => {
    render(
      <NavTree
        nodes={tree}
        expandedNodes={new Set(["modsel"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={vi.fn()}
      />,
    );
    expect(screen.getByText("General details")).toBeInTheDocument();
    expect(screen.getByText("Atmosphere")).toBeInTheDocument();
  });

  it("shows nested children when parent chain expanded", () => {
    render(
      <NavTree
        nodes={tree}
        expandedNodes={new Set(["modsel", "atmos"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={vi.fn()}
      />,
    );
    expect(screen.getByText("Horizontal")).toBeInTheDocument();
  });

  it("calls onToggle when clicking branch node", async () => {
    const onToggle = vi.fn();
    render(
      <NavTree
        nodes={tree}
        expandedNodes={new Set()}
        selectedWindowId={null}
        onToggle={onToggle}
        onSelect={vi.fn()}
      />,
    );
    await userEvent.click(screen.getByText("Model Selection"));
    expect(onToggle).toHaveBeenCalledWith("modsel");
  });

  it("calls onSelect when clicking leaf node", async () => {
    const onSelect = vi.fn();
    render(
      <NavTree
        nodes={tree}
        expandedNodes={new Set(["modsel"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={onSelect}
      />,
    );
    await userEvent.click(screen.getByText("General details"));
    expect(onSelect).toHaveBeenCalledWith("personal_gen");
  });

  it("highlights selected leaf", () => {
    render(
      <NavTree
        nodes={tree}
        expandedNodes={new Set(["modsel"])}
        selectedWindowId="personal_gen"
        onToggle={vi.fn()}
        onSelect={vi.fn()}
      />,
    );
    const button = screen.getByText("General details").closest("button");
    expect(button).toHaveAttribute("aria-current", "page");
  });
});

describe("NavTree – follow_on nodes", () => {
  it("hides follow_on nodes from the tree", () => {
    const nodes = [
      buildNavNode({
        name: "parent",
        label: "Parent",
        node_type: "node",
        children: [
          buildNavNode({ name: "visible_panel", label: "Visible", node_type: "panel" }),
          buildNavNode({ name: "hidden_follow", label: "Hidden", node_type: "follow_on" }),
        ],
      }),
    ];
    render(
      <NavTree
        nodes={nodes}
        expandedNodes={new Set(["parent"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={vi.fn()}
      />,
    );
    expect(screen.getByText("Visible")).toBeInTheDocument();
    expect(screen.queryByText("Hidden")).not.toBeInTheDocument();
  });

  it("treats panel with only follow_on children as a leaf", () => {
    const nodes = [
      buildNavNode({
        name: "parent",
        label: "Parent",
        node_type: "node",
        children: [
          buildNavNode({
            name: "output_panel",
            label: "Output choices",
            node_type: "panel",
            children: [
              buildNavNode({ name: "follow_win", label: "Follow-on", node_type: "follow_on" }),
            ],
          }),
        ],
      }),
    ];
    const onSelect = vi.fn();
    render(
      <NavTree
        nodes={nodes}
        expandedNodes={new Set(["parent"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={onSelect}
      />,
    );
    // Should be a clickable leaf, not an expandable folder
    const button = screen.getByText("Output choices").closest("button");
    expect(button).toBeInTheDocument();
    expect(button).not.toHaveAttribute("aria-expanded");
  });
});

describe("NavTree – shared panels", () => {
  it("renders shared panels as clickable leaves with distinct styling", () => {
    const nodes = [
      buildNavNode({
        name: "parent",
        label: "Parent",
        node_type: "node",
        children: [
          buildNavNode({ name: "smcc_OASIS", label: "OASIS Coupling", node_type: "shared" }),
        ],
      }),
    ];
    const onSelect = vi.fn();
    render(
      <NavTree
        nodes={nodes}
        expandedNodes={new Set(["parent"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={onSelect}
      />,
    );
    expect(screen.getByText("OASIS Coupling")).toBeInTheDocument();
  });

  it("calls onSelect when clicking shared panel", async () => {
    const nodes = [
      buildNavNode({
        name: "parent",
        label: "Parent",
        node_type: "node",
        children: [
          buildNavNode({ name: "smcc_OASIS", label: "OASIS Coupling", node_type: "shared" }),
        ],
      }),
    ];
    const onSelect = vi.fn();
    render(
      <NavTree
        nodes={nodes}
        expandedNodes={new Set(["parent"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={onSelect}
      />,
    );
    await userEvent.click(screen.getByText("OASIS Coupling"));
    expect(onSelect).toHaveBeenCalledWith("smcc_OASIS");
  });
});

describe("NavTree – panel with sub-panels", () => {
  it("renders panel with sub-panels as both clickable and expandable", async () => {
    const nodes = [
      buildNavNode({
        name: "parent",
        label: "Parent",
        node_type: "node",
        children: [
          buildNavNode({
            name: "io_services",
            label: "IO Services",
            node_type: "panel",
            children: [
              buildNavNode({ name: "ios_gen", label: "General IOS", node_type: "panel" }),
              buildNavNode({ name: "ios_mpi", label: "MPI Options", node_type: "panel" }),
            ],
          }),
        ],
      }),
    ];
    const onSelect = vi.fn();
    const onToggle = vi.fn();
    render(
      <NavTree
        nodes={nodes}
        expandedNodes={new Set(["parent"])}
        selectedWindowId={null}
        onToggle={onToggle}
        onSelect={onSelect}
      />,
    );

    // Clicking the label selects the panel
    await userEvent.click(screen.getByText("IO Services"));
    expect(onSelect).toHaveBeenCalledWith("io_services");

    // The expand button exists separately
    const expandBtn = screen.getByLabelText("Expand");
    expect(expandBtn).toBeInTheDocument();
    await userEvent.click(expandBtn);
    expect(onToggle).toHaveBeenCalledWith("io_services");
  });

  it("shows sub-panels when panel-with-children is expanded", () => {
    const nodes = [
      buildNavNode({
        name: "parent",
        label: "Parent",
        node_type: "node",
        children: [
          buildNavNode({
            name: "io_services",
            label: "IO Services",
            node_type: "panel",
            children: [
              buildNavNode({ name: "ios_gen", label: "General IOS", node_type: "panel" }),
            ],
          }),
        ],
      }),
    ];
    render(
      <NavTree
        nodes={nodes}
        expandedNodes={new Set(["parent", "io_services"])}
        selectedWindowId={null}
        onToggle={vi.fn()}
        onSelect={vi.fn()}
      />,
    );
    expect(screen.getByText("General IOS")).toBeInTheDocument();
  });
});
