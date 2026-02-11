import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { FieldDisplay } from "@/components/shared/field-display";
import { JobEditForm } from "./job-edit-form";
import { Pencil } from "lucide-react";
import type { JobResponse } from "@/types/job";

interface JobInfoCardProps {
  readonly job: JobResponse;
}

export function JobInfoCard({ job }: JobInfoCardProps) {
  const [editing, setEditing] = useState(false);

  if (editing) {
    return <JobEditForm job={job} onCancel={() => setEditing(false)} />;
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Job Details</CardTitle>
        <Button variant="outline" size="sm" onClick={() => setEditing(true)}>
          <Pencil className="mr-2 h-3 w-3" />
          Edit
        </Button>
      </CardHeader>
      <CardContent>
        <dl className="grid gap-4 sm:grid-cols-2">
          <FieldDisplay label="Job ID" value={job.job_id} />
          <FieldDisplay label="Experiment" value={job.exp_id} />
          <FieldDisplay label="Description" value={job.description} />
          <FieldDisplay label="Version" value={job.version} />
          <FieldDisplay label="Atmosphere" value={job.atmosphere} />
          <FieldDisplay label="Ocean" value={job.ocean} />
          <FieldDisplay label="Slab" value={job.slab} />
          <FieldDisplay label="Mesoscale" value={job.mesoscale} />
        </dl>
      </CardContent>
    </Card>
  );
}
