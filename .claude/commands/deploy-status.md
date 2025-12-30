# Check Deployment Status

Check the current deployment status and any errors.

## Steps

1. Read the deploy feedback file if it exists:
   ```bash
   cat .deploy-feedback.json
   ```

2. Check recent GitHub Actions runs for deploy status

3. If there are errors, analyze them and suggest fixes

4. Report the status to the user including:
   - Last deploy time
   - Success/failure status
   - Any errors or warnings
   - URLs to check
   - Suggested actions if failed
