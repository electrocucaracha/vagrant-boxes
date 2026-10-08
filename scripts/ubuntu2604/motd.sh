#!/bin/bash -eux

MOTD_PAM_SSHD_FILE=${MOTD_PAM_SSHD_FILE:-/etc/pam.d/sshd}
MOTD_PAM_LOGIN_FILE=${MOTD_PAM_LOGIN_FILE:-/etc/pam.d/login}
MOTD_ROOT_HOME=${MOTD_ROOT_HOME:-/root}
MOTD_VAGRANT_HOME=${MOTD_VAGRANT_HOME:-/home/vagrant}
MOTD_APT_NOTIFIER_FILE=${MOTD_APT_NOTIFIER_FILE:-/etc/apt/apt.conf.d/99update-notifier}
MOTD_FILE=${MOTD_FILE:-/etc/motd}
MOTD_NEWS_FILE=${MOTD_NEWS_FILE:-/etc/default/motd-news}

motd2604_main() {
	sed -i -e "s/motd=\/run\/motd.dynamic/motd=\/etc\/motd/g" "${MOTD_PAM_SSHD_FILE}"
	sed -i -e "s/\(.*pam_motd.so.*noupdate.*\)/# \1/g" "${MOTD_PAM_SSHD_FILE}"

	sed -i -e "s/motd=\/run\/motd.dynamic/motd=\/etc\/motd/g" "${MOTD_PAM_LOGIN_FILE}"
	sed -i -e "s/\(.*pam_motd.so.*noupdate.*\)/# \1/g" "${MOTD_PAM_LOGIN_FILE}"

	mkdir -p "${MOTD_ROOT_HOME}/.cache/"
	touch "${MOTD_ROOT_HOME}/.cache/motd.legal-displayed"

	if [ -d "${MOTD_VAGRANT_HOME}/" ]; then
		mkdir -p "${MOTD_VAGRANT_HOME}/.cache/"
		touch "${MOTD_VAGRANT_HOME}/.cache/motd.legal-displayed"
		chown vagrant:vagrant "${MOTD_VAGRANT_HOME}/.cache/"
		chown vagrant:vagrant "${MOTD_VAGRANT_HOME}/.cache/motd.legal-displayed"
	fi

	[ -f "${MOTD_APT_NOTIFIER_FILE}" ] && truncate --size=0 "${MOTD_APT_NOTIFIER_FILE}"
	[ -f "${MOTD_FILE}" ] && truncate --size=0 "${MOTD_FILE}"

	systemctl --quiet is-active update-notifier-motd.timer && systemctl stop update-notifier-motd.timer
	systemctl --quiet is-active motd-news.timer && systemctl stop motd-news.timer

	systemctl --quiet is-enabled update-notifier-motd.timer && systemctl disable update-notifier-motd.timer
	systemctl --quiet is-enabled motd-news.timer && systemctl disable motd-news.timer

	[ -f "${MOTD_NEWS_FILE}" ] && sed -i 's/.*ENABLE.*/ENABLE=0/g' "${MOTD_NEWS_FILE}"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	motd2604_main "$@"
fi
