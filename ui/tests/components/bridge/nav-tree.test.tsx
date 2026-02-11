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
