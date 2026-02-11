import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { EntryDisplay } from "@/components/bridge/components/entry-display";
import type { EntryComponent } from "@/types/bridge";

const component: EntryComponent = {
  kind: "entry",
  label: "Number of columns",
  justify: "L",
  variable: "NCOLSAG",
  width: 10,
};

describe("EntryDisplay", () => {
  it("renders label and resolved value", () => {
    render(<EntryDisplay component={component} variables={{ NCOLSAG: "96" }} />);
    expect(screen.getByText("Number of columns")).toBeInTheDocument();
    expect(screen.getByDisplayValue("96")).toBeInTheDocument();
  });

  it("renders empty string for missing variable", () => {
    render(<EntryDisplay component={component} variables={{}} />);
    expect(screen.getByDisplayValue("")).toBeInTheDocument();
  });

  it("renders first element for array variable", () => {
    render(<EntryDisplay component={component} variables={{ NCOLSAG: ["96", "192"] }} />);
    expect(screen.getByDisplayValue("96")).toBeInTheDocument();
  });

  it("input is read-only", () => {
    render(<EntryDisplay component={component} variables={{ NCOLSAG: "96" }} />);
    const input = screen.getByDisplayValue("96");
    expect(input).toHaveAttribute("readonly");
  });
});
