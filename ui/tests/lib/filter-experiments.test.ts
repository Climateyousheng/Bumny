import { describe, it, expect } from "vitest";
import { filterExperiments, type ExplorerFilters } from "@/lib/filter-experiments";
import { buildExperiment } from "../mocks/fixtures";

const experiments = [
  buildExperiment({ id: "aaaa", owner: "hadsm", description: "Standard atmosphere", version: "8.6", privacy: "N" }),
  buildExperiment({ id: "xqgt", owner: "nd20983", description: "Control run", version: "8.6", privacy: "Y" }),
  buildExperiment({ id: "xqjc", owner: "nd20983", description: "Sensitivity test", version: "7.3", privacy: "N" }),
];

const emptyFilters: ExplorerFilters = { search: "", owner: "", version: "", privacy: "" };

describe("filterExperiments", () => {
  it("returns all experiments with empty filters", () => {
    expect(filterExperiments(experiments, emptyFilters)).toEqual(experiments);
  });

  it("filters by search term matching ID", () => {
    const result = filterExperiments(experiments, { ...emptyFilters, search: "aaaa" });
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe("aaaa");
  });

  it("filters by search term matching owner", () => {
    const result = filterExperiments(experiments, { ...emptyFilters, search: "nd20983" });
    expect(result).toHaveLength(2);
  });

  it("filters by search term matching description (case-insensitive)", () => {
    const result = filterExperiments(experiments, { ...emptyFilters, search: "CONTROL" });
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe("xqgt");
  });

  it("filters by owner", () => {
    const result = filterExperiments(experiments, { ...emptyFilters, owner: "hadsm" });
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe("aaaa");
  });

  it("filters by version", () => {
    const result = filterExperiments(experiments, { ...emptyFilters, version: "7.3" });
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe("xqjc");
  });

  it("filters by privacy", () => {
    const result = filterExperiments(experiments, { ...emptyFilters, privacy: "Y" });
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe("xqgt");
  });

  it("combines multiple filters", () => {
    const result = filterExperiments(experiments, {
      search: "nd20983",
      owner: "nd20983",
      version: "8.6",
      privacy: "Y",
    });
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe("xqgt");
  });

  it("returns empty array when no matches", () => {
    const result = filterExperiments(experiments, { ...emptyFilters, search: "nonexistent" });
    expect(result).toHaveLength(0);
  });
});
