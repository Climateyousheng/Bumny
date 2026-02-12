import { describe, it, expect } from "vitest";
import { computeJobFieldDiffs, computeVariableDiffs, formatVariableValue } from "@/lib/diff-utils";
import { buildJob } from "../mocks/fixtures";

describe("computeJobFieldDiffs", () => {
  it("marks all fields unchanged for identical jobs", () => {
    const job = buildJob();
    const diffs = computeJobFieldDiffs(job, job);
    expect(diffs.every((d) => d.status === "unchanged")).toBe(true);
  });

  it("detects changed fields", () => {
    const jobA = buildJob({ description: "Control run", version: "8.6" });
    const jobB = buildJob({ description: "Sensitivity test", version: "8.7" });
    const diffs = computeJobFieldDiffs(jobA, jobB);

    const descDiff = diffs.find((d) => d.field === "description");
    expect(descDiff?.status).toBe("changed");
    expect(descDiff?.valueA).toBe("Control run");
    expect(descDiff?.valueB).toBe("Sensitivity test");

    const verDiff = diffs.find((d) => d.field === "version");
    expect(verDiff?.status).toBe("changed");
  });

  it("excludes job_id, exp_id, and opened from comparison", () => {
    const jobA = buildJob({ job_id: "a", exp_id: "xqgt", opened: "" });
    const jobB = buildJob({ job_id: "b", exp_id: "xqjc", opened: "nd20983" });
    const diffs = computeJobFieldDiffs(jobA, jobB);

    const fields = diffs.map((d) => d.field);
    expect(fields).not.toContain("job_id");
    expect(fields).not.toContain("exp_id");
    expect(fields).not.toContain("opened");
  });
});

describe("computeVariableDiffs", () => {
  it("returns empty for identical variables", () => {
    const vars = { A: "1", B: "2" };
    const diffs = computeVariableDiffs(vars, vars);
    expect(diffs.every((d) => d.status === "unchanged")).toBe(true);
  });

  it("detects added variables", () => {
    const diffs = computeVariableDiffs({ A: "1" }, { A: "1", B: "2" });
    const bDiff = diffs.find((d) => d.name === "B");
    expect(bDiff?.status).toBe("added");
    expect(bDiff?.valueA).toBeUndefined();
    expect(bDiff?.valueB).toBe("2");
  });

  it("detects removed variables", () => {
    const diffs = computeVariableDiffs({ A: "1", B: "2" }, { A: "1" });
    const bDiff = diffs.find((d) => d.name === "B");
    expect(bDiff?.status).toBe("removed");
    expect(bDiff?.valueA).toBe("2");
    expect(bDiff?.valueB).toBeUndefined();
  });

  it("detects changed variables", () => {
    const diffs = computeVariableDiffs({ A: "1" }, { A: "99" });
    const aDiff = diffs.find((d) => d.name === "A");
    expect(aDiff?.status).toBe("changed");
  });

  it("handles array variables correctly", () => {
    const diffs = computeVariableDiffs(
      { T: ["a", "b", "c"] },
      { T: ["a", "b", "d"] },
    );
    const tDiff = diffs.find((d) => d.name === "T");
    expect(tDiff?.status).toBe("changed");
  });

  it("treats identical arrays as unchanged", () => {
    const diffs = computeVariableDiffs(
      { T: ["a", "b"] },
      { T: ["a", "b"] },
    );
    const tDiff = diffs.find((d) => d.name === "T");
    expect(tDiff?.status).toBe("unchanged");
  });

  it("sorts results by variable name", () => {
    const diffs = computeVariableDiffs(
      { Z: "1", A: "2", M: "3" },
      { Z: "1", A: "2", M: "3" },
    );
    const names = diffs.map((d) => d.name);
    expect(names).toEqual(["A", "M", "Z"]);
  });
});

describe("formatVariableValue", () => {
  it("returns empty string for undefined", () => {
    expect(formatVariableValue(undefined)).toBe("");
  });

  it("returns string values as-is", () => {
    expect(formatVariableValue("42")).toBe("42");
  });

  it("joins array values with commas", () => {
    expect(formatVariableValue(["a", "b", "c"])).toBe("a, b, c");
  });
});
