# EmailJS Template Configuration Fix

## Problem
Emails show "OK" status in EmailJS dashboard but are not arriving in inbox/spam.

## Solution: Configure Template "To Email" Field

The issue is that your EmailJS template is not configured to use the `{{to_email}}` variable in the "To Email" field.

### Step-by-Step Fix:

1. **Go to EmailJS Dashboard**
   - Visit [https://dashboard.emailjs.com/](https://dashboard.emailjs.com/)
   - Log in to your account

2. **Open Your Template**
   - Click **"Email Templates"** in the left sidebar
   - Find your template with ID: `template_bge8q1g`
   - Click on it to edit

3. **Configure "To Email" Field**
   - Look for the **"To Email"** field (usually at the top of the template editor)
   - **IMPORTANT:** In the "To Email" field, enter: `{{to_email}}`
   - This tells EmailJS to use the recipient email from your code

4. **Verify Template Variables**
   Make sure your template has these variables:
   - **To Email:** `{{to_email}}` ✅ (This is the most important!)
   - **Subject:** `{{subject}}`
   - **Body/Content:** `{{message}}`
   - **Name:** `{{name}}` (if you want to use it)
   - **Time:** `{{time}}` (if you want to use it)

5. **Save the Template**
   - Click **"Save"** or **"Update Template"**

6. **Test Again**
   - Go back to your app
   - Issue teacher credentials again
   - Check the email inbox

## Template Configuration Example

Your template should look like this:

**To Email:** `{{to_email}}` ← **This is critical!**

**Subject:** `{{subject}}`

**Content/Body:**
```
Hello {{name}},

{{message}}
```

## Common Issues

### Issue 1: "To Email" field is empty or has a fixed email
- **Fix:** Change it to `{{to_email}}`

### Issue 2: "To Email" field has wrong variable name
- **Fix:** Make sure it's exactly `{{to_email}}` (not `{{to_email}}`, `{{email}}`, etc.)

### Issue 3: Template variables don't match
- **Fix:** Ensure your template has all these variables:
  - `{{to_email}}`
  - `{{subject}}`
  - `{{message}}`
  - `{{name}}` (optional)
  - `{{time}}` (optional)

## Verification

After fixing the template:
1. Issue teacher credentials in your app
2. Check EmailJS dashboard → Email History
3. Click on the email entry to see details
4. Verify the "To Email" shows the correct recipient
5. Check the recipient's inbox (and spam folder)

## Still Not Working?

If emails still don't arrive after fixing the template:
1. Check EmailJS dashboard → Email History → Click on the email entry
2. Look for any error messages or warnings
3. Verify the recipient email address is correct
4. Check if Gmail is blocking the emails (check Gmail security settings)
5. Try sending to a different email address to test

