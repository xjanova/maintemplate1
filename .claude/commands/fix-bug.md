# Fix Bug

Start fixing a bug with proper workflow.

## Arguments
- $ARGUMENTS: Bug description

## Steps

1. Understand the bug from $ARGUMENTS

2. Create a fix branch:
   ```bash
   git checkout -b fix/bug-description
   ```

3. Update docs/TASKS.md:
   - Add bug to "In Progress"
   - Include description

4. Investigate and fix the bug

5. Test the fix

6. Commit with conventional commit message:
   ```bash
   git add .
   git commit -m "fix: description of fix"
   ```

7. Push and create PR:
   ```bash
   git push -u origin fix/bug-description
   gh pr create --title "fix: Bug Fix" --body "Description"
   ```

8. Update docs/TASKS.md with PR link

9. Report back to user with:
   - What was fixed
   - Root cause
   - PR link
