# Verify Deployment

Verify that deployment was successful and the site is working.

## Steps

1. Check deploy feedback:
   ```bash
   cat .deploy-feedback.json
   ```

2. Get the site URL from feedback or config:
   ```bash
   cat .deploy.config
   ```

3. Check the URLs mentioned in `urls_to_check`

4. Verify:
   - Site is accessible
   - New changes are visible
   - No errors in browser console

5. If issues found:
   - Analyze the error
   - Suggest code fixes
   - Offer to create fix commit

6. Report to user:
   - Deployment status
   - Site accessibility
   - Any issues found
   - Screenshots or descriptions of changes
