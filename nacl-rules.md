# NACL Rules Reference
## Project 2: Secure VPC with WAF, Shield & Network Firewall

---

## Private Subnet NACL

### Inbound Rules

| Rule # | Type     | Protocol | Port  | Source          | Action |
|--------|----------|----------|-------|-----------------|--------|
| 100    | HTTP     | TCP      | 80    | 10.0.0.0/16     | ALLOW  |
| 110    | HTTPS    | TCP      | 443   | 10.0.0.0/16     | ALLOW  |
| *      | All traffic | All   | All   | 0.0.0.0/0       | DENY   |

### Outbound Rules

| Rule # | Type       | Protocol | Port Range  | Destination | Action |
|--------|------------|----------|-------------|-------------|--------|
| 100    | Custom TCP | TCP      | 1024-65535  | 10.0.0.0/16 | ALLOW  |
| *      | All traffic | All     | All         | 0.0.0.0/0   | DENY   |

---

## Security Groups

### alb-sg (ALB Security Group)

**Inbound:**
| Protocol | Port | Source        | Purpose              |
|----------|------|---------------|----------------------|
| TCP      | 80   | 0.0.0.0/0     | HTTP from internet   |
| TCP      | 443  | 0.0.0.0/0     | HTTPS from internet  |

**Outbound:**
| Protocol | Port | Destination   | Purpose     |
|----------|------|---------------|-------------|
| All      | All  | 0.0.0.0/0     | All outbound |

---

### app-sg (Application Security Group)

**Inbound:**
| Protocol | Port | Source  | Purpose                        |
|----------|------|---------|--------------------------------|
| TCP      | 80   | alb-sg  | HTTP only from ALB             |
| TCP      | 443  | alb-sg  | HTTPS only from ALB            |

> ⚠️ Source is the Security Group ID of `alb-sg`, NOT an IP range.
> This ensures the app layer is never directly reachable from the internet.

**Outbound:**
| Protocol | Port | Destination | Purpose      |
|----------|------|-------------|--------------|
| All      | All  | 0.0.0.0/0   | All outbound |

---

## Key Differences: NACLs vs Security Groups

| Feature            | NACLs                        | Security Groups              |
|--------------------|------------------------------|------------------------------|
| Level              | Subnet                       | Instance / ENI               |
| State              | Stateless                    | Stateful                     |
| Rule types         | Allow AND Deny               | Allow only                   |
| Rule evaluation    | In order (lowest # first)    | All rules evaluated together |
| Return traffic     | Must explicitly allow        | Automatically allowed        |
| Use case           | Broad subnet-level blocking  | Fine-grained per-resource    |
