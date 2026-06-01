# VS Pattern Application Examples

## Example 1: Marketing Hypothesis → Pattern E

**Input:**
> "I have a food delivery startup, want to launch social media ads. Budget is small, only $300 for testing. Not sure what will work best — funny reels, nutrition tips, or just discounts. Target audience: office workers 25–40."

**Classification:** MODERATE + STRATEGY + FEW + YES → Pattern E (External Collapse)

**VS Prompt:**
```
Generate 3 marketing hypotheses for a food delivery startup.
Target audience: office workers aged 25–40.
Budget: $300 for testing.

For each hypothesis:
- core message
- format (reel / post / story)
- expected CTR
- success probability (0–1)
- minimal test for validation
- main risk

Format — readable, with headers.
```

**Execution prompt (example, "discounts" variant selected):**
```
Develop a creative concept for a food delivery ad campaign.
Hypothesis: discount offers for office workers.
Budget: $300. Platform: Instagram/TikTok.

What to produce:
- 3 creative variants (reel / story)
- post copy
- call to action
- hashtags
```

---

## Example 2: Bug Diagnosis → Pattern C

**Input:**
> "CRM isn't syncing with the Telegram bot. Reinstalled webhook, checked API key — valid. Bot logs are empty, CRM logs are empty. Could be network, could be library, could be API version. Urgent."

**Classification:** UNCERTAIN + DIAGNOSTIC + FEW + YES → Pattern C (VS-CoT)

**VS Prompt:**
```
Think step by step about possible causes of the problem:
CRM not syncing with Telegram bot.
- webhook was reinstalled — didn't help
- API key is valid
- bot logs are empty
- CRM logs are empty
- urgent

Then generate 5 root cause hypotheses with probabilities.
For each:
- hypothesis
- how to verify (specific command)
- what to do if confirmed
```

**Execution prompt:**
```
Write a script to fix the sync issue.
Diagnosis: [selected hypothesis].
Fix plan:
- step 1
- step 2
Verification: [command from VS analysis]
```

---

## Example 3: Architecture Selection → Pattern A

**Input:**
> "Need CRM integration with Telegram bot. When a new lead appears in CRM, the bot should send a notification to chat. Data: name, phone, source. Not sure which approach — webhook, long polling, or message queue."

**Classification:** MODERATE + CODE + FEW + NO → Pattern A (VS-Standard)

**VS Prompt:**
```
Generate 3 architectural approaches for CRM–Telegram bot integration.
Task: new lead in CRM → notification in Telegram.

For each approach:
- name
- architecture description
- pros (2)
- cons (2)
- success probability (0–1)
- estimated implementation time
- maintenance complexity
```
