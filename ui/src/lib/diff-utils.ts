import type { JobResponse } from "@/types/job";
import type { VariableValues } from "@/types/bridge";

export interface FieldDiff {
  readonly field: string;
  readonly valueA: string;
  readonly valueB: string;
  readonly status: "unchanged" | "changed";
}

export interface VariableDiff {
  readonly name: string;
  readonly valueA: string | string[] | undefined;
  readonly valueB: string | string[] | undefined;
  readonly status: "added" | "removed" | "changed" | "unchanged";
}

const DIFFABLE_FIELDS: readonly (keyof JobResponse)[] = [
  "description",
  "version",
  "atmosphere",
  "ocean",
  "slab",
  "mesoscale",
];

export function computeJobFieldDiffs(
  jobA: JobResponse,
  jobB: JobResponse,
): readonly FieldDiff[] {
  return DIFFABLE_FIELDS.map((field) => ({
    field,
    valueA: jobA[field],
    valueB: jobB[field],
    status: jobA[field] === jobB[field] ? "unchanged" : "changed",
  }));
}

function valuesEqual(
  a: string | string[] | undefined,
  b: string | string[] | undefined,
): boolean {
  if (a === b) return true;
  if (a === undefined || b === undefined) return false;
  if (typeof a === "string" && typeof b === "string") return a === b;
  if (Array.isArray(a) && Array.isArray(b)) {
    return a.length === b.length && a.every((v, i) => v === b[i]);
  }
  return false;
}

export function computeVariableDiffs(
  varsA: VariableValues,
  varsB: VariableValues,
): readonly VariableDiff[] {
  const allKeys = new Set([...Object.keys(varsA), ...Object.keys(varsB)]);
  const diffs: VariableDiff[] = [];

  for (const name of [...allKeys].sort()) {
    const valueA = varsA[name];
    const valueB = varsB[name];
    const inA = name in varsA;
    const inB = name in varsB;

    let status: VariableDiff["status"];
    if (!inA) {
      status = "added";
    } else if (!inB) {
      status = "removed";
    } else if (valuesEqual(valueA, valueB)) {
      status = "unchanged";
    } else {
      status = "changed";
    }

    diffs.push({ name, valueA, valueB, status });
  }

  return diffs;
}

export function formatVariableValue(value: string | string[] | undefined): string {
  if (value === undefined) return "";
  if (typeof value === "string") return value;
  return value.join(", ");
}
