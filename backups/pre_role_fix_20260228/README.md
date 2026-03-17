# Code Status: Feb 28, 2026
## Portal (3001) Integration Level: Loose Wrapper
- Doorkeeper (OAuth Provider) is installed and migrations are run.
- Handshake IDs (UID/SECRET) are verified in the database.
- CURRENT LIMITATION: The Portal UI does not yet differentiate between Producer, Talent, and Client during hand-off to 3003.

## App Capabilities (Verified via Audit)
1. PRODUCER: Central Admin. Owns Events, Forms, Announcements. 
   - CRITICAL: Owns curated talent pools and preparation of Client-specific slide decks.
2. TALENT: External users. Owns individual Slides (portfolios) and TalentData.
3. CLIENT: Brand reviewers. Linked to specific Events; receives decks from Producer for feedback/negotiation.

## Connection Logic
- All roles are linked via 'email' across SQL (Portal) and MongoDB (CastNXT).
