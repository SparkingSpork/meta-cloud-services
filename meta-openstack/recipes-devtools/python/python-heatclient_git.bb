DESCRIPTION = "CLI and python client library for OpenStack Heat"
HOMEPAGE = "https://launchpad.net/heat"
SECTION = "devel/python"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=34400b68072d710fecd0a2940a0d1658"

DEPENDS += " \
        python-pip \
        python-pbr \
        "

# Satisfy setup.py 'setup_requires'
DEPENDS += " \
        python-pbr-native \
        "

RDEPENDS_${PN} +="python-cliff \
	python-httplib2 \
	python-iso8601 \
	python-prettytable \
	python-pyparsing \
	python-simplejson \
	python-pbr \
	bash \
	"

PR = "r0"
SRCNAME = "heatclient"

SRC_URI = "git://github.com/openstack/python-heatclient.git;branch=master;protocol=https"

PV = "1.17.0+git${SRCPV}"
SRCREV = "8af5deb458d51f4ec16e769d7fd6c94655f82f5f"
S = "${WORKDIR}/git"

inherit setuptools3


PACKAGECONFIG ?= "bash-completion"
PACKAGECONFIG[bash-completion] = ",,bash-completion,bash-completion ${BPN}-bash-completion"

do_install_append() {
	install -d ${D}/${sysconfdir}/bash_completion.d
	install -m 664 ${S}/tools/heat.bash_completion ${D}/${sysconfdir}/bash_completion.d
}

PACKAGES =+ "${SRCNAME}-tests ${BPN}-bash-completion"
FILES_${BPN}-bash-completion = "${sysconfdir}/bash_completion.d/*"
ALLOW_EMPTY_${SRCNAME}-tests = "1"

RDEPENDS_${SRCNAME}-tests += "python-testscenarios \
	python-mox3 \
	"
