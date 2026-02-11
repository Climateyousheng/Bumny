import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { FieldDisplay } from "@/components/shared/field-display";
import { ExperimentEditForm } from "./experiment-edit-form";
import { Pencil } from "lucide-react";
import type { ExperimentResponse } from "@/types/experiment";
import { useUser } from "@/hooks/use-user";

interface ExperimentInfoCardProps {
  readonly experiment: ExperimentResponse;
}

export function ExperimentInfoCard({ experiment }: ExperimentInfoCardProps) {
  const [editing, setEditing] = useState(false);
  const { username } = useUser();
  const isOwner = username === experiment.owner;

  if (editing) {
    return <ExperimentEditForm experiment={experiment} onCancel={() => setEditing(false)} />;
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Experiment Details</CardTitle>
        {isOwner && (
          <Button variant="outline" size="sm" onClick={() => setEditing(true)}>
            <Pencil className="mr-2 h-3 w-3" />
            Edit
          </Button>
        )}
      </CardHeader>
      <CardContent>
        <dl className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <FieldDisplay label="Owner" value={experiment.owner} />
          <FieldDisplay label="Description" value={experiment.description} />
          <FieldDisplay label="Version" value={experiment.version} />
          <FieldDisplay label="Atmosphere" value={experiment.atmosphere} />
          <FieldDisplay label="Ocean" value={experiment.ocean} />
          <FieldDisplay label="Slab" value={experiment.slab} />
          <FieldDisplay label="Mesoscale" value={experiment.mesoscale} />
          <FieldDisplay label="Access List" value={experiment.access_list} />
          <div className="space-y-1">
            <dt className="text-sm font-medium text-muted-foreground">Privacy</dt>
            <dd>
              <Badge variant={experiment.privacy === "Y" ? "destructive" : "secondary"}>
                {experiment.privacy === "Y" ? "Private" : "Public"}
              </Badge>
            </dd>
          </div>
        </dl>
      </CardContent>
    </Card>
  );
}
