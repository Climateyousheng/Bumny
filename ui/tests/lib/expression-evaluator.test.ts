import { describe, it, expect } from "vitest";
import { evaluate } from "@/lib/expression-evaluator";

describe("evaluate – basic comparisons", () => {
  it("equal true", () => {
    expect(evaluate('OCAAA==1', { OCAAA: "1" })).toBe(true);
  });

  it("equal false", () => {
    expect(evaluate('OCAAA==1', { OCAAA: "2" })).toBe(false);
  });

  it("not equal true", () => {
    expect(evaluate('OCAAA!=1', { OCAAA: "2" })).toBe(true);
  });

  it("not equal false", () => {
    expect(evaluate('OCAAA!=1', { OCAAA: "1" })).toBe(false);
  });

  it("string comparison true", () => {
    expect(evaluate('USE_TCA=="Y"', { USE_TCA: "Y" })).toBe(true);
  });

  it("string comparison false", () => {
    expect(evaluate('USE_TCA=="Y"', { USE_TCA: "N" })).toBe(false);
  });

  it("missing variable defaults to empty string", () => {
    expect(evaluate('X==1', {})).toBe(false);
    expect(evaluate('X==""', {})).toBe(true);
  });
});

describe("evaluate – logical operators", () => {
  it("or true", () => {
    expect(evaluate('A==1||B==2', { A: "1", B: "0" })).toBe(true);
  });

  it("or false", () => {
    expect(evaluate('A==1||B==2', { A: "0", B: "0" })).toBe(false);
  });

  it("and true", () => {
    expect(evaluate('A==1&&B==2', { A: "1", B: "2" })).toBe(true);
  });

  it("and false", () => {
    expect(evaluate('A==1&&B==2', { A: "1", B: "0" })).toBe(false);
  });

  it("chained or", () => {
    expect(evaluate('OCAAA==2||OCAAA==3||OCAAA==4', { OCAAA: "3" })).toBe(true);
  });

  it("parenthesised", () => {
    expect(
      evaluate('(USE_TCA=="Y")&&(OCAAA==2)', { USE_TCA: "Y", OCAAA: "2" }),
    ).toBe(true);
  });

  it("negation", () => {
    expect(evaluate('!(A==1)', { A: "2" })).toBe(true);
    expect(evaluate('!(A==1)', { A: "1" })).toBe(false);
  });

  it("complex expression", () => {
    const expr = '(ATMOS_SR(18)=="0A")||(AAS_AC=="N"&&AAS_IAU=="N")';
    const vars = { ATMOS_SR: ["x", "y"], AAS_AC: "N", AAS_IAU: "N" };
    expect(evaluate(expr, vars)).toBe(true);
  });
});

describe("evaluate – keywords", () => {
  it("NEVER -> false", () => {
    expect(evaluate("NEVER", {})).toBe(false);
  });

  it("ALWAYS -> true", () => {
    expect(evaluate("ALWAYS", {})).toBe(true);
  });
});

describe("evaluate – subscripts", () => {
  it("subscript access (1-based)", () => {
    const vars = { ATMOS_SR: ["0A", "1A", "0A"] };
    expect(evaluate('ATMOS_SR(1)=="0A"', vars)).toBe(true);
    expect(evaluate('ATMOS_SR(2)=="1A"', vars)).toBe(true);
  });

  it("subscript out of range returns empty string", () => {
    const vars = { ATMOS_SR: ["0A"] };
    expect(evaluate('ATMOS_SR(99)=="0A"', vars)).toBe(false);
  });

  it("subscript on scalar returns the scalar", () => {
    const vars = { X: "hello" };
    expect(evaluate('X(1)=="hello"', vars)).toBe(true);
  });
});

describe("evaluate – edge cases", () => {
  it("empty expression -> true", () => {
    expect(evaluate("", {})).toBe(true);
  });

  it("whitespace handling", () => {
    expect(evaluate(" A == 1 ", { A: "1" })).toBe(true);
  });

  it("quoted string with alphanumeric", () => {
    expect(evaluate('X=="0A"', { X: "0A" })).toBe(true);
  });

  it("not-equal with string", () => {
    expect(
      evaluate('ATMOS_SR(12)!="0A"', { ATMOS_SR: Array.from({ length: 12 }, () => "0A") }),
    ).toBe(false);
  });

  it("double-quoted string", () => {
    expect(evaluate('X=="hello"', { X: "hello" })).toBe(true);
  });

  it("numeric comparison (string-based)", () => {
    expect(evaluate("X==42", { X: "42" })).toBe(true);
  });

  it("single-quoted string", () => {
    expect(evaluate("X=='Y'", { X: "Y" })).toBe(true);
  });

  it("throws on invalid expression", () => {
    expect(() => evaluate("X > 1", { X: "2" })).toThrow();
  });

  it("throws on unterminated string", () => {
    expect(() => evaluate('X=="hello', { X: "hello" })).toThrow();
  });

  it("throws on missing closing paren", () => {
    expect(() => evaluate("(A==1", { A: "1" })).toThrow();
  });
});
