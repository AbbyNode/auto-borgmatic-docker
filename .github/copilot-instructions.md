# Copilot Instructions

## Style

### Commits
* When creating new commits in automatic agent mode, always prefix commit with `[COPILOT]`.

### Code Execution
* **Never** run bash scripts on the host machine.
    * All scripts must run inside containers.

### Cohesion with Existing Code
* New work should be cohesive with existing code.
* Refer to the same game files when possible.
* Use similar approaches to existing implementations.
