import { useParams, Link } from "react-router-dom";
import { useJob } from "@/hooks/use-jobs";
import { JobInfoCard } from "./job-info-card";
import { LockStatusCard } from "./lock-status-card";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";
import { Button } from "@/components/ui/button";
import { ChevronLeft, Settings2 } from "lucide-react";

export function JobDetailPage() {
  const { expId, jobId } = useParams<{ expId: string; jobId: string }>();
  const { data: job, isLoading, error } = useJob(expId!, jobId!);

  if (isLoading) return <LoadingSkeleton />;
  if (error) return <ErrorAlert message={error.message} />;
  if (!job) return <ErrorAlert message="Job not found" />;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <Link to={`/experiments/${expId}`} className="text-muted-foreground hover:text-foreground">
          <ChevronLeft className="h-4 w-4" />
        </Link>
        <h1 className="text-2xl font-bold">
          <span className="font-mono">{expId}</span> / Job <span className="font-mono">{jobId}</span>
        </h1>
      </div>
      <Button variant="outline" asChild>
        <Link to={`/experiments/${expId}/jobs/${jobId}/bridge`}>
          <Settings2 className="mr-2 h-4 w-4" />
          Open Bridge
        </Link>
      </Button>
      <div className="grid gap-6 lg:grid-cols-2">
        <JobInfoCard job={job} />
        <LockStatusCard expId={expId!} jobId={jobId!} />
      </div>
    </div>
  );
}
