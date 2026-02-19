---
description: Implement a task from Backlog.md end-to-end
agent: build
model: openai/gpt-5.3-codex
---

If there is a backlog folder and/or `Backlog.md` is set up in the repository
then do the following:

Use the provided task number or context for a task, read the full contents of
the task from the `Backlog.md` board using the MCP server if available. If the
backlog has not been initialized then initialize the backlog in a
non-interactive way.

Once you have the necessary context, use the writing-plans skill to write a plan
to execute the task end-to-end (minus the commit) and then use the executing-plans skill to execute the plan.
Use parallel subagents where possible.
