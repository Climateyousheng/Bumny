import { useState, useMemo } from "react";
import { useParams, Link } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";
import { EmptyState } from "@/components/shared/empty-state";
import { FieldDiffTable } from "./field-diff-table";
import { VariableDiffTable } from "./variable-diff-table";
import { useJobs, useJob } from "@/hooks/use-jobs";
import { useJobVariables } from "@/hooks/use-bridge";
import { computeJobFieldDiffs, computeVariableDiffs } from "@/lib/diff-utils";

export function DiffPage() {
  const { expId } = useParams<{ expId: string }>();
  const { data: jobs, isLoading: jobsLoading, error: jobsError } = useJobs(expId ?? "");

  const [jobAId, setJobAId] = useState<string>("");
  const [jobBId, setJobBId] = useState<string>("");

  // Auto-select first two jobs when loaded
  const resolvedA = jobAId || (jobs && jobs.length >= 1 ? jobs[0]!.job_id : "");
  const resolvedB = jobBId || (jobs && jobs.length >= 2 ? jobs[1]!.job_id : "");

  const bothSelected = resolvedA !== "" && resolvedB !== "" && resolvedA !== resolvedB;

  const { data: jobA, isLoading: jobALoading } = useJob(expId ?? "", resolvedA, {
    enabled: bothSelected,
  });
  const { data: jobB, isLoading: jobBLoading } = useJob(expId ?? "", resolvedB, {
    enabled: bothSelected,
  });
  const { data: varsA, isLoading: varsALoading } = useJobVariables(expId ?? "", resolvedA, {
    enabled: bothSelected,
  });
  const { data: varsB, isLoading: varsBLoading } = useJobVariables(expId ?? "", resolvedB, {
    enabled: bothSelected,
  });

  const fieldDiffs = useMemo(
    () => (jobA && jobB ? computeJobFieldDiffs(jobA, jobB) : []),
    [jobA, jobB],
  );

  const variableDiffs = useMemo(
    () => (varsA && varsB ? computeVariableDiffs(varsA, varsB) : []),
    [varsA, varsB],
  );

  const dataLoading = jobALoading || jobBLoading || varsALoading || varsBLoading;
  const jobALabel = `Job ${resolvedA}`;
  const jobBLabel = `Job ${resolvedB}`;

  if (!expId) {
    return <ErrorAlert message="Missing experiment ID" />;
  }

  return (
    <div className="container py-6 space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="sm" asChild>
          <Link to={`/experiments/${expId}`}>
            <ArrowLeft className="mr-1 h-4 w-4" />
            Back
          </Link>
        </Button>
        <h1 className="text-2xl font-bold">Job Difference — {expId}</h1>
      </div>

      {jobsError && <ErrorAlert message={jobsError.message} />}

      {jobsLoading ? (
        <Skeleton className="h-20 w-full" />
      ) : !jobs || jobs.length < 2 ? (
        <EmptyState
          title="Need at least two jobs"
          description="Create a second job to compare differences."
        />
      ) : (
        <>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-end gap-6">
                <div className="space-y-1">
                  <Label htmlFor="job-a-select">Job A</Label>
                  <select
                    id="job-a-select"
                    value={resolvedA}
                    onChange={(e) => setJobAId(e.target.value)}
                    className="flex h-9 w-32 rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm"
                  >
                    {jobs.map((j) => (
                      <option key={j.job_id} value={j.job_id}>
                        {j.job_id} — {j.description}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="space-y-1">
                  <Label htmlFor="job-b-select">Job B</Label>
                  <select
                    id="job-b-select"
                    value={resolvedB}
                    onChange={(e) => setJobBId(e.target.value)}
                    className="flex h-9 w-32 rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm"
                  >
                    {jobs.map((j) => (
                      <option key={j.job_id} value={j.job_id}>
                        {j.job_id} — {j.description}
                      </option>
                    ))}
                  </select>
                </div>
                {resolvedA === resolvedB && resolvedA !== "" && (
                  <p className="text-sm text-muted-foreground">Select two different jobs to compare.</p>
                )}
              </div>
            </CardContent>
          </Card>

          {bothSelected && dataLoading && (
            <div className="space-y-4">
              <Skeleton className="h-48 w-full" />
              <Skeleton className="h-48 w-full" />
            </div>
          )}

          {bothSelected && !dataLoading && jobA && jobB && (
            <>
              <Card>
                <CardHeader>
                  <CardTitle>Job Fields</CardTitle>
                </CardHeader>
                <CardContent>
                  <FieldDiffTable
                    diffs={fieldDiffs}
                    jobALabel={jobALabel}
                    jobBLabel={jobBLabel}
                  />
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Basis Variables</CardTitle>
                </CardHeader>
                <CardContent>
                  {varsA && varsB ? (
                    <VariableDiffTable
                      diffs={variableDiffs}
                      jobALabel={jobALabel}
                      jobBLabel={jobBLabel}
                    />
                  ) : (
                    <p className="text-sm text-muted-foreground">
                      Variable data unavailable.
                    </p>
                  )}
                </CardContent>
              </Card>
            </>
          )}
        </>
      )}
    </div>
  );
}
