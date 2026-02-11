import { useParams, Link } from "react-router-dom";
import { useExperiment } from "@/hooks/use-experiments";
import { useJobs } from "@/hooks/use-jobs";
import { ExperimentInfoCard } from "./experiment-info-card";
import { JobTable } from "@/components/jobs/job-table";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";
import { ChevronLeft } from "lucide-react";

export function ExperimentDetailPage() {
  const { expId } = useParams<{ expId: string }>();
  const { data: experiment, isLoading: expLoading, error: expError } = useExperiment(expId!);
  const { data: jobs, isLoading: jobsLoading, error: jobsError } = useJobs(expId!);

  if (expLoading || jobsLoading) return <LoadingSkeleton />;
  if (expError) return <ErrorAlert message={expError.message} />;
  if (jobsError) return <ErrorAlert message={jobsError.message} />;
  if (!experiment) return <ErrorAlert message="Experiment not found" />;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <Link to="/" className="text-muted-foreground hover:text-foreground">
          <ChevronLeft className="h-4 w-4" />
        </Link>
        <h1 className="text-2xl font-bold font-mono">{experiment.id}</h1>
      </div>
      <ExperimentInfoCard experiment={experiment} />
      <div className="space-y-4">
        <h2 className="text-xl font-semibold">Jobs</h2>
        <JobTable expId={expId!} jobs={jobs ?? []} />
      </div>
    </div>
  );
}
