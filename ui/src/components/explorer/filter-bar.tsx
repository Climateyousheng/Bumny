import { X } from "lucide-react";
import { SearchInput } from "@/components/shared/search-input";
import { Button } from "@/components/ui/button";
import type { ExplorerFilters } from "@/lib/filter-experiments";
import { EMPTY_FILTERS } from "@/lib/filter-experiments";

interface FilterBarProps {
  readonly filters: ExplorerFilters;
  readonly onFiltersChange: (filters: ExplorerFilters) => void;
  readonly owners: readonly string[];
  readonly versions: readonly string[];
}

export function FilterBar({ filters, onFiltersChange, owners, versions }: FilterBarProps) {
  const hasFilters =
    filters.search !== "" ||
    filters.owner !== "" ||
    filters.version !== "" ||
    filters.privacy !== "";

  return (
    <div className="flex flex-wrap items-center gap-3">
      <div className="w-64">
        <SearchInput
          value={filters.search}
          onChange={(search) => onFiltersChange({ ...filters, search })}
          placeholder="Search experiments..."
        />
      </div>
      <select
        value={filters.owner}
        onChange={(e) => onFiltersChange({ ...filters, owner: e.target.value })}
        aria-label="Filter by owner"
        className="h-9 rounded-md border border-input bg-background px-3 text-sm"
      >
        <option value="">All owners</option>
        {owners.map((o) => (
          <option key={o} value={o}>
            {o}
          </option>
        ))}
      </select>
      <select
        value={filters.version}
        onChange={(e) => onFiltersChange({ ...filters, version: e.target.value })}
        aria-label="Filter by version"
        className="h-9 rounded-md border border-input bg-background px-3 text-sm"
      >
        <option value="">All versions</option>
        {versions.map((v) => (
          <option key={v} value={v}>
            {v}
          </option>
        ))}
      </select>
      <select
        value={filters.privacy}
        onChange={(e) => onFiltersChange({ ...filters, privacy: e.target.value })}
        aria-label="Filter by privacy"
        className="h-9 rounded-md border border-input bg-background px-3 text-sm"
      >
        <option value="">All</option>
        <option value="Y">Private</option>
        <option value="N">Public</option>
      </select>
      {hasFilters && (
        <Button
          variant="ghost"
          size="sm"
          onClick={() => onFiltersChange(EMPTY_FILTERS)}
          aria-label="Clear filters"
        >
          <X className="mr-1 h-3 w-3" />
          Clear
        </Button>
      )}
    </div>
  );
}
