<task>
Diagnose {{TARGET_LABEL}}. Symptom / context: {{USER_FOCUS}}
</task>

<research_mode>
Read logs and code to find the root cause. Do not change any files.
</research_mode>

<grounding_rules>
Base conclusions on observed evidence. Separate facts from hypotheses and state confidence.
</grounding_rules>

<output_contract>
Return: root cause (or top hypotheses with confidence), the supporting evidence, and the
recommended next step.
</output_contract>