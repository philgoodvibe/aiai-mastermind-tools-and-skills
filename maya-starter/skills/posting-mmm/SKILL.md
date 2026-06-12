---
name: posting-mmm
description: Stage a compliance-passed post in Mai Marketing Machine (GoHighLevel social planner API) as a DRAFT for owner review, and schedule it after approval. Use when a draft has passed compliance-check, or when the owner says "stage this", "send to Mai Marketing Machine", "schedule the post", or asks what is waiting for review. Reads credentials from the system keychain, never from files.
---

# Posting via Mai Marketing Machine

Mai Marketing Machine runs on the GoHighLevel platform, so this skill talks to the GoHighLevel social planner API. Two iron rules: every post is created as a DRAFT until the owner approves, and credentials are read from the system keychain at runtime, never stored in files, never printed, never committed.

## Credentials

Two secrets, stored by the owner during course Module 5:

| Keychain item name | What it is |
|---|---|
| `ghl-location-id` | The Mai Marketing Machine location ID |
| `ghl-pit-token` | The private integration key |

Read them on a Mac:

```bash
LOCATION_ID=$(security find-generic-password -s ghl-location-id -w)
PIT=$(security find-generic-password -s ghl-pit-token -w)
```

On Windows, they live in Credential Manager under the same names; read them in PowerShell with the CredentialManager module:

```powershell
$pit = (Get-StoredCredential -Target "ghl-pit-token").GetNetworkCredential().Password
```

Handling rules:

- Never echo, log, or display these values. Use the variables directly in the API call and nothing else.
- Never write them to any file, including temp files, .env files, or this repo.
- If a keychain item is missing, do not improvise. Ask the owner to add it (on a Mac: `security add-generic-password -a "$USER" -s ghl-location-id -w`, which prompts for the value so it never touches shell history; then the same for `ghl-pit-token`; then in Keychain Access set Access Control to allow). Course Module 5.2 walks them through it.

## API basics

Base URL `https://services.leadconnectorhq.com`. Every request carries:

```
Authorization: Bearer $PIT
Version: 2021-07-28
Accept: application/json
```

If a call fails with an unexpected shape, check the current GoHighLevel API docs for the social-media-posting endpoints before retrying; fields occasionally change.

## Step 1: Confirm the draft is eligible

Only stage posts whose post.md shows `Compliance: PASS`. No pass, no post, no exceptions. The post folder must contain the final caption and the image file(s).

## Step 2: Find the connected account

```bash
curl -s "https://services.leadconnectorhq.com/social-media-posting/$LOCATION_ID/accounts" \
  -H "Authorization: Bearer $PIT" -H "Version: 2021-07-28" -H "Accept: application/json"
```

Pull the account ID for the target platform (Instagram, unless the owner says otherwise). Cache the ID in this file under a "Known accounts" note so you do not re-fetch daily, but re-fetch if a post call rejects it.

## Step 3: Upload the image

Upload each image to the media library and capture the returned URL:

```bash
curl -s "https://services.leadconnectorhq.com/medias/upload-file" \
  -H "Authorization: Bearer $PIT" -H "Version: 2021-07-28" \
  -F "file=@output/drafts/<post-folder>/image-1.png" \
  -F "hosted=true" -F "locationId=$LOCATION_ID"
```

## Step 4: Create the post as DRAFT

```bash
curl -s -X POST "https://services.leadconnectorhq.com/social-media-posting/$LOCATION_ID/posts" \
  -H "Authorization: Bearer $PIT" -H "Version: 2021-07-28" -H "Content-Type: application/json" \
  -d '{
    "accountIds": ["<account-id>"],
    "summary": "<the caption, exactly as compliance passed it>",
    "media": [{"url": "<uploaded-image-url>", "type": "image/png"}],
    "type": "post",
    "status": "draft"
  }'
```

For a carousel, include each image in `media` in slide order. Do not edit the caption between the compliance pass and this call.

## Step 5: Tell the owner

Report: which post is staged, one line on the concept, and where to review it (Mai Marketing Machine, Marketing tab, Social Planner, Drafts). The post folder stays in `output/drafts/` with Status: draft.

## Step 6: After approval, schedule

When the owner approves and gives a time (or says to use the standing best-time preference), update the post to scheduled, for example with `"status": "scheduled"` and `"scheduleDate": "<ISO 8601 datetime with timezone>"` via the post update endpoint. Then move the post folder to `output/approved/` and update Status. Once the post is confirmed live, move the folder to `output/posted/`.

## Troubleshooting

- **401:** the private integration key is wrong, rotated, or lacks Social Planner scopes. Ask the owner to check the key in Mai Marketing Machine settings and re-save the keychain item.
- **404 on accounts or posts:** the location ID is wrong. Ask the owner to re-check it in settings.
- **Post created but no image:** the media URL was not accepted; re-upload and confirm the URL returns the image in a browser.

Never paste the raw API response containing tokens or account emails into chat. Summarize.
