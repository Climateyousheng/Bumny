interface FieldDisplayProps {
  readonly label: string;
  readonly value: string;
}

export function FieldDisplay({ label, value }: FieldDisplayProps) {
  return (
    <div className="space-y-1">
      <dt className="text-sm font-medium text-muted-foreground">{label}</dt>
      <dd className="text-sm">{value || "\u2014"}</dd>
    </div>
  );
}
