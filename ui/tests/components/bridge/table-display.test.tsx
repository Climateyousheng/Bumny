import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { TableDisplay } from "@/components/bridge/components/table-display";
import type { TableComponent } from "@/types/bridge";

const component: TableComponent = {
  kind: "table",
  name: "test_table",
  header: "Test Table",
  orientation: "v",
  justify: "L",
  rows: "3",
  width: 10,
  validation: "",
  children: [
    {
      kind: "element",
      label: "Values",
      variable: "COL1",
      rows: "3",
      width: 10,
      mode: "entry",
    },
    {
      kind: "elementautonum",
      label: "Index",
      start: "1",
      end: "3",
      width: 5,
    },
  ],
};

describe("TableDisplay", () => {
  it("renders header", () => {
    render(<TableDisplay component={component} variables={{}} />);
    expect(screen.getByText("Test Table")).toBeInTheDocument();
  });

  it("renders column headers", () => {
    render(<TableDisplay component={component} variables={{}} />);
    expect(screen.getByText("Values")).toBeInTheDocument();
    expect(screen.getByText("Index")).toBeInTheDocument();
  });

  it("renders correct number of rows", () => {
    render(<TableDisplay component={component} variables={{ COL1: ["a", "b", "c"] }} />);
    const rows = screen.getAllByRole("row");
    // 1 header row + 3 data rows
    expect(rows).toHaveLength(4);
  });

  it("resolves array variable values into cells", () => {
    render(<TableDisplay component={component} variables={{ COL1: ["a", "b", "c"] }} />);
    expect(screen.getByText("a")).toBeInTheDocument();
    expect(screen.getByText("b")).toBeInTheDocument();
    expect(screen.getByText("c")).toBeInTheDocument();
  });

  it("renders autonum values", () => {
    render(<TableDisplay component={component} variables={{}} />);
    expect(screen.getByText("1")).toBeInTheDocument();
    expect(screen.getByText("2")).toBeInTheDocument();
    expect(screen.getByText("3")).toBeInTheDocument();
  });
});
