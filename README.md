# 🛡️ Project 2 — Secure VPC with WAF, Shield & Network Firewall

<div align="center">

![AWS Security](https://img.shields.io/badge/AWS-Cloud%20Security-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-22c55e?style=for-the-badge)
![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate-f59e0b?style=for-the-badge)
![Duration](https://img.shields.io/badge/Duration-4--6%20Hours-38bdf8?style=for-the-badge)

**Part of the AWS Cloud Security — 5 Core Projects Series**

[Overview](#-overview) • [Architecture](#-architecture) • [Services Used](#-services-used) • [Steps](#-implementation-steps) • [Screenshots](#-screenshots) • [Key Learnings](#-key-learnings)

</div>

---

## 📌 Overview

This project demonstrates building a **complete network security perimeter** on AWS using layered defenses. I built a production-grade secure VPC that combines multiple AWS security services to protect against DDoS attacks, web exploits, and unauthorized network access — covering the core competencies interviewers test in cloud security roles.

### 🎯 What I Built

| Component | Purpose |
|-----------|---------|
| **Secure VPC** | Multi-tier network with public, private & isolated subnets |
| **NACLs & Security Groups** | Layered stateless + stateful network controls |
| **AWS WAF** | OWASP Top 10 protection + rate limiting on ALB |
| **AWS Network Firewall** | Stateful deep packet inspection |
| **VPC Flow Logs + Athena** | Real-time traffic monitoring & threat queries |
| **AWS Shield Standard** | Automatic DDoS protection |

---

## 🏗️ Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────┐
│              AWS WAF (Web ACL)                  │
│     OWASP Rules + Rate Limiting + IP Blocks     │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│         Application Load Balancer (ALB)         │
│              Public Subnets (2 AZs)             │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│         AWS Network Firewall Subnet             │
│     Stateful Rules: Block SSH, Alert HTTP       │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│            Private App Subnets                  │
│         Security Group: app-sg                  │
│    (Only allows traffic from alb-sg)            │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│         VPC Flow Logs → S3 → Athena             │
│         Query & analyze rejected traffic        │
└─────────────────────────────────────────────────┘

Shield Standard: Active on all resources (automatic)
```

---

## ⚙️ Services Used

<div align="center">

| Service | Role | Cost |
|---------|------|------|
| **Amazon VPC** | Core network isolation | Free tier |
| **Security Groups** | Stateful instance-level firewall | Free |
| **Network ACLs** | Stateless subnet-level filtering | Free |
| **AWS WAF** | Layer 7 web application firewall | Pay-per-use |
| **AWS Network Firewall** | Stateful packet inspection | Pay-per-use |
| **Application Load Balancer** | Traffic distribution + WAF attachment | Pay-per-use |
| **VPC Flow Logs** | Network traffic logging | Free (S3 storage cost) |
| **Amazon Athena** | SQL queries on flow log data | Pay-per-query |
| **Amazon S3** | Flow log storage | Free tier |
| **AWS Shield Standard** | DDoS protection L3/L4 | Free (always on) |

</div>

---

## 📋 Implementation Steps

### Part 1 — Secure VPC Setup

- [x] Created `security-vpc` with CIDR `10.0.0.0/16` using "VPC and more" wizard
- [x] Auto-provisioned 2 public + 2 private subnets across 2 AZs
- [x] Created dedicated `firewall-subnet-1a` (`10.0.48.0/28`) for Network Firewall
- [x] Configured `alb-sg` — allows HTTP/HTTPS from internet (`0.0.0.0/0`)
- [x] Configured `app-sg` — allows traffic only from `alb-sg` (not internet)
- [x] Edited private subnet NACLs:
  - Inbound: Allow 80, 443 from VPC CIDR; deny all else
  - Outbound: Allow ephemeral ports 1024–65535

### Part 2 — Application Load Balancer

- [x] Deployed internet-facing ALB across both public subnets
- [x] Attached `alb-sg` security group
- [x] Created `test-tg` target group (HTTP:80) for WAF attachment

### Part 3 — AWS WAF

- [x] Created Web ACL (`security-waf`) in `eu-north-1`
- [x] Added managed rule groups:
  - `AWSManagedRulesCommonRuleSet` — OWASP Top 10
  - `AWSManagedRulesSQLiRuleSet` — SQL Injection
  - `AWSManagedRulesKnownBadInputsRuleSet`
- [x] Rate-based rules: GET, POST limiting (Count mode for monitoring)
- [x] Associated Web ACL with ALB

### Part 4 — Network Firewall

- [x] Created `vpc-firewall` in firewall subnet
- [x] Created `firewall-policy` with stateful rule group
- [x] Stateful rules: Block SSH (port 22), Alert on HTTP traffic
- [x] Strict rule evaluation order enabled

### Part 5 — VPC Flow Logs + Athena

- [x] Enabled VPC Flow Logs → S3 bucket (`vpc-flow-logs-muhammad-2026`)
- [x] Created Athena database `vpc_logs`
- [x] Created external table `vpc_flow_logs` pointing to S3
- [x] Ran threat analysis query — returned **20 rejected connections** from external IPs

### Part 6 — Shield Standard Verification

- [x] Confirmed Shield Standard is automatically active (no config needed)
- [x] Documented when Shield Advanced is warranted (production, SLA-critical workloads)

---

## 📸 Screenshots

> All screenshots are in the [`/screenshots`](./screenshots/) folder in sequence.

| # | Step | Screenshot |
|---|------|-----------|
| 01 | VPC Created (`security-vpc`, `10.0.0.0/16`) | [View](./screenshots/01_VPC_Created.png) |
| 02 | Firewall Subnet Created (`10.0.48.0/28`) | [View](./screenshots/02_Firewall_Subnet_Created.png) |
| 03 | Security Group 1 — `alb-sg` Created | [View](./screenshots/03_Security_Group_ALB_SG.png) |
| 04 | Security Group 2 — `app-sg` Created | [View](./screenshots/04_Security_Group_App_SG.png) |
| 05 | Application Load Balancer Created | [View](./screenshots/05_ALB_Created.png) |
| 06 | Target Group `test-tg` Created | [View](./screenshots/06_Target_Group_Created.png) |
| 07 | WAF Web ACL Created & Associated with ALB | [View](./screenshots/07_WAF_WebACL_Created.png) |
| 08 | WAF Managed Rules Added | [View](./screenshots/08_WAF_Rules_Added.png) |
| 09 | Network Firewall `vpc-firewall` Created | [View](./screenshots/09_Network_Firewall_Created.png) |
| 10 | Stateful Rule Group Active | [View](./screenshots/10_Stateful_Rules_Created.png) |
| 11 | S3 Bucket for Flow Logs Created | [View](./screenshots/11_S3_Bucket_FlowLogs.png) |
| 12 | VPC Flow Log Active (State: Active) | [View](./screenshots/12_VPC_FlowLog_Active.png) |
| 13 | Athena Table Created Successfully | [View](./screenshots/13_Athena_Table_Created.png) |
| 14 | Athena Query — 20 Rejected Connections Found | [View](./screenshots/14_Athena_Query_Results.png) |

---

## 🔍 Key Learnings

### NACLs vs Security Groups vs WAF vs Network Firewall

> This is one of the most common interview questions for cloud security roles.

| Feature | NACLs | Security Groups | WAF | Network Firewall |
|---------|-------|----------------|-----|-----------------|
| **Layer** | L3/L4 | L3/L4 | L7 | L3–L7 |
| **State** | Stateless | Stateful | Stateful | Stateful |
| **Scope** | Subnet level | Instance level | ALB/CloudFront | VPC level |
| **Rules** | Allow + Deny | Allow only | Complex conditions | Suricata-compatible |
| **Use case** | Broad subnet blocks | Per-resource control | Web exploit protection | Deep packet inspection |

### Real Threat Data from Athena Query

After enabling VPC Flow Logs, I queried rejected traffic and found **20 external IPs** being blocked — proof that the security controls are actively working. Notable blocked ports:
- Port `23` (Telnet) — legacy protocol scan
- Port `22` (SSH) — brute force attempt
- Port `88` (Kerberos) — credential attack vector

### Shield Standard vs Shield Advanced

| | Standard | Advanced |
|--|---------|---------|
| **Cost** | Free | ~$3,000/month |
| **Protection** | L3/L4 DDoS | L3/L4/L7 DDoS |
| **SRT Access** | No | 24/7 DRT team |
| **Cost Protection** | No | Yes |
| **When needed** | All accounts | Production with SLA |

---

## 🧹 Cleanup

Resources deleted after project completion to avoid charges:
```
✅ Network Firewall (vpc-firewall)
✅ Application Load Balancer (test-alb)  
✅ WAF Web ACL
✅ Target Group (test-tg)
```
Resources retained (no ongoing cost):
```
✅ VPC, Subnets, Security Groups, NACLs
✅ VPC Flow Logs (minimal S3 storage cost)
✅ Athena Database
```

---

## 📁 Project Structure

```
aws-project2-secure-vpc/
├── README.md                    ← This file
├── architecture-diagram.md      ← Detailed architecture notes  
├── athena-queries.sql           ← All SQL queries used
├── nacl-rules.md                ← NACL configuration reference
└── screenshots/
    ├── 01_VPC_Created.png
    ├── 02_Firewall_Subnet_Created.png
    ├── 03_Security_Group_ALB_SG.png
    ├── 04_Security_Group_App_SG.png
    ├── 05_ALB_Created.png
    ├── 06_Target_Group_Created.png
    ├── 07_WAF_WebACL_Created.png
    ├── 08_WAF_Rules_Added.png
    ├── 09_Network_Firewall_Created.png
    ├── 10_Stateful_Rules_Created.png
    ├── 11_S3_Bucket_FlowLogs.png
    ├── 12_VPC_FlowLog_Active.png
    ├── 13_Athena_Table_Created.png
    └── 14_Athena_Query_Results.png
```

---

## 🔗 Related Projects

| Project | Topic | Status |
|---------|-------|--------|
| [Project 1 — IAM Least-Privilege with ABAC](../project-1-iam/) | Identity & Access Management | ✅ Complete |
| **Project 2 — Secure VPC with WAF & Network Firewall** | Network Security | ✅ **You are here** |
| [Project 3 — KMS + Secrets Manager](../project-3-kms/) | Encryption & Secrets | 🔄 In Progress |
| [Project 4 — GuardDuty + Security Hub](../project-4-guardduty/) | Threat Detection | ⏳ Upcoming |
| [Project 5 — Automated Remediation](../project-5-remediation/) | Incident Response | ⏳ Upcoming |

---

<div align="center">

**Muhammad Ahmad** · AWS Cloud Security Series · 2026

![AWS](https://img.shields.io/badge/Amazon%20Web%20Services-232F3E?style=flat&logo=amazonaws&logoColor=FF9900)
![Security](https://img.shields.io/badge/Cloud%20Security-Practitioner-blue?style=flat)

</div>
