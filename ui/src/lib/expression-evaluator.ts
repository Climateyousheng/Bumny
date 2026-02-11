/**
 * Evaluate UMUI conditional expressions used in .case and .invisible.
 *
 * Grammar (recursive-descent):
 *   expr     -> or_expr
 *   or_expr  -> and_expr ('||' and_expr)*
 *   and_expr -> not_expr ('&&' not_expr)*
 *   not_expr -> '!' not_expr | primary
 *   primary  -> '(' expr ')' | comparison | 'NEVER' | 'ALWAYS'
 *   comparison -> value ('==' | '!=') value
 *   value    -> IDENTIFIER | IDENTIFIER '(' INDEX ')' | LITERAL
 */

export type VariableMap = Record<string, string | string[]>;

export class ExpressionError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ExpressionError";
  }
}

export function evaluate(expression: string, variables: VariableMap): boolean {
  const expr = expression.trim();
  if (expr === "") return true;

  const parser = new Parser(expr, variables);
  const result = parser.parseExpr();

  if (parser.pos < parser.text.length) {
    const remaining = parser.text.slice(parser.pos).trim();
    if (remaining !== "") {
      throw new ExpressionError(
        `Unexpected trailing text: "${remaining}" in "${expression}"`,
      );
    }
  }

  return result;
}

class Parser {
  readonly text: string;
  readonly variables: VariableMap;
  pos: number;

  constructor(text: string, variables: VariableMap) {
    this.text = text;
    this.variables = variables;
    this.pos = 0;
  }

  parseExpr(): boolean {
    return this.orExpr();
  }

  private skipSpaces(): void {
    while (this.pos < this.text.length && this.text[this.pos] === " ") {
      this.pos += 1;
    }
  }

  private atEnd(): boolean {
    this.skipSpaces();
    return this.pos >= this.text.length;
  }

  private match(token: string): boolean {
    this.skipSpaces();
    if (this.text.slice(this.pos, this.pos + token.length) === token) {
      this.pos += token.length;
      return true;
    }
    return false;
  }

  private orExpr(): boolean {
    let left = this.andExpr();
    while (this.match("||")) {
      const right = this.andExpr();
      left = left || right;
    }
    return left;
  }

  private andExpr(): boolean {
    let left = this.notExpr();
    while (this.match("&&")) {
      const right = this.notExpr();
      left = left && right;
    }
    return left;
  }

  private notExpr(): boolean {
    this.skipSpaces();
    if (
      this.pos < this.text.length &&
      this.text[this.pos] === "!" &&
      this.pos + 1 < this.text.length &&
      this.text[this.pos + 1] !== "="
    ) {
      this.pos += 1;
      return !this.notExpr();
    }
    return this.primary();
  }

  private primary(): boolean {
    this.skipSpaces();

    if (this.atEnd()) {
      throw new ExpressionError("Unexpected end of expression");
    }

    // Parenthesised sub-expression
    if (this.text[this.pos] === "(") {
      this.pos += 1;
      const result = this.orExpr();
      this.skipSpaces();
      if (this.pos >= this.text.length || this.text[this.pos] !== ")") {
        throw new ExpressionError("Missing closing parenthesis");
      }
      this.pos += 1;
      return result;
    }

    // Keywords: NEVER / ALWAYS
    const keywords: [string, boolean][] = [["NEVER", false], ["ALWAYS", true]];
    for (const [keyword, value] of keywords) {
      if (this.text.slice(this.pos).startsWith(keyword)) {
        const end = this.pos + keyword.length;
        if (end >= this.text.length || !isAlphaNumeric(this.text[end]!)) {
          this.pos = end;
          return value;
        }
      }
    }

    // Must be a comparison
    return this.comparison();
  }

  private comparison(): boolean {
    const left = this.value();
    this.skipSpaces();

    if (this.match("==")) {
      const right = this.value();
      return left === right;
    } else if (this.match("!=")) {
      const right = this.value();
      return left !== right;
    } else {
      throw new ExpressionError(
        `Expected == or != at position ${this.pos} in "${this.text}"`,
      );
    }
  }

  private value(): string {
    this.skipSpaces();

    if (this.atEnd()) {
      throw new ExpressionError("Unexpected end of expression in value");
    }

    const ch = this.text[this.pos]!;

    // Quoted string
    if (ch === "'" || ch === '"') {
      return this.quotedString();
    }

    // Number (possibly negative)
    if (
      isDigit(ch) ||
      (ch === "-" &&
        this.pos + 1 < this.text.length &&
        isDigit(this.text[this.pos + 1]!))
    ) {
      return this.number();
    }

    // Identifier (possibly with subscript)
    if (isAlpha(ch) || ch === "_") {
      return this.identifier();
    }

    throw new ExpressionError(
      `Unexpected character "${ch}" at position ${this.pos} in "${this.text}"`,
    );
  }

  private quotedString(): string {
    const quote = this.text[this.pos]!;
    this.pos += 1;
    const start = this.pos;
    while (this.pos < this.text.length && this.text[this.pos] !== quote) {
      this.pos += 1;
    }
    if (this.pos >= this.text.length) {
      throw new ExpressionError("Unterminated string");
    }
    const val = this.text.slice(start, this.pos);
    this.pos += 1; // skip closing quote
    return val;
  }

  private number(): string {
    const start = this.pos;
    if (this.text[this.pos] === "-") {
      this.pos += 1;
    }
    while (
      this.pos < this.text.length &&
      (isDigit(this.text[this.pos]!) || this.text[this.pos] === ".")
    ) {
      this.pos += 1;
    }
    return this.text.slice(start, this.pos);
  }

  private identifier(): string {
    const start = this.pos;
    while (
      this.pos < this.text.length &&
      (isAlphaNumeric(this.text[this.pos]!) || this.text[this.pos] === "_")
    ) {
      this.pos += 1;
    }

    const name = this.text.slice(start, this.pos);
    this.skipSpaces();

    // Check for subscript: NAME(index)
    if (this.pos < this.text.length && this.text[this.pos] === "(") {
      this.pos += 1;
      const idxStart = this.pos;
      while (this.pos < this.text.length && this.text[this.pos] !== ")") {
        this.pos += 1;
      }
      if (this.pos >= this.text.length) {
        throw new ExpressionError(`Unterminated subscript for ${name}`);
      }
      const indexStr = this.text.slice(idxStart, this.pos);
      this.pos += 1; // skip ')'
      return this.resolveSubscript(name, indexStr);
    }

    return this.resolve(name);
  }

  private resolve(name: string): string {
    const val = this.variables[name];
    if (val === undefined) return "";
    if (Array.isArray(val)) {
      return val.length > 0 ? val[0]! : "";
    }
    return val;
  }

  private resolveSubscript(name: string, indexStr: string): string {
    const val = this.variables[name];
    if (val === undefined) return "";
    if (Array.isArray(val)) {
      const idx = parseInt(indexStr, 10) - 1; // 1-based to 0-based
      if (isNaN(idx) || idx < 0 || idx >= val.length) return "";
      return val[idx]!;
    }
    // scalar: return the value regardless of subscript
    if (typeof val === "string") return val;
    return "";
  }
}

function isDigit(ch: string): boolean {
  return ch >= "0" && ch <= "9";
}

function isAlpha(ch: string): boolean {
  return (ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z");
}

function isAlphaNumeric(ch: string): boolean {
  return isAlpha(ch) || isDigit(ch);
}
