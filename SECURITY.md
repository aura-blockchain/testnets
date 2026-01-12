# Security Policy

## Scope

This policy covers the AURA testnet infrastructure including:
- Network configuration files (genesis.json, chain.json)
- Public endpoints (RPC, REST, gRPC)
- Validator node configurations

For vulnerabilities in the core AURA blockchain code, report to the [main repository](https://github.com/aura-blockchain/aura/security).

## Reporting a Vulnerability

**Email**: security@aurablockchain.org

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Affected components (validator, endpoint, config)

## Response Timeline

| Severity | Response | Resolution Target |
|----------|----------|-------------------|
| Critical | 24 hours | 7 days |
| High | 48 hours | 14 days |
| Medium | 7 days | 30 days |
| Low | 14 days | 60 days |

## Testnet-Specific Notes

- Testnets use non-production keys and have no real value at stake
- Endpoint availability issues are lower priority than consensus bugs
- Configuration errors that could propagate to mainnet are treated as High severity

## Recognition

Contributors who responsibly disclose vulnerabilities will be acknowledged in release notes (with permission).
