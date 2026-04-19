#!/usr/bin/env bash

set -euo pipefail

HOSTNAME_LABEL="myserver"
BASELINE_FILE="/var/lib/raspi-audit/baseline.json"
REPORT_FILE="/tmp/raspi-weekly-audit.txt"
MAIL_TO="admin@example.com"
MAIL_SUBJECT="Raspi Weekly Security Audit — host: ${HOSTNAME_LABEL} — $(date '+%Y-%m-%d %H:%M:%S')"

log_section() {
    printf '\n[%s] %s\n' "$1" "$2" >> "${REPORT_FILE}"
}

write_line() {
    printf '%s\n' "$1" >> "${REPORT_FILE}"
}

send_report() {
    if command -v mail >/dev/null 2>&1; then
        mail -s "${MAIL_SUBJECT}" "${MAIL_TO}" < "${REPORT_FILE}"
    else
        cat "${REPORT_FILE}"
    fi
}

get_current_users() {
    getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1 ":" $3 ":" $6 ":" $7}' | sort
}

get_current_cron_state() {
    {
        find /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly /etc/cron.weekly -type f 2>/dev/null | sort
        crontab -l 2>/dev/null || true
    } | sed '/^\s*$/d'
}

get_current_systemd_enabled() {
    systemctl list-unit-files --state=enabled --no-pager --no-legend 2>/dev/null | awk '{print $1}' | sort
}

get_current_setuid_files() {
    find / -perm -4000 -type f 2>/dev/null | sort
}

compare_against_baseline() {
    local label="$1"
    local current_file="$2"
    local baseline_file="$3"

    if [[ ! -f "${baseline_file}" ]]; then
        write_line "  Baseline missing for ${label}"
        return
    fi

    local added removed
    added=$(comm -13 "${baseline_file}" "${current_file}" || true)
    removed=$(comm -23 "${baseline_file}" "${current_file}" || true)

    if [[ -z "${added}" && -z "${removed}" ]]; then
        write_line "  Ei muutoksia ${label}"
        return
    fi

    [[ -n "${added}" ]] && {
        write_line "  Uudet ${label}:"
        while IFS= read -r line; do
            [[ -n "${line}" ]] && write_line "    + ${line}"
        done <<< "${added}"
    }

    [[ -n "${removed}" ]] && {
        write_line "  Poistetut ${label}:"
        while IFS= read -r line; do
            [[ -n "${line}" ]] && write_line "    - ${line}"
        done <<< "${removed}"
    }
}

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

: > "${REPORT_FILE}"

write_line "Raspi Weekly Security Audit — host: ${HOSTNAME_LABEL} — $(date '+%Y-%m-%d %H:%M:%S')"

log_section 1 "Kirjautumiset (viimeiset 7 päivää)"
write_line "--- last -s -7days -Fwi ---"
last -s -7days -Fwi >> "${REPORT_FILE}" 2>/dev/null || write_line "last-komento epäonnistui"
write_line
write_line "--- last -s -7days -a -Fwi ---"
last -s -7days -a -Fwi >> "${REPORT_FILE}" 2>/dev/null || write_line "last -a -komento epäonnistui"
write_line
write_line "--- lastb -s -7days -Fwi ---"
lastb -s -7days -Fwi >> "${REPORT_FILE}" 2>/dev/null || write_line "lastb-komento epäonnistui"

log_section 2 "Uudet/poistetut käyttäjät (UID>=1000)"
get_current_users > "${WORKDIR}/users.current"
if [[ -f "${WORKDIR}/users.baseline" ]]; then rm -f "${WORKDIR}/users.baseline"; fi
jq -r '.users[]?' "${BASELINE_FILE}" 2>/dev/null | sort > "${WORKDIR}/users.baseline" || true
compare_against_baseline "käyttäjiin" "${WORKDIR}/users.current" "${WORKDIR}/users.baseline"

log_section 3 "Cron-muutokset vs. baseline"
get_current_cron_state > "${WORKDIR}/cron.current"
jq -r '.cron[]?' "${BASELINE_FILE}" 2>/dev/null | sort > "${WORKDIR}/cron.baseline" || true
compare_against_baseline "cron-kohteissa" "${WORKDIR}/cron.current" "${WORKDIR}/cron.baseline"

log_section 4 "systemd-enabled muutokset vs. baseline"
get_current_systemd_enabled > "${WORKDIR}/systemd.current"
jq -r '.systemd_enabled[]?' "${BASELINE_FILE}" 2>/dev/null | sort > "${WORKDIR}/systemd.baseline" || true
compare_against_baseline "systemd enable -tiloissa" "${WORKDIR}/systemd.current" "${WORKDIR}/systemd.baseline"

log_section 5 "Uudet/poistetut setuid-tiedostot vs. baseline"
get_current_setuid_files > "${WORKDIR}/setuid.current"
jq -r '.setuid_files[]?' "${BASELINE_FILE}" 2>/dev/null | sort > "${WORKDIR}/setuid.baseline" || true
compare_against_baseline "setuid-listassa" "${WORKDIR}/setuid.current" "${WORKDIR}/setuid.baseline"

write_line
write_line "Huom: tämä on automaattinen raportti. Baseline-tiedosto: ${BASELINE_FILE}"

send_report
