import { useState } from "react";
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useUpdateExperiment } from "@/hooks/use-experiments";
import { toast } from "sonner";
import type { ExperimentResponse } from "@/types/experiment";

interface ExperimentEditFormProps {
  readonly experiment: ExperimentResponse;
  readonly onCancel: () => void;
}

export function ExperimentEditForm({ experiment, onCancel }: ExperimentEditFormProps) {
  const [description, setDescription] = useState(experiment.description);
  const [version, setVersion] = useState(experiment.version);
  const [atmosphere, setAtmosphere] = useState(experiment.atmosphere);
  const [ocean, setOcean] = useState(experiment.ocean);
  const [slab, setSlab] = useState(experiment.slab);
  const [mesoscale, setMesoscale] = useState(experiment.mesoscale);
  const [accessList, setAccessList] = useState(experiment.access_list);
  const [privacy, setPrivacy] = useState(experiment.privacy);
  const updateExperiment = useUpdateExperiment(experiment.id);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    updateExperiment.mutate(
      { description, version, atmosphere, ocean, slab, mesoscale, access_list: accessList, privacy },
      {
        onSuccess: () => {
          toast.success("Experiment updated");
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
          <CardTitle>Edit Experiment</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="edit-description">Description</Label>
              <Input id="edit-description" value={description} onChange={(e) => setDescription(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-version">Version</Label>
              <Input id="edit-version" value={version} onChange={(e) => setVersion(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-atmosphere">Atmosphere</Label>
              <Input id="edit-atmosphere" value={atmosphere} onChange={(e) => setAtmosphere(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-ocean">Ocean</Label>
              <Input id="edit-ocean" value={ocean} onChange={(e) => setOcean(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-slab">Slab</Label>
              <Input id="edit-slab" value={slab} onChange={(e) => setSlab(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-mesoscale">Mesoscale</Label>
              <Input id="edit-mesoscale" value={mesoscale} onChange={(e) => setMesoscale(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-access-list">Access List</Label>
              <Input id="edit-access-list" value={accessList} onChange={(e) => setAccessList(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-privacy">Privacy</Label>
              <select
                id="edit-privacy"
                value={privacy}
                onChange={(e) => setPrivacy(e.target.value)}
                className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm"
              >
                <option value="N">Public</option>
                <option value="Y">Private</option>
              </select>
            </div>
          </div>
        </CardContent>
        <CardFooter className="justify-end gap-2">
          <Button type="button" variant="outline" onClick={onCancel}>
            Cancel
          </Button>
          <Button type="submit" disabled={updateExperiment.isPending}>
            {updateExperiment.isPending ? "Saving..." : "Save"}
          </Button>
        </CardFooter>
      </form>
    </Card>
  );
}
