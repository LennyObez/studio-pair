# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 0.x.x   | Yes (development)  |

## Reporting a Vulnerability

We take the security of Studio Pair seriously. If you discover a security
vulnerability, please report it responsibly.

**DO NOT** create a public GitHub issue for security vulnerabilities.

### How to Report

1. Email **security@studiopair.app** with a description of the vulnerability
2. Include steps to reproduce the issue
3. Include the potential impact
4. If possible, suggest a fix

### What to Expect

- **Acknowledgment**: We will acknowledge receipt within 48 hours
- **Assessment**: We will assess the vulnerability within 5 business days
- **Resolution**: Critical vulnerabilities will be patched within 7 days; others within 30 days
- **Disclosure**: We will coordinate disclosure timing with you

### Security Measures

Studio Pair implements the following security measures:

- **Two-tier encryption**: Standard encryption (TLS + at-rest) for most data; client-side encryption for sensitive modules (Vault, Health, Private Capsule)
- **Authentication**: Argon2id/bcrypt password hashing, TOTP-based 2FA, short-lived access tokens
- **Authorization**: Multi-layer authorization model (auth, space membership, role, ownership, share permissions, privacy mode, entitlement)
- **Data protection**: GDPR-compliant data handling, right to deletion, data export
- **Input validation**: Server-side validation on all endpoints, parameterized queries
- **Rate limiting**: Configurable per-endpoint rate limiting with exponential backoff

### Scope

The following are in scope for security reports:

- Authentication and authorization bypasses
- Data exposure or leakage
- Encryption weaknesses
- Injection vulnerabilities (SQL, XSS, etc.)
- Privilege escalation
- CSRF/SSRF vulnerabilities

### Out of Scope

- Denial of service attacks
- Social engineering
- Physical security
- Third-party service vulnerabilities
