# Identity Verification - BayanTrack Mobile

The mobile identity-verification feature uses the existing KYC implementation
and records as its first provider. Internal `kyc_*` names remain for stored-data
and code compatibility; user-facing text and preferred network routes use
"identity verification" or "verification".

## Preferred API routes

- `GET /api/auth/verification/id-types/`
- `POST /api/auth/verification/submit/`
- `GET /api/auth/verification/status/`
- `POST /api/auth/verification/withdraw/` (currently policy-blocked while pending)
- `POST /api/auth/verification/resubmit/`
- `GET /api/auth/verification/form-options/`

The equivalent `/api/auth/kyc/*` routes remain supported by the Backend for
backward compatibility. New mobile requests use the preferred routes.

## Status values

The provider currently returns these stable values:

- `unverified`
- `pending`
- `verified`
- `rejected`
- `resubmit_requested`
- `suspended`

The response may contain canonical `verification_status` and legacy
`kyc_status`; the repository maps either value into the existing DTOs and
domain entities.

Rejected and resubmission-requested submissions prefill the correction form.
The form shows the rejection reason, uses a **Correct & Resubmit** action, and
asks for confirmation before sending. Pending and verified states remain
read-only; pending withdrawal is blocked by Backend policy until a safe review
lock exists.

## Permissions

- Authenticated, non-suspended users may submit reports and perform currently
  allowed report actions regardless of verification status.
- Suspended verification blocks report submission and protected report writes.
- Comments and other explicitly protected actions keep their existing
  verified-only gates.
- Profile access is not verification-gated.

## Architecture

- `data/` contains the existing KYC-named DTOs, repository, and mappers.
- `domain/` contains the existing entities, repository contract, and use cases.
- `presentation/` contains submission, resubmission, and status UI.

Do not duplicate validation or migrate stored KYC fields merely to change the
public terminology. Generalization happens at the API, UI, and contract edges.
