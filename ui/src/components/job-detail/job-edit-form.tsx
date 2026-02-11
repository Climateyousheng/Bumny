import { useState } from "react";
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useUpdateJob } from "@/hooks/use-jobs";
import { toast } from "sonner";
import type { JobResponse } from "@/types/job";

interface JobEditFormProps {
  readonly job: JobResponse;
  readonly onCancel: () => void;
}

export function JobEditForm({ job, onCancel }: JobEditFormProps) {
  const [description, setDescription] = useState(job.description);
  const [version, setVersion] = useState(job.version);
  const [atmosphere, setAtmosphere] = useState(job.atmosphere);
  const [ocean, setOcean] = useState(job.ocean);
  const [slab, setSlab] = useState(job.slab);
  const [mesoscale, setMesoscale] = useState(job.mesoscale);
  const updateJob = useUpdateJob(job.exp_id, job.job_id);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    updateJob.mutate(
      { description, version, atmosphere, ocean, slab, mesoscale },
      {
        onSuccess: () => {
          toast.success("Job updated");
          onCancel();
        },
        onError: (err) => {
          toast.error(err.message);
        },
      },
    );
  }

  return (
    <Card>
      <form onSubmit={handleSubmit}>
        <CardHeader>
          <CardTitle>Edit Job</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="edit-job-description">Description</Label>
              <Input id="edit-job-description" value={description} onChange={(e) => setDescription(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-job-version">Version</Label>
              <Input id="edit-job-version" value={version} onChange={(e) => setVersion(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-job-atmosphere">Atmosphere</Label>
              <Input id="edit-job-atmosphere" value={atmosphere} onChange={(e) => setAtmosphere(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-job-ocean">Ocean</Label>
              <Input id="edit-job-ocean" value={ocean} onChange={(e) => setOcean(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-job-slab">Slab</Label>
              <Input id="edit-job-slab" value={slab} onChange={(e) => setSlab(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-job-mesoscale">Mesoscale</Label>
              <Input id="edit-job-mesoscale" value={mesoscale} onChange={(e) => setMesoscale(e.target.value)} />
            </div>
          </div>
        </CardContent>
        <CardFooter className="justify-end gap-2">
          <Button type="button" variant="outline" onClick={onCancel}>
            Cancel
          </Button>
          <Button type="submit" disabled={updateJob.isPending}>
            {updateJob.isPending ? "Saving..." : "Save"}
          </Button>
        </CardFooter>
      </form>
    </Card>
  );
}
