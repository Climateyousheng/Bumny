import { describe, it, expect, beforeEach } from "vitest";
import { http, HttpResponse } from "msw";
import { server } from "../mocks/server";
import { setUsername, clearUsername } from "@/lib/user-store";
import {
  listExperiments,
  getExperiment,
  createExperiment,
  updateExperiment,
  deleteExperiment,
  copyExperiment,
  listJobs,
  getJob,
  createJob,
  updateJob,
  deleteJob,
  copyJob,
  checkLock,
  acquireLock,
  releaseLock,
} from "@/lib/api-client";

describe("api-client", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  // --- Experiments ---
  describe("listExperiments", () => {
    it("returns experiment list", async () => {
      const result = await listExperiments();
      expect(result.experiments).toHaveLength(3);
      expect(result.experiments[0]?.id).toBe("aaaa");
    });
  });

  describe("getExperiment", () => {
    it("returns a single experiment", async () => {
      const result = await getExperiment("xqgt");
      expect(result.id).toBe("xqgt");
      expect(result.owner).toBe("nd20983");
    });

    it("throws ApiError on 404", async () => {
      await expect(getExperiment("zzzz")).rejects.toThrow("Not found");
    });
  });

  describe("createExperiment", () => {
    it("creates an experiment and returns it", async () => {
      const result = await createExperiment({
        initial: "test",
        description: "New experiment",
      });
      expect(result.id).toBe("newx");
      expect(result.description).toBe("New experiment");
    });

    it("sends X-UMUI-User header", async () => {
      let capturedHeader: string | null = null;
      server.use(
        http.post("/experiments", ({ request }) => {
          capturedHeader = request.headers.get("X-UMUI-User");
          return HttpResponse.json(
            { id: "test", owner: "testuser", description: "", version: "", access_list: "", privacy: "N", atmosphere: "", ocean: "", slab: "", mesoscale: "" },
            { status: 201 },
          );
        }),
      );
      await createExperiment({ initial: "t", description: "test" });
      expect(capturedHeader).toBe("testuser");
    });
  });

  describe("updateExperiment", () => {
    it("updates and returns the experiment", async () => {
      const result = await updateExperiment("xqgt", { description: "Updated" });
      expect(result.description).toBe("Updated");
    });
  });

  describe("deleteExperiment", () => {
    it("completes without error", async () => {
      await expect(deleteExperiment("xqgt")).resolves.toBeUndefined();
    });
  });

  describe("copyExperiment", () => {
    it("copies and returns new experiment", async () => {
      const result = await copyExperiment("xqgt", {
        initial: "copy",
        description: "Copied",
      });
      expect(result.id).toBe("cpyx");
    });
  });

  // --- Jobs ---
  describe("listJobs", () => {
    it("returns job list", async () => {
      const result = await listJobs("xqgt");
      expect(result.jobs).toHaveLength(2);
    });
  });

  describe("getJob", () => {
    it("returns a single job", async () => {
      const result = await getJob("xqgt", "a");
      expect(result.job_id).toBe("a");
    });

    it("throws ApiError on 404", async () => {
      await expect(getJob("xqgt", "z")).rejects.toThrow("Not found");
    });
  });

  describe("createJob", () => {
    it("creates and returns a job", async () => {
      const result = await createJob("xqgt", { job_id: "c", description: "New" });
      expect(result.job_id).toBe("c");
    });
  });

  describe("updateJob", () => {
    it("updates and returns the job", async () => {
      const result = await updateJob("xqgt", "a", { description: "Updated" });
      expect(result.description).toBe("Updated");
    });
  });

  describe("deleteJob", () => {
    it("completes without error", async () => {
      await expect(deleteJob("xqgt", "a")).resolves.toBeUndefined();
    });
  });

  describe("copyJob", () => {
    it("copies and returns new job", async () => {
      const result = await copyJob("xqgt", "a", {
        dest_exp_id: "xqgt",
        dest_job_id: "d",
      });
      expect(result.job_id).toBe("d");
    });
  });

  // --- Locks ---
  describe("checkLock", () => {
    it("returns lock status", async () => {
      const result = await checkLock("xqgt", "a");
      expect(result.locked).toBe(false);
      expect(result.owner).toBeNull();
    });
  });

  describe("acquireLock", () => {
    it("acquires and returns lock result", async () => {
      const result = await acquireLock("xqgt", "a");
      expect(result.success).toBe(true);
      expect(result.owner).toBe("nd20983");
    });
  });

  describe("releaseLock", () => {
    it("releases and returns lock result", async () => {
      const result = await releaseLock("xqgt", "a");
      expect(result.success).toBe(true);
      expect(result.message).toBe("Lock released");
    });
  });

  // --- Error handling ---
  describe("error handling", () => {
    it("throws ApiError with status and detail for non-ok responses", async () => {
      server.use(
        http.get("/experiments", () => {
          return HttpResponse.json({ detail: "Server error" }, { status: 500 });
        }),
      );
      try {
        await listExperiments();
        expect.fail("Should have thrown");
      } catch (err) {
        expect(err).toHaveProperty("status", 500);
        expect(err).toHaveProperty("detail", "Server error");
      }
    });

    it("throws when no username is set for mutating requests", () => {
      clearUsername();
      expect(() =>
        createExperiment({ initial: "t", description: "test" }),
      ).toThrow("Username is required");
    });
  });
});
