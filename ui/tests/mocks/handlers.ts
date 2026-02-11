import { http, HttpResponse } from "msw";
import { buildExperiment, buildJob, buildLockStatus, buildLockResult } from "./fixtures";

const experiments = [
  buildExperiment({ id: "aaaa", owner: "hadsm", description: "Standard atmosphere" }),
  buildExperiment({ id: "xqgt", owner: "nd20983", description: "Control run" }),
  buildExperiment({ id: "xqjc", owner: "nd20983", description: "Sensitivity test" }),
];

const jobs = [
  buildJob({ job_id: "a", exp_id: "xqgt", description: "Job A" }),
  buildJob({ job_id: "b", exp_id: "xqgt", description: "Job B" }),
];

export const handlers = [
  // Experiments
  http.get("/experiments", () => {
    return HttpResponse.json({ experiments });
  }),

  http.get("/experiments/:expId", ({ params }) => {
    const exp = experiments.find((e) => e.id === params["expId"]);
    if (!exp) return HttpResponse.json({ detail: "Not found" }, { status: 404 });
    return HttpResponse.json(exp);
  }),

  http.post("/experiments", async ({ request }) => {
    const body = (await request.json()) as Record<string, string>;
    const exp = buildExperiment({
      id: "newx",
      owner: "testuser",
      description: body["description"] ?? "",
      privacy: body["privacy"] ?? "N",
    });
    return HttpResponse.json(exp, { status: 201 });
  }),

  http.patch("/experiments/:expId", async ({ params, request }) => {
    const body = (await request.json()) as Record<string, string>;
    const exp = experiments.find((e) => e.id === params["expId"]);
    if (!exp) return HttpResponse.json({ detail: "Not found" }, { status: 404 });
    return HttpResponse.json({ ...exp, ...body });
  }),

  http.delete("/experiments/:expId", () => {
    return new HttpResponse(null, { status: 204 });
  }),

  http.post("/experiments/:expId/copy", async ({ request }) => {
    const body = (await request.json()) as Record<string, string>;
    const exp = buildExperiment({
      id: "cpyx",
      owner: "testuser",
      description: body["description"] ?? "",
    });
    return HttpResponse.json(exp, { status: 201 });
  }),

  // Jobs
  http.get("/experiments/:expId/jobs", () => {
    return HttpResponse.json({ jobs });
  }),

  http.get("/experiments/:expId/jobs/:jobId", ({ params }) => {
    const job = jobs.find((j) => j.job_id === params["jobId"]);
    if (!job) return HttpResponse.json({ detail: "Not found" }, { status: 404 });
    return HttpResponse.json(job);
  }),

  http.post("/experiments/:expId/jobs", async ({ params, request }) => {
    const body = (await request.json()) as Record<string, string>;
    const job = buildJob({
      job_id: body["job_id"] ?? "c",
      exp_id: params["expId"] as string,
      description: body["description"] ?? "",
    });
    return HttpResponse.json(job, { status: 201 });
  }),

  http.patch("/experiments/:expId/jobs/:jobId", async ({ params, request }) => {
    const body = (await request.json()) as Record<string, string>;
    const job = jobs.find((j) => j.job_id === params["jobId"]);
    if (!job) return HttpResponse.json({ detail: "Not found" }, { status: 404 });
    return HttpResponse.json({ ...job, ...body });
  }),

  http.delete("/experiments/:expId/jobs/:jobId", () => {
    return new HttpResponse(null, { status: 204 });
  }),

  http.post("/experiments/:expId/jobs/:jobId/copy", async ({ request }) => {
    const body = (await request.json()) as Record<string, string>;
    const job = buildJob({
      job_id: body["dest_job_id"] ?? "d",
      exp_id: body["dest_exp_id"] ?? "xqgt",
      description: body["description"] ?? "",
    });
    return HttpResponse.json(job, { status: 201 });
  }),

  // Locks
  http.get("/experiments/:expId/jobs/:jobId/lock", () => {
    return HttpResponse.json(buildLockStatus());
  }),

  http.post("/experiments/:expId/jobs/:jobId/lock", () => {
    return HttpResponse.json(buildLockResult());
  }),

  http.delete("/experiments/:expId/jobs/:jobId/lock", () => {
    return HttpResponse.json(buildLockResult({ message: "Lock released" }));
  }),
];
