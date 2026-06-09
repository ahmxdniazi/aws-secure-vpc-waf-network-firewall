# Architecture Notes
## Project 2: Secure VPC with WAF, Shield & Network Firewall

---

## VPC Configuration

| Resource | Value |
|----------|-------|
| VPC Name | `security-vpc` |
| VPC ID | `vpc-0791e82268a31d279` |
| CIDR Block | `10.0.0.0/16` |
| Region | `eu-north-1` (Stockholm) |
| DNS Hostnames | Enabled |
| DNS Resolution | Enabled |

---

## Subnet Layout

| Subnet Name | CIDR | AZ | Type | Purpose |
|-------------|------|----|------|---------|
| Public Subnet 1 | `10.0.0.0/20` | eu-north-1a | Public | ALB Node |
| Public Subnet 2 | `10.0.16.0/20` | eu-north-1b | Public | ALB Node |
| Private Subnet 1 | `10.0.32.0/20` | eu-north-1a | Private | App Layer |
| Private Subnet 2 | `10.0.36.0/20` | eu-north-1b | Private | App Layer |
| Firewall Subnet | `10.0.48.0/28` | eu-north-1a | Isolated | Network Firewall |

---

## Defense Layers (Outside → Inside)

```
Layer 1: AWS Shield Standard
         └── Automatic DDoS protection (L3/L4) on all resources

Layer 2: AWS WAF (attached to ALB)
         ├── AWSManagedRulesCommonRuleSet (OWASP Top 10)
         ├── SQL Injection protection
         ├── Known bad inputs blocking
         ├── Rate limiting (GET/POST)
         └── IP reputation blocking

Layer 3: Network ACLs
         ├── Public subnets: allow 80, 443 from internet
         └── Private subnets: allow 80, 443 from VPC CIDR only

Layer 4: AWS Network Firewall (firewall subnet)
         ├── Stateful deep packet inspection
         ├── Block SSH (port 22) from internet
         └── Alert on unencrypted HTTP traffic

Layer 5: Security Groups
         ├── alb-sg: allows 80/443 from 0.0.0.0/0
         └── app-sg: allows 80/443 ONLY from alb-sg
```

---

## WAF Rules Summary

| Rule Name | Type | Action | Coverage |
|-----------|------|--------|----------|
| AWSManagedRulesCommonRuleSet | Managed | Block | OWASP Top 10 |
| AWSManagedRulesSQLiRuleSet | Managed | Block | SQL Injection |
| AWSManagedRulesKnownBadInputsRuleSet | Managed | Block | Known exploits |
| GlobalRateBasedRule | Rate-based | Count | Global rate limit |
| RateBasedRuleGET | Rate-based | Count | GET request limit |
| RateBasedRulePOST | Rate-based | Count | POST request limit |
| ManagedIPDDoSRateLimit | Rate-based | Count | DDoS mitigation |
| Amazon IP Reputation List | Managed | Block | Known bad IPs |

---

## Network Firewall Configuration

| Setting | Value |
|---------|-------|
| Firewall Name | `vpc-firewall` |
| Policy Name | `firewall-policy` |
| Rule Group | `Stateful-rules` |
| Rule Order | Strict order |
| Stateful Rule 1 | Drop TCP port 22 (SSH) |
| Stateful Rule 2 | Alert HTTP traffic |

---

## VPC Flow Logs Configuration

| Setting | Value |
|---------|-------|
| Flow Log Name | `security-flowlog-vpc` |
| Traffic Type | All |
| Destination | S3 |
| S3 Bucket | `vpc-flow-logs-muhammad-2026` |
| Format | Default |
| Aggregation | 10 minutes |
| State | Active |

---

## Athena Query Results

Running the threat analysis query returned **20 rejected connections** from external IPs, demonstrating the security controls are actively working:

Notable blocked attempts:
- `198.235.24.102` → Port `23` (Telnet scan)
- Multiple IPs → Port `22` (SSH brute force)
- `205.210.31.140` → Port `88` (Kerberos attack)
- Various IPs → High-numbered ports (port scanning activity)
