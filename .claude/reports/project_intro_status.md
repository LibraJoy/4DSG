# 4DSG / DovSG Project Intro & Status

## 1. Executive Summary
4DSG packages the DovSG (Dense Open-Vocabulary 3D Scene Graphs) research stack inside a reproducible Docker workspace. The current push is to harden the 3DSG preprocessing→visualization pipeline and keep GPU/OpenGL tooling reliable inside containers. End-to-end preprocessing plus the interactive viewer now runs with CUDA acceleration, and a 3DSG-only fast path supports quicker iteration once artifacts exist. Overall health is “functional but hands-on”: core pipeline runs, while GUI transport, CLIP query ergonomics, and stdin handling still need polish. Documentation has been consolidated so Docker setup/testing live only in the two canonical guides.

## 2. Current Progress Snapshot
- **Working:** Full preprocess + 3DSG demo via `demo.py --preprocess`; semantic memory/device bug fixed; 3DSG-only script enables 5–10 min reruns; interactive viewer hotkeys (B/C/R/Q/G/I/O/V) operate after stdin guard.
- **Flaky / Blocked:** Native OpenGL works on X11 hosts but VNC/Xpra fallback not yet validated; Open3D windows still depend on host DISPLAY and GPU drivers; CLIP (“Q” key) prompts fall back to canned text when stdin closes; Docker stdin/EOF workaround is defensive but not permanent; task-planning branch disabled pending API-key gating.

## 3. Decision Log
- Skip automated task planning for now; require explicit opt-in and API key validation.
- Default to native OpenGL/X11; add VNC/Xpra only if headless usage demands it.
- Keep user-facing helper scripts ≤4 (build, run, clean, downloads); any extras need justification or consolidation.
- Maintain exactly two authoritative Docker docs: `docker/README.md` (setup) and `docker/MANUAL_VERIFICATION.md` (verification/demos).

## 4. Canonical Entry Points
- `docker/README.md` – Environment prerequisites, installation, container lifecycle.
- `docker/MANUAL_VERIFICATION.md` – Manual smoke tests, demo walkthroughs, troubleshooting.

## 5. File Map (Terse)
- `DovSG/demo.py` – Pipeline entrypoint (preprocess + interactive run).
- `DovSG/dovsg/controller.py` – Orchestrates pose, memory, instances, 3DSG build, viewer.
- `DovSG/dovsg/memory/` – View dataset, semantic memory, instances, scene graph modules.
- `DovSG/dovsg/scripts/` – Utility CLI (pose estimation, point cloud, tooling).
- `docker/dockerfiles/` – Container definitions for `dovsg` and `droid-slam`.
- `docker/scripts/` – Host helpers (`docker_build.sh`, `docker_run.sh`, `docker_clean.sh`, downloads, 3DSG-only fast path).

## 6. Open Issues & Next Work Items
- Open3D GUI on headless hosts → validate/document VNC or Xpra fallback without duplicating setup steps.
- CLIP “Q” key prompt robustness → add explicit flag/config to bypass stdin and document default prompt behavior.
- Docker stdin handling → replace try/except guard with a deterministic `--no-input` CLI option downstream.
- Script count pressure (≤4 rule) → review `run_3dsg_only.sh` vs documenting equivalent command path.
- Task-planning/API integration → design gated path that checks keys before enabling LLM calls.
- GPU capability checks → automate GLX/Open3D sanity test inside verification script instead of manual commands.
- Artifact reuse expectations → surface cached-directory requirements in viewer UI/logs to cut rerun confusion.
- Permission drift inside bind mounts → document/playbook for `chown` fix before editing source.

## 7. Guardrails (.CLAUDE)
- No new features without explicit approval; focus on stabilization and documentation.
- Keep diffs minimal, reversible, and logged in `.claude/worklog.md`.
- Prefer wrappers or scripts over intrusive code edits; share commands in docs rather than new wizards.
- Respect consolidated docs: top-level README stays high-level, Docker details live only in the two canonical files.
