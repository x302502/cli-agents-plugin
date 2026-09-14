<task>
Refactor {{TARGET_LABEL}}. Goal: {{USER_FOCUS}}
</task>

<completeness_contract>
Preserve behavior unless explicitly told otherwise. Do not touch unrelated files. Run the
project's tests after changes.
</completeness_contract>

<verification_loop>
After edits, run the project's test/lint command and iterate until it passes, or report a
concrete blocker.
</verification_loop>

<action_safety>
Keep the change narrow. No opportunistic rewrites, no unrelated reformatting.
</action_safety>

<output_contract>
Report the files changed, the verification command you ran, and its pass/fail result.
</output_contract>