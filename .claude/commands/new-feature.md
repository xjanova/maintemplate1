# Start New Feature

Start developing a new feature with proper workflow.

## Arguments
- $ARGUMENTS: Feature description

## Steps

1. Understand the feature from $ARGUMENTS

2. Create a feature branch:
   ```bash
   git checkout -b feature/feature-name
   ```

3. Update docs/TASKS.md with the new task:
   - Add to "In Progress" section
   - Include description and branch name

4. Implement the feature

5. Commit with conventional commit message:
   ```bash
   git add .
   git commit -m "feat: description of feature"
   ```

6. Push and create PR:
   ```bash
   git push -u origin feature/feature-name
   gh pr create --title "feat: Feature Name" --body "Description"
   ```

7. Update docs/TASKS.md with PR link

8. Report back to user with:
   - What was implemented
   - PR link
   - Next steps
