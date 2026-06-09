-- ============================================================
-- AWS VPC Flow Logs — Athena Queries
-- Project 2: Secure VPC with WAF, Shield & Network Firewall
-- Author: Muhammad Ahmad
-- ============================================================

-- Step 1: Create the database
CREATE DATABASE vpc_logs;

-- Step 2: Create the external table pointing to S3
CREATE EXTERNAL TABLE IF NOT EXISTS vpc_logs.vpc_flow_logs (
  version int,
  account string,
  interfaceid string,
  sourceaddress string,
  destinationaddress string,
  sourceport int,
  destinationport int,
  protocol int,
  numpackets int,
  numbytes bigint,
  starttime int,
  endtime int,
  action string,
  logstatus string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
LOCATION 's3://vpc-flow-logs-muhammad-2026/';

-- ============================================================
-- THREAT ANALYSIS QUERIES
-- ============================================================

-- Query 1: Top rejected source IPs (potential attackers)
SELECT sourceaddress, destinationport, action, COUNT(*) as hits
FROM vpc_logs.vpc_flow_logs
WHERE action = 'REJECT'
GROUP BY sourceaddress, destinationport, action
ORDER BY hits DESC
LIMIT 20;

-- Query 2: Most targeted destination ports
SELECT destinationport, COUNT(*) as attempts
FROM vpc_logs.vpc_flow_logs
WHERE action = 'REJECT'
GROUP BY destinationport
ORDER BY attempts DESC
LIMIT 10;

-- Query 3: Traffic volume by source IP
SELECT sourceaddress, SUM(numbytes) as total_bytes, COUNT(*) as total_packets
FROM vpc_logs.vpc_flow_logs
GROUP BY sourceaddress
ORDER BY total_bytes DESC
LIMIT 20;

-- Query 4: SSH brute force detection (port 22 attempts)
SELECT sourceaddress, COUNT(*) as ssh_attempts
FROM vpc_logs.vpc_flow_logs
WHERE destinationport = 22
  AND action = 'REJECT'
GROUP BY sourceaddress
ORDER BY ssh_attempts DESC;

-- Query 5: Telnet scan detection (port 23)
SELECT sourceaddress, action, COUNT(*) as hits
FROM vpc_logs.vpc_flow_logs
WHERE destinationport = 23
GROUP BY sourceaddress, action
ORDER BY hits DESC;

-- Query 6: All accepted traffic summary
SELECT interfaceid, sourceaddress, destinationaddress, destinationport, action
FROM vpc_logs.vpc_flow_logs
WHERE action = 'ACCEPT'
LIMIT 50;
