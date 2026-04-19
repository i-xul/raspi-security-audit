# raspi-security-audit

Weekly security audit automation for a Raspberry Pi server with baseline checks and email reporting.

## Overview

This repository documents a practical weekly security audit workflow for a Raspberry Pi server.

The purpose of the project is to improve visibility into system changes and potentially suspicious activity by collecting key audit information automatically and sending it as a scheduled report.

## Current Workflow

The audit process includes checks such as:

* recent successful login activity
* recent failed login activity
* changes in local user accounts
* cron configuration changes compared to a baseline
* systemd enabled-service changes compared to a baseline
* new or removed setuid files compared to a baseline
* automatic email delivery of the audit report

## Features

* scheduled weekly audit reporting
* baseline-based change detection
* login activity review
* service and cron drift detection
* privileged file change awareness
* email-based reporting for remote review

## Goals

* improve visibility into server state over time
* detect meaningful changes without manual inspection
* build a lightweight recurring audit process
* document a reusable home server security workflow
* create a public portfolio version of a real system administration project

## Environment

* Raspberry Pi
* Linux shell scripting
* cron or scheduled execution
* baseline comparison logic
* email notifications

## Notes

This repository is based on a real audit workflow adapted into a public example.

AI tools (ChatGPT) were used for idea exploration, script refinement, debugging, and documentation support. The final workflow was tested and adjusted manually in a real environment.

Sensitive information such as real usernames, hostnames, IP addresses, file paths, and email details has been removed from this public version.

## Repository Structure

- `scripts/` – audit automation scripts
- `examples/` – example audit reports
- `docs/` – project notes and documentation
