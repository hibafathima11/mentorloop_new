# EmailJS Setup Guide - Free Email Notifications

This guide will help you set up **EmailJS** (free tier: 200 emails/month) to send email notifications when:
- Admin adds a teacher
- Admin approves a student
- Admin approves a parent

## Step 1: Create EmailJS Account (Free)

1. Go to [https://www.emailjs.com/](https://www.emailjs.com/)
2. Click **"Sign Up"** (top right)
3. Sign up with your email or Google account
4. Verify your email address

## Step 2: Add Email Service

1. After logging in, go to **"Email Services"** in the left sidebar
2. Click **"Add New Service"**
3. Choose an email provider:
   - **Gmail** (recommended for free tier)
   - **Outlook**
   - **Yahoo**
   - Or any other supported provider
4. Follow the instructions to connect your email account
5. Once connected, note your **Service ID** (e.g., `service_xxxxx`)

## Step 3: Create Email Template

1. Go to **"Email Templates"** in the left sidebar
2. Click **"Create New Template"**
3. Use this template structure:

**Template Name:** `mentorloop_notifications`

**Subject:** `{{subject}}`

**Content:**
```
{{message}}
```

4. Click **"Save"**
5. Note your **Template ID** (e.g., `template_xxxxx`)

## Step 4: Get Your Public Key

1. Go to **"Account"** → **"General"** in the left sidebar
2. Find your **Public Key** (also called User ID)
3. Copy it (e.g., `xxxxxxxxxxxxx`)

## Step 5: Update Your Flutter Code

1. Open `lib/utils/email_service.dart`
2. Replace the placeholder values with your actual EmailJS credentials:

```dart
static const String emailJsServiceId = 'YOUR_SERVICE_ID';  // From Step 2
static const String emailJsTemplateId = 'YOUR_TEMPLATE_ID'; // From Step 3
static const String emailJsPublicKey = 'YOUR_PUBLIC_KEY';   // From Step 4
```

**Example:**
```dart
static const String emailJsServiceId = 'service_abc123';
static const String emailJsTemplateId = 'template_xyz789';
static const String emailJsPublicKey = 'abcdefghijklmnop';
```

## Step 6: Test the Setup

1. Run your Flutter app
2. As an admin, try approving a student or adding a teacher
3. Check the recipient's email inbox for the notification
4. Check EmailJS dashboard → **"Logs"** to see if emails were sent successfully

## Troubleshooting

### Emails Not Sending?

1. **Check EmailJS Logs:**
   - Go to EmailJS dashboard → **"Logs"**
   - Look for error messages

2. **Verify Credentials:**
   - Double-check Service ID, Template ID, and Public Key
   - Make sure there are no extra spaces or quotes

3. **Check Email Service Connection:**
   - Go to **"Email Services"**
   - Make sure your email service is still connected
   - Reconnect if needed

4. **Free Tier Limits:**
   - Free tier allows 200 emails/month
   - Check your usage in the dashboard
   - Upgrade if you need more

### Common Errors

- **"Invalid service ID"**: Check your Service ID in `email_service.dart`
- **"Invalid template ID"**: Check your Template ID in `email_service.dart`
- **"Invalid public key"**: Check your Public Key in `email_service.dart`
- **"Email service not connected"**: Reconnect your email service in EmailJS dashboard

## EmailJS Free Tier Limits

- ✅ **200 emails per month** (resets monthly)
- ✅ **2 email services**
- ✅ **2 email templates**
- ✅ **No credit card required**
- ✅ **Perfect for small to medium applications**

## Upgrade Options (If Needed)

If you exceed 200 emails/month:
- **Paid plans** start at $15/month for 1,000 emails
- Visit EmailJS pricing page for details

## Security Notes

⚠️ **Important:** The Public Key is safe to use in client-side code, but:
- Never commit sensitive credentials to public repositories
- Consider using environment variables for production
- The Public Key is designed to be public, but keep your Service ID and Template ID private if possible

## Support

- EmailJS Documentation: [https://www.emailjs.com/docs/](https://www.emailjs.com/docs/)
- EmailJS Support: Available in dashboard
- Flutter HTTP Package: Already included in your `pubspec.yaml`

---

**That's it!** Your email notifications are now set up and ready to use. 🎉

