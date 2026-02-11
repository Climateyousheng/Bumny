import type { NavNodeResponse, WindowResponse, PanComponent, HelpResponse, VariableRegistrationResponse, PartitionResponse, VariablesResponse } from "@/types/bridge";
import type { ExperimentResponse } from "@/types/experiment";
import type { JobResponse } from "@/types/job";
import type { LockStatusResponse, LockResultResponse } from "@/types/lock";

export function buildExperiment(overrides: Partial<ExperimentResponse> = {}): ExperimentResponse {
  return {
    id: "xqgt",
    owner: "nd20983",
    description: "Test experiment",
    version: "8.6",
    access_list: "",
    privacy: "N",
    atmosphere: "",
    ocean: "",
    slab: "",
    mesoscale: "",
    ...overrides,
  };
}

export function buildJob(overrides: Partial<JobResponse> = {}): JobResponse {
  return {
    job_id: "a",
    exp_id: "xqgt",
    version: "8.6",
    description: "Test job",
    opened: "",
    atmosphere: "",
    ocean: "",
    slab: "",
    mesoscale: "",
    ...overrides,
  };
}

export function buildLockStatus(overrides: Partial<LockStatusResponse> = {}): LockStatusResponse {
  return {
    locked: false,
    owner: null,
    ...overrides,
  };
}

export function buildLockResult(overrides: Partial<LockResultResponse> = {}): LockResultResponse {
  return {
    success: true,
    owner: "nd20983",
    message: "Lock acquired",
    forced: false,
    ...overrides,
  };
}

// --- Bridge fixtures ---

export function buildNavNode(overrides: Partial<NavNodeResponse> = {}): NavNodeResponse {
  return {
    name: "modsel",
    label: "Model Selection",
    node_type: "node",
    children: [],
    ...overrides,
  };
}

export function buildWindow(overrides: Partial<WindowResponse> = {}): WindowResponse {
  return {
    win_id: "atmos_Domain_Horiz",
    title: "Horizontal",
    win_type: "entry",
    components: [],
    ...overrides,
  };
}

export function buildTextComponent(overrides: Partial<PanComponent> = {}): PanComponent {
  return {
    kind: "text",
    text: "Select area option",
    justify: "L",
    ...overrides,
  } as PanComponent;
}

export function buildEntryComponent(overrides: Partial<PanComponent> = {}): PanComponent {
  return {
    kind: "entry",
    label: "Number of columns",
    justify: "L",
    variable: "NCOLSAG",
    width: 10,
    ...overrides,
  } as PanComponent;
}

export function buildCheckComponent(overrides: Partial<PanComponent> = {}): PanComponent {
  return {
    kind: "check",
    label: "Enable feature",
    justify: "L",
    variable: "FEAT_ON",
    on_value: "Y",
    off_value: "N",
    ...overrides,
  } as PanComponent;
}

export function buildBasradComponent(overrides: Partial<PanComponent> = {}): PanComponent {
  return {
    kind: "basrad",
    label: "Select Area Option",
    justify: "L",
    count: 2,
    orientation: "v",
    variable: "OCAAA",
    options: [["Global Model", "1"], ["Limited Area Model", "2"]],
    ...overrides,
  } as PanComponent;
}

export function buildTableComponent(overrides: Partial<PanComponent> = {}): PanComponent {
  return {
    kind: "table",
    name: "test_table",
    header: "Test Table",
    orientation: "v",
    justify: "L",
    rows: "3",
    width: 10,
    validation: "",
    children: [
      {
        kind: "element",
        label: "Column 1",
        variable: "COL1",
        rows: "3",
        width: 10,
        mode: "entry",
      },
    ],
    ...overrides,
  } as PanComponent;
}

export function buildPushNextComponent(overrides: Partial<PanComponent> = {}): PanComponent {
  return {
    kind: "pushnext",
    label: "Next Window",
    target_window: "atmos_Domain_Vert",
    ...overrides,
  } as PanComponent;
}

export function buildHelpResponse(overrides: Partial<HelpResponse> = {}): HelpResponse {
  return {
    win_id: "atmos_Domain_Horiz",
    text: "This window configures the horizontal domain.",
    ...overrides,
  };
}

export function buildVariableRegistration(
  overrides: Partial<VariableRegistrationResponse> = {},
): VariableRegistrationResponse {
  return {
    name: "NCOLSAG",
    default: "96",
    dim1_start: "1",
    dim1_end: "0",
    dim2_start: "0",
    var_type: "INT",
    width: 10,
    format_spec: "0",
    window: "atmos_Domain_Horiz",
    partition: "a2312",
    condition: "",
    validation_type: "RANGE",
    validation_args: ["1", "1000"],
    ...overrides,
  };
}

export function buildPartition(overrides: Partial<PartitionResponse> = {}): PartitionResponse {
  return {
    key: "a",
    identifier: "atmos",
    conditions: ['ATMOS_SR(01)=="0A"'],
    ...overrides,
  };
}

export function buildVariablesResponse(
  overrides: Partial<VariablesResponse> = {},
): VariablesResponse {
  return {
    variables: {
      OCAAA: "1",
      NCOLSAG: "96",
    },
    ...overrides,
  };
}
