import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { ComponentRenderer } from "@/components/bridge/component-renderer";
import type { PanComponent, VariableValues } from "@/types/bridge";

const defaultProps = {
  variables: { OCAAA: "1", NCOLSAG: "96" } as VariableValues,
  allVariables: { OCAAA: "1", NCOLSAG: "96" } as VariableValues,
  onNavigate: vi.fn(),
};

describe("ComponentRenderer", () => {
  it("renders text component", () => {
    const component: PanComponent = { kind: "text", text: "Hello World", justify: "L" };
    render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByText("Hello World")).toBeInTheDocument();
  });

  it("renders entry component with resolved variable", () => {
    const component: PanComponent = {
      kind: "entry",
      label: "Columns",
      justify: "L",
      variable: "NCOLSAG",
      width: 10,
    };
    render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByDisplayValue("96")).toBeInTheDocument();
  });

  it("renders check component", () => {
    const component: PanComponent = {
      kind: "check",
      label: "Enable",
      justify: "L",
      variable: "FEAT",
      on_value: "Y",
      off_value: "N",
    };
    render(
      <ComponentRenderer
        component={component}
        variables={{ FEAT: "Y" }}
        allVariables={{}}
        onNavigate={vi.fn()}
      />,
    );
    expect(screen.getByRole("checkbox")).toBeChecked();
  });

  it("renders basrad component", () => {
    const component: PanComponent = {
      kind: "basrad",
      label: "Select Area",
      justify: "L",
      count: 2,
      orientation: "v",
      variable: "OCAAA",
      options: [["Global", "1"], ["Limited", "2"]],
    };
    render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByText("Global")).toBeInTheDocument();
    expect(screen.getByText("Limited")).toBeInTheDocument();
  });

  it("renders gap as spacer", () => {
    const component: PanComponent = { kind: "gap" };
    const { container } = render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(container.querySelector(".h-2")).toBeInTheDocument();
  });

  it("renders block with indentation", () => {
    const component: PanComponent = {
      kind: "block",
      indent: 1,
      children: [{ kind: "text", text: "Indented text", justify: "L" }],
    };
    render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByText("Indented text")).toBeInTheDocument();
  });

  it("renders case active when expression is true", () => {
    const component: PanComponent = {
      kind: "case",
      expression: "OCAAA==1",
      children: [{ kind: "text", text: "Visible content", justify: "L" }],
    };
    const { container } = render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByText("Visible content")).toBeInTheDocument();
    expect(container.querySelector(".opacity-40")).not.toBeInTheDocument();
  });

  it("renders case greyed out when expression is false", () => {
    const component: PanComponent = {
      kind: "case",
      expression: "OCAAA==2",
      children: [{ kind: "text", text: "Greyed content", justify: "L" }],
    };
    const { container } = render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByText("Greyed content")).toBeInTheDocument();
    expect(container.querySelector(".opacity-40")).toBeInTheDocument();
  });

  it("renders invisible children when expression is true", () => {
    const component: PanComponent = {
      kind: "invisible",
      expression: "OCAAA==1",
      children: [{ kind: "text", text: "Should be visible", justify: "L" }],
    };
    render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByText("Should be visible")).toBeInTheDocument();
  });

  it("hides invisible children when expression is false", () => {
    const component: PanComponent = {
      kind: "invisible",
      expression: "OCAAA==99",
      children: [{ kind: "text", text: "Should be hidden", justify: "L" }],
    };
    render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.queryByText("Should be hidden")).not.toBeInTheDocument();
  });

  it("renders pushnext button", () => {
    const onNavigate = vi.fn();
    const component: PanComponent = {
      kind: "pushnext",
      label: "Go Next",
      target_window: "next_win",
    };
    render(
      <ComponentRenderer
        component={component}
        variables={{}}
        allVariables={{}}
        onNavigate={onNavigate}
      />,
    );
    expect(screen.getByRole("button", { name: "Go Next" })).toBeInTheDocument();
  });

  it("returns null for element (table child)", () => {
    const component: PanComponent = {
      kind: "element",
      label: "Col",
      variable: "X",
      rows: "1",
      width: 5,
      mode: "entry",
    };
    const { container } = render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(container.innerHTML).toBe("");
  });

  it("falls back to true on expression error in case", () => {
    const component: PanComponent = {
      kind: "case",
      expression: "INVALID > EXPR",
      children: [{ kind: "text", text: "Fallback visible", justify: "L" }],
    };
    const { container } = render(<ComponentRenderer component={component} {...defaultProps} />);
    expect(screen.getByText("Fallback visible")).toBeInTheDocument();
    expect(container.querySelector(".opacity-40")).not.toBeInTheDocument();
  });
});
