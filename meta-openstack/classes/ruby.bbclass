#
# Copyright (C) 2014 Wind River Systems, Inc.
#
DEPENDS += " \
    ruby-native \
"
RDEPENDS += " \
    ruby \
"

#${PN}_do_compile[depends] += "ruby-native:do_populate_sysroot"

def get_rubyversion(p):
    import re
    from os.path import isfile
    from subprocess import check_output
    found_version = "SOMETHING FAILED!"

    cmd = "%s/ruby" % p

    if not isfile(cmd):
       return found_version

    version = check_output([cmd, "--version"])
    
    r = re.compile("ruby ([0-9]+\.[0-9]+\.[0-9]+)*")
    m = r.match(version)
    if m:
        found_version = m.group(1)

    return found_version

def get_rubygemslocation(p):
    import re
    from os.path import isfile
    from subprocess import check_output
    found_loc = "SOMETHING FAILED!"

    cmd = "%s/gem" % p

    if not isfile(cmd):
       return found_loc

    loc = check_output([cmd, "env"]).split('\n')

    r = re.compile(".*\- (/usr.*/ruby/gems/.*)")
    for line in loc:
        m = r.match(line)
        if m:
            found_loc = m.group(1)
            break

    return found_loc

def get_rubygemsversion(p):
    import re
    from os.path import isfile
    from subprocess import check_output
    found_version = "SOMETHING FAILED!"

    cmd = "%s/gem" % p

    if not isfile(cmd):
       return found_version

    version = check_output([cmd, "env", "gemdir"])
    
    r = re.compile(".*([0-9]+\.[0-9]+\.[0-9]+)$")
    m = r.match(version)
    if m:
        found_version = m.group(1)

    return found_version

RUBY_VERSION ?= "${@get_rubyversion("${STAGING_BINDIR_NATIVE}")}"
RUBY_GEM_DIRECTORY ?= "${@get_rubygemslocation("${STAGING_BINDIR_NATIVE}")}"
RUBY_GEM_VERSION ?= "${@get_rubygemsversion("${STAGING_BINDIR_NATIVE}")}"

export GEM_HOME = "${STAGING_DIR_NATIVE}/usr/lib/ruby/gems/${RUBY_GEM_VERSION}"

RUBY_BUILD_GEMS ?= "${BPN}.gemspec"
RUBY_INSTALL_GEMS ?= "${BPN}-${BPV}.gem"

RUBY_COMPILE_FLAGS ?= 'LANG="C.UTF-8" LC_ALL="C.UTF-8"'

ruby_do_compile() {
	for gem in ${RUBY_BUILD_GEMS}; do
		${RUBY_COMPILE_FLAGS} gem build $gem
	done
}


ruby_do_install() {
	for gem in ${RUBY_INSTALL_GEMS}; do
		gem install --ignore-dependencies --local --env-shebang --install-dir ${D}/${libdir}/ruby/gems/${RUBY_GEM_VERSION}/ $gem
	done
}

EXPORT_FUNCTIONS do_compile do_install

PACKAGES = "${PN}-dbg ${PN} ${PN}-doc ${PN}-dev"

FILES_${PN}-dbg += " \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/.debug \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/*/.debug \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/*/*/.debug \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems/*/*/*/*/*/.debug \
        "

FILES_${PN} += " \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/gems \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/cache \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/bin \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/specifications \
        "

FILES_${PN}-doc += " \
        ${libdir}/ruby/gems/${RUBY_GEM_VERSION}/doc \
        "