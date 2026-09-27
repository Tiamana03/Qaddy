# Group Permissions

**Version:** 1.0  
**Status:** Architecture Approved

---

# Purpose

This document defines the permission system used throughout Qaddy.

Permissions determine what each member of a group is allowed to do.

The goal is to provide a simple permission model today while remaining scalable for future releases.

Permissions apply to:

- Golf Groups
- Trips
- Shared Rounds
- Future Clubhouses
- Future Leagues
- Future Competitions

---

# Permission Philosophy

Qaddy is designed around collaboration.

Every group should have an owner.

Owners may assign administrators.

Everyone else becomes a member.

This keeps permissions predictable and easy to understand.

---

# Permission Levels

## Owner

Highest permission level.

A group has exactly one Owner.

Owner permissions include:

- Edit group details
- Delete group
- Invite members
- Remove members
- Promote Admins
- Demote Admins
- Transfer ownership
- Create rounds
- Edit rounds
- Delete rounds
- Manage trips
- Manage expenses
- Manage side games
- Start rounds
- Finish rounds

---

## Admin

Admins assist the Owner.

Permissions include:

- Invite members
- Remove members
- Edit group details
- Create rounds
- Edit rounds
- Manage trips
- Manage expenses
- Configure side games
- Start rounds
- Finish rounds

Admins cannot:

- Delete group
- Transfer ownership
- Remove the Owner
- Promote another Owner

---

## Member

Default permission level.

Members can:

- Join rounds
- View group information
- Participate in scoring
- View leaderboards
- View statistics
- Join trips
- Upload photos
- Chat
- View expenses

Members cannot:

- Delete anything
- Manage permissions
- Edit group settings

---

# Permission Matrix

| Action | Owner | Admin | Member |
|----------|-------|-------|--------|
| View Group | ✅ | ✅ | ✅ |
| Edit Group | ✅ | ✅ | ❌ |
| Delete Group | ✅ | ❌ | ❌ |
| Invite Members | ✅ | ✅ | ❌ |
| Remove Members | ✅ | ✅ | ❌ |
| Transfer Ownership | ✅ | ❌ | ❌ |
| Create Round | ✅ | ✅ | ❌ |
| Edit Round | ✅ | ✅ | ❌ |
| Delete Round | ✅ | ✅ | ❌ |
| Start Round | ✅ | ✅ | ❌ |
| Finish Round | ✅ | ✅ | ❌ |
| Submit Scores | ✅ | ✅ | ✅ |
| View Leaderboard | ✅ | ✅ | ✅ |
| Create Trip | ✅ | ✅ | ❌ |
| Edit Trip | ✅ | ✅ | ❌ |
| View Trip | ✅ | ✅ | ✅ |
| Upload Photos | ✅ | ✅ | ✅ |
| Participate in Chat | ✅ | ✅ | ✅ |

---

# Group Ownership

Each group stores:

- Owner ID
- Admin IDs
- Member IDs

Ownership may be transferred.

Only one Owner exists at any time.

---

# Round Permissions

Only Owners and Admins may:

- Create rounds
- Edit round settings
- Configure side games
- Configure teams
- Cancel rounds

Members may:

- Join
- View
- Submit scores
- Track progress

---

# Trip Permissions

Owners and Admins may:

- Create trips
- Edit itineraries
- Book golf courses
- Manage accommodation
- Manage expenses
- Invite travellers

Members may:

- Accept invitations
- View itinerary
- Upload photos
- Participate in chat
- Record expenses where allowed

---

# Expense Permissions

Owners/Admins may:

- Add expenses
- Edit expenses
- Delete expenses
- Finalise balances

Members may:

- View balances
- Add personal expenses (future)
- Mark payments complete

---

# Future Permission Expansion

The permission system is intentionally scalable.

Future roles may include:

- Moderator
- Tournament Director
- Club Captain
- League Manager
- Event Organiser
- Statistician

These roles should extend the existing permission model rather than replacing it.

---

# Security Principles

Permissions should always be validated by the backend.

The UI should never be trusted as the source of truth.

If a user lacks permission:

- Actions should be hidden where appropriate.
- Backend validation must still reject unauthorised requests.

---

# Related Documents

- app-architecture.md
- friend-data-model.md
- friend-relationship-model.md
- group-data-model.md
- trip-data-model.md
- round-data-model.md

---

**End of Document**