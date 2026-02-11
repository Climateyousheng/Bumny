// ---------------------------------------------------------------------------
// Navigation tree
// ---------------------------------------------------------------------------

export interface NavNodeResponse {
  readonly name: string;
  readonly label: string;
  readonly node_type: "node" | "panel" | "shared" | "repeated" | "follow_on";
  readonly children: readonly NavNodeResponse[];
}

// ---------------------------------------------------------------------------
// Window definitions
// ---------------------------------------------------------------------------

export interface WindowResponse {
  readonly win_id: string;
  readonly title: string;
  readonly win_type: "entry" | "dummy";
  readonly components: readonly PanComponent[];
}

export type PanComponent =
  | TextComponent
  | EntryComponent
  | CheckComponent
  | BasradComponent
  | GapComponent
  | BlockComponent
  | CaseComponent
  | InvisibleComponent
  | PushNextComponent
  | TableComponent
  | ElementComponent
  | ElementAutoNumComponent;

export interface TextComponent {
  readonly kind: "text";
  readonly text: string;
  readonly justify: string;
}

export interface EntryComponent {
  readonly kind: "entry";
  readonly label: string;
  readonly justify: string;
  readonly variable: string;
  readonly width: number;
}

export interface CheckComponent {
  readonly kind: "check";
  readonly label: string;
  readonly justify: string;
  readonly variable: string;
  readonly on_value: string;
  readonly off_value: string;
}

export interface BasradComponent {
  readonly kind: "basrad";
  readonly label: string;
  readonly justify: string;
  readonly count: number;
  readonly orientation: string;
  readonly variable: string;
  readonly options: readonly (readonly [string, string])[];
}

export interface GapComponent {
  readonly kind: "gap";
}

export interface BlockComponent {
  readonly kind: "block";
  readonly indent: number;
  readonly children: readonly PanComponent[];
}

export interface CaseComponent {
  readonly kind: "case";
  readonly expression: string;
  readonly active?: boolean;
  readonly children: readonly PanComponent[];
}

export interface InvisibleComponent {
  readonly kind: "invisible";
  readonly expression: string;
  readonly active?: boolean;
  readonly children: readonly PanComponent[];
}

export interface PushNextComponent {
  readonly kind: "pushnext";
  readonly label: string;
  readonly target_window: string;
}

export interface TableComponent {
  readonly kind: "table";
  readonly name: string;
  readonly header: string;
  readonly orientation: string;
  readonly justify: string;
  readonly rows: string;
  readonly width: number;
  readonly validation: string;
  readonly children: readonly PanComponent[];
}

export interface ElementComponent {
  readonly kind: "element";
  readonly label: string;
  readonly variable: string;
  readonly rows: string;
  readonly width: number;
  readonly mode: string;
}

export interface ElementAutoNumComponent {
  readonly kind: "elementautonum";
  readonly label: string;
  readonly start: string;
  readonly end: string;
  readonly width: number;
}

// ---------------------------------------------------------------------------
// Variable register
// ---------------------------------------------------------------------------

export interface VariableRegistrationResponse {
  readonly name: string;
  readonly default: string;
  readonly dim1_start: string;
  readonly dim1_end: string;
  readonly dim2_start: string;
  readonly var_type: string;
  readonly width: number;
  readonly format_spec: string;
  readonly window: string;
  readonly partition: string;
  readonly condition: string;
  readonly validation_type: string;
  readonly validation_args: readonly string[];
}

// ---------------------------------------------------------------------------
// Partition
// ---------------------------------------------------------------------------

export interface PartitionResponse {
  readonly key: string;
  readonly identifier: string;
  readonly conditions: readonly string[];
}

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

export type VariableValues = Record<string, string | string[]>;

export interface VariablesResponse {
  readonly variables: VariableValues;
}

// ---------------------------------------------------------------------------
// Help
// ---------------------------------------------------------------------------

export interface HelpResponse {
  readonly win_id: string;
  readonly text: string;
}
