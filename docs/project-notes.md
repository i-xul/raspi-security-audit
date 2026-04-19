# Project Notes

## Purpose

This project was created to automate weekly security audits for a Raspberry Pi server.

The goal was to improve visibility into system activity and detect meaningful changes over time without relying on manual log inspection.

## What I learned

During this project I learned more about:

- collecting and structuring audit data using shell scripting
- using system tools like `last`, `lastb`, `systemctl`, and `find`
- comparing system state against a stored baseline
- identifying meaningful changes in users, services, and privileged files
- building automated reporting workflows
- sanitizing real-world configurations for public portfolio use

## Practical lessons

One key insight from this project was that a system can appear stable while still undergoing subtle changes over time.

By introducing a baseline comparison model, it becomes much easier to detect:

- unexpected user account changes
- configuration drift in cron jobs or services
- changes in privileged files (setuid)

Another important lesson was that regular reporting improves awareness significantly compared to reactive log checking.

## Portfolio note

This repository is based on a real audit workflow adapted into a public example.

Sensitive details such as usernames, hostnames, IP addresses, and file paths have been removed.

AI tools were used during development for ideation, debugging, and documentation, but the final workflow was tested and validated manually in a real environment.
