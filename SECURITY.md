# Security Policy

## Overview

PT KGiTON takes security seriously. This document outlines our security policies and procedures for the KGiTON SDK.

## Proprietary Software Notice

⚠️ **CONFIDENTIAL**: This software is the proprietary property of PT KGiTON and contains confidential trade secrets. All security-related information must be kept confidential.

---

## Reporting Security Vulnerabilities

### Eligibility

Only **authorized license holders** may report security vulnerabilities. If you are not a licensed user, you are not authorized to access or analyze this software.

### Reporting Process

If you discover a security vulnerability:

#### ❌ DO NOT:
- Open a public GitHub issue
- Discuss the vulnerability on social media or forums
- Share details with unauthorized third parties
- Attempt to exploit the vulnerability
- Access data that doesn't belong to you

#### ✅ DO:
1. Email security details to: **support@kgiton.com**
2. Use subject line: `[SECURITY] Your License ID - Brief Description`
3. Include:
   - Your license ID and organization name
   - SDK version affected
   - Detailed vulnerability description
   - Steps to reproduce
   - Potential impact assessment
   - Suggested fix (if available)
4. Wait for acknowledgment from PT KGiTON security team
5. Keep all communications confidential

### Example Report Format

```
Subject: [SECURITY] LIC-12345 - Authentication Bypass

License ID: LIC-12345
Organization: Acme Corporation
SDK Version: 1.0.0
Severity: High

Description:
[Detailed description of the vulnerability]

Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Impact:
[Description of potential impact]

Suggested Fix:
[Optional: Your suggested solution]
```

---

## Security Response

### Response Timeline

| Priority | Description | Response Time | Fix Timeline |
|----------|-------------|---------------|--------------|
| **Critical** | Remote code execution, data breach | 4 hours | 24-48 hours |
| **High** | Authentication bypass, privilege escalation | 24 hours | 3-7 days |
| **Medium** | Information disclosure, DoS | 48 hours | 7-14 days |
| **Low** | Minor security improvements | 7 days | Next release |

### Response Process

1. **Acknowledgment** - We acknowledge receipt within the response time
2. **Verification** - Our team verifies and assesses the vulnerability
3. **Development** - We develop and test a fix
4. **Notification** - Licensed users are notified of the security update
5. **Deployment** - Patch is distributed to all licensed users
6. **Disclosure** - Public disclosure (if applicable) after 90 days

### Distribution

- Security patches are distributed **only to authorized users**
- Critical updates may require immediate action
- Users will be notified via registered email address
- Patch notes will include severity and recommended actions

---

## Confidentiality Agreement

By reporting a security issue, you agree to:

✅ **Maintain Confidentiality** - Not disclose the issue publicly until PT KGiTON releases a fix and provides clearance

✅ **Responsible Disclosure** - Follow responsible disclosure practices per industry standards

✅ **Limited Testing** - Only test on systems you own or have explicit permission to test

✅ **No Exploitation** - Not exploit the vulnerability for personal gain or to harm others

✅ **Cooperation** - Cooperate with PT KGiTON security team during investigation

---

## Vulnerability Disclosure Policy

### Timeline

- **Day 0**: Vulnerability reported
- **Day 1-3**: PT KGiTON acknowledges and begins investigation
- **Day 4-30**: Fix development and testing
- **Day 31-60**: Patch distribution to licensed users
- **Day 90**: Public disclosure (if applicable and agreed upon)

### Public Disclosure

Public disclosure will only occur:
- After a fix is available and distributed
- After 90-day grace period (minimum)
- With mutual agreement between reporter and PT KGiTON
- In compliance with legal requirements

---

## Security Best Practices

### For SDK Users

1. **Keep Updated** - Always use the latest SDK version
2. **Secure Storage** - Store license keys securely (never in source code)
3. **API Keys** - Protect API keys and tokens
4. **Network Security** - Use HTTPS for all API communications
5. **Input Validation** - Validate all user inputs
6. **Error Handling** - Don't expose sensitive information in error messages
7. **Code Review** - Review integration code for security issues

### License Key Protection

- ⚠️ Never commit license keys to version control
- ⚠️ Use environment variables or secure storage
- ⚠️ Rotate keys if compromised
- ⚠️ Limit key distribution to authorized personnel

---

## Security Features

The KGiTON SDK includes:

- ✅ License-based authentication
- ✅ Encrypted device communication
- ✅ JWT token-based API authentication
- ✅ Automatic token refresh
- ✅ HTTPS-only API communication
- ✅ Input validation and sanitization
- ✅ Comprehensive error handling

---

## Scope

This security policy covers:

- ✅ KGiTON SDK (all versions)
- ✅ Device communication layer
- ✅ API client implementation
- ✅ Authentication mechanisms
- ✅ Example applications

Out of scope:
- ❌ Third-party dependencies (report to their maintainers)
- ❌ Issues in user's own application code
- ❌ Physical device security
- ❌ Backend infrastructure (covered separately)

---

## Recognition

PT KGiTON values security researchers who:
- Follow responsible disclosure practices
- Provide detailed, helpful reports
- Cooperate with our security team

While we don't offer a bug bounty program, we:
- Acknowledge helpful reporters (with permission)
- May offer recognition on our website/documentation
- Provide priority support to active security contributors

## Contact Information

### Security Team

📧 **Email:** support@kgiton.com  
📝 **Subject Format:** `[SECURITY] License-ID - Brief Description`  
⏱️ **Response Time:** See table above based on severity

### General Support

📧 **Email:** support@kgiton.com  
🌐 **Website:** https://www.kgiton.com

### Emergency Contact (Enterprise License Only)

For critical security issues affecting production systems:
- Contact via your dedicated support channel
- Available 24/7 for Enterprise license holders

---

## Legal Notice

### Unauthorized Access

⚠️ **WARNING**: Unauthorized access, use, or analysis of this software is strictly prohibited.

Attempting to:
- Access the SDK without a valid license
- Reverse engineer or decompile the software
- Exploit vulnerabilities for malicious purposes
- Distribute confidential information

May result in:
- Civil liability
- Criminal prosecution
- License termination
- Legal action for damages

### Compliance

This security policy complies with:
- Indonesian cybersecurity laws
- International responsible disclosure standards
- Industry best practices for proprietary software

---

**© 2025 PT KGiTON. All Rights Reserved.**

For licensing information, see [AUTHORIZATION.md](AUTHORIZATION.md).  
For general support, see [README.md](README.md).
