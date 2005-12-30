# This Makefile is for the ORM extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.17 (Revision: 1.133) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
#   MakeMaker Parameters:

#     ABSTRACT => q[ORM - Powerful object-relational mapper for Perl.]
#     AUTHOR => q[Alexey V. Akimov]
#     NAME => q[ORM]
#     PREREQ_PM => { DBD::SQLite=>q[1.11] }
#     VERSION_FROM => q[lib/ORM.pm]

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/local/lib/perl5/5.8.2/mach/Config.pm)

# They may have been overridden via Makefile.PL or on the command line
AR = ar
CC = cc
CCCDLFLAGS = -DPIC -fPIC
CCDLFLAGS =   -Wl,-R/usr/local/lib/perl5/5.8.2/mach/CORE
DLEXT = so
DLSRC = dl_dlopen.xs
LD = cc
LDDLFLAGS = -shared  -L/usr/local/lib
LDFLAGS = -Wl,-E  -L/usr/local/lib
LIBC = 
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = freebsd
OSVERS = 4.7-release-p7
RANLIB = :
SITELIBEXP = /usr/local/lib/perl5/site_perl/5.8.2
SITEARCHEXP = /usr/local/lib/perl5/site_perl/5.8.2/mach
SO = so
EXE_EXT = 
FULL_AR = /usr/bin/ar
VENDORARCHEXP = 
VENDORLIBEXP = 


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
NAME = ORM
NAME_SYM = ORM
VERSION = 0.8
VERSION_MACRO = VERSION
VERSION_SYM = 0_8
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.8
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3
INSTALLDIRS = site
DESTDIR = 
PREFIX = /usr/local
PERLPREFIX = /usr/local
SITEPREFIX = /usr/local
VENDORPREFIX = 
INSTALLPRIVLIB = $(PERLPREFIX)/lib/perl5/5.8.2
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = $(SITEPREFIX)/lib/perl5/site_perl/5.8.2
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = 
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(PERLPREFIX)/lib/perl5/5.8.2/mach
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = $(SITEPREFIX)/lib/perl5/site_perl/5.8.2/mach
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = 
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(PERLPREFIX)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(SITEPREFIX)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = 
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(PERLPREFIX)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLMAN1DIR = $(PERLPREFIX)/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(SITEPREFIX)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = 
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(PERLPREFIX)/lib/perl5/5.8.2/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(SITEPREFIX)/lib/perl5/5.8.2/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = 
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB = /usr/local/lib/perl5/5.8.2/BSDPAN
PERL_ARCHLIB = /usr/local/lib/perl5/5.8.2/mach
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = $(FIRST_MAKEFILE).old
MAKE_APERL_FILE = $(FIRST_MAKEFILE).aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/local/lib/perl5/5.8.2/mach/CORE
PERL = /usr/local/bin/perl
FULLPERL = /usr/local/bin/perl
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/local/lib/perl5/5.8.2/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.17
MM_REVISION = 1.133

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
FULLEXT = ORM
BASEEXT = ORM
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/ORM.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = lib/ORM.ru.pod

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DIRFILESEP)Config.pm $(PERL_INC)$(DIRFILESEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/ORM.pm \
	lib/ORM.ru.pod \
	lib/ORM/Base.pm \
	lib/ORM/Broken.pm \
	lib/ORM/Cache.pm \
	lib/ORM/Const.pm \
	lib/ORM/Date.pm \
	lib/ORM/Datetime.pm \
	lib/ORM/Db.pm \
	lib/ORM/Db/DBI.pm \
	lib/ORM/Db/DBI/MySQL.pm \
	lib/ORM/Db/DBI/SQLite.pm \
	lib/ORM/Db/DBIResultSet.pm \
	lib/ORM/Db/DBIResultSetFull.pm \
	lib/ORM/Db/Replicated.pm \
	lib/ORM/DbLog.pm \
	lib/ORM/DbResultSet.pm \
	lib/ORM/Error.pm \
	lib/ORM/Expr.pm \
	lib/ORM/Filter.pm \
	lib/ORM/Filter/Case.pm \
	lib/ORM/Filter/Cmp.pm \
	lib/ORM/Filter/Func.pm \
	lib/ORM/Filter/Group.pm \
	lib/ORM/Filter/Interval.pm \
	lib/ORM/History.pm \
	lib/ORM/Ident.pm \
	lib/ORM/Meta/ORM/Date.pm \
	lib/ORM/Meta/ORM/Datetime.pm \
	lib/ORM/Meta/ORM/History.pm \
	lib/ORM/Metaprop.pm \
	lib/ORM/MetapropBuilder.pm \
	lib/ORM/Order.pm \
	lib/ORM/ResultSet.pm \
	lib/ORM/Stat.pm \
	lib/ORM/StatResultSet.pm \
	lib/ORM/Ta.pm \
	lib/ORM/Tjoin.pm \
	lib/ORM/TjoinNull.pm

PM_TO_BLIB = lib/ORM/Expr.pm \
	blib/lib/ORM/Expr.pm \
	lib/ORM/Error.pm \
	blib/lib/ORM/Error.pm \
	lib/ORM/TjoinNull.pm \
	blib/lib/ORM/TjoinNull.pm \
	lib/ORM/DbResultSet.pm \
	blib/lib/ORM/DbResultSet.pm \
	lib/ORM/Filter/Case.pm \
	blib/lib/ORM/Filter/Case.pm \
	lib/ORM/Meta/ORM/History.pm \
	blib/lib/ORM/Meta/ORM/History.pm \
	lib/ORM/Cache.pm \
	blib/lib/ORM/Cache.pm \
	lib/ORM/Filter/Func.pm \
	blib/lib/ORM/Filter/Func.pm \
	lib/ORM/Db/DBIResultSetFull.pm \
	blib/lib/ORM/Db/DBIResultSetFull.pm \
	lib/ORM/Db/DBI.pm \
	blib/lib/ORM/Db/DBI.pm \
	lib/ORM/ResultSet.pm \
	blib/lib/ORM/ResultSet.pm \
	lib/ORM/Const.pm \
	blib/lib/ORM/Const.pm \
	lib/ORM/Ident.pm \
	blib/lib/ORM/Ident.pm \
	lib/ORM/Base.pm \
	blib/lib/ORM/Base.pm \
	lib/ORM/Tjoin.pm \
	blib/lib/ORM/Tjoin.pm \
	lib/ORM/Filter/Interval.pm \
	blib/lib/ORM/Filter/Interval.pm \
	lib/ORM/History.pm \
	blib/lib/ORM/History.pm \
	lib/ORM/Broken.pm \
	blib/lib/ORM/Broken.pm \
	lib/ORM/Meta/ORM/Datetime.pm \
	blib/lib/ORM/Meta/ORM/Datetime.pm \
	lib/ORM/Db/DBI/SQLite.pm \
	blib/lib/ORM/Db/DBI/SQLite.pm \
	lib/ORM/Date.pm \
	blib/lib/ORM/Date.pm \
	lib/ORM.pm \
	blib/lib/ORM.pm \
	lib/ORM/StatResultSet.pm \
	blib/lib/ORM/StatResultSet.pm \
	lib/ORM/Db.pm \
	blib/lib/ORM/Db.pm \
	lib/ORM/MetapropBuilder.pm \
	blib/lib/ORM/MetapropBuilder.pm \
	lib/ORM/Metaprop.pm \
	blib/lib/ORM/Metaprop.pm \
	lib/ORM/Filter/Group.pm \
	blib/lib/ORM/Filter/Group.pm \
	lib/ORM/Order.pm \
	blib/lib/ORM/Order.pm \
	lib/ORM/Filter/Cmp.pm \
	blib/lib/ORM/Filter/Cmp.pm \
	lib/ORM/Meta/ORM/Date.pm \
	blib/lib/ORM/Meta/ORM/Date.pm \
	lib/ORM/Db/DBI/MySQL.pm \
	blib/lib/ORM/Db/DBI/MySQL.pm \
	lib/ORM/Filter.pm \
	blib/lib/ORM/Filter.pm \
	lib/ORM.ru.pod \
	blib/lib/ORM.ru.pod \
	lib/ORM/Ta.pm \
	blib/lib/ORM/Ta.pm \
	lib/ORM/DbLog.pm \
	blib/lib/ORM/DbLog.pm \
	lib/ORM/Datetime.pm \
	blib/lib/ORM/Datetime.pm \
	lib/ORM/Stat.pm \
	blib/lib/ORM/Stat.pm \
	lib/ORM/Db/DBIResultSet.pm \
	blib/lib/ORM/Db/DBIResultSet.pm \
	lib/ORM/Db/Replicated.pm \
	blib/lib/ORM/Db/Replicated.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 1.42
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(PERLRUN)  -e 'use AutoSplit;  autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1)'



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(SHELL) -c true
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(PERLRUN) "-MExtUtils::Command" -e mkpath
EQUALIZE_TIMESTAMP = $(PERLRUN) "-MExtUtils::Command" -e eqtime
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(PERLRUN) -MExtUtils::Install -e 'install({@ARGV}, '\''$(VERBINST)'\'', 0, '\''$(UNINST)'\'');'
DOC_INSTALL = $(PERLRUN) "-MExtUtils::Command::MM" -e perllocal_install
UNINSTALL = $(PERLRUN) "-MExtUtils::Command::MM" -e uninstall
WARN_IF_OLD_PACKLIST = $(PERLRUN) "-MExtUtils::Command::MM" -e warn_if_old_packlist


# --- MakeMaker makemakerdflt section:
makemakerdflt: all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = ORM
DISTVNAME = ORM-0.8


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIB="$(LIB)"\
	LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	OPTIMIZE="$(OPTIMIZE)"\
	PASTHRU_DEFINE="$(PASTHRU_DEFINE)"\
	PASTHRU_INC="$(PASTHRU_INC)"


# --- MakeMaker special_targets section:
.SUFFIXES: .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) $(INST_LIBDIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

config :: $(INST_ARCHAUTODIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

config :: $(INST_AUTODIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)

$(INST_AUTODIR)/.exists :: /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h $(INST_AUTODIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_AUTODIR)

$(INST_LIBDIR)/.exists :: /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h $(INST_LIBDIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_LIBDIR)

$(INST_ARCHAUTODIR)/.exists :: /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h $(INST_ARCHAUTODIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_ARCHAUTODIR)

config :: $(INST_MAN3DIR)$(DIRFILESEP).exists
	$(NOECHO) $(NOOP)


$(INST_MAN3DIR)/.exists :: /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(EQUALIZE_TIMESTAMP) /usr/local/lib/perl5/5.8.2/mach/CORE/perl.h $(INST_MAN3DIR)/.exists

	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_MAN3DIR)

help:
	perldoc ExtUtils::MakeMaker


# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/ORM.ru.pod \
	lib/ORM.ru.pod
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW)\
	  lib/ORM.ru.pod $(INST_MAN3DIR)/ORM.ru.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	-$(RM_RF) ./blib $(MAKE_APERL_FILE) $(INST_ARCHAUTODIR)/extralibs.all $(INST_ARCHAUTODIR)/extralibs.ld perlmain.c tmon.out mon.out so_locations pm_to_blib *$(OBJ_EXT) *$(LIB_EXT) perl.exe perl perl$(EXE_EXT) $(BOOTSTRAP) $(BASEEXT).bso $(BASEEXT).def lib$(BASEEXT).def $(BASEEXT).exp $(BASEEXT).x core core.*perl.*.? *perl.core core.[0-9] core.[0-9][0-9] core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9][0-9]
	-$(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:

# Delete temporary files (via clean) and also delete installed files
realclean purge ::  clean realclean_subdirs
	$(RM_RF) $(INST_AUTODIR) $(INST_ARCHAUTODIR)
	$(RM_RF) $(DISTVNAME)
	$(RM_F)  blib/lib/ORM/Db/Replicated.pm blib/lib/ORM/Base.pm blib/lib/ORM/DbLog.pm blib/lib/ORM/Filter/Cmp.pm blib/lib/ORM/Filter/Case.pm blib/lib/ORM/Filter/Interval.pm blib/lib/ORM/TjoinNull.pm
	$(RM_F) blib/lib/ORM/Cache.pm blib/lib/ORM/Filter/Group.pm blib/lib/ORM/Const.pm blib/lib/ORM/Filter.pm blib/lib/ORM/Metaprop.pm $(FIRST_MAKEFILE) blib/lib/ORM/Ta.pm blib/lib/ORM/DbResultSet.pm
	$(RM_F) blib/lib/ORM/Order.pm blib/lib/ORM/Meta/ORM/Datetime.pm blib/lib/ORM/Db/DBIResultSetFull.pm blib/lib/ORM/Ident.pm blib/lib/ORM/Db/DBIResultSet.pm blib/lib/ORM/Meta/ORM/Date.pm
	$(RM_F) blib/lib/ORM/StatResultSet.pm blib/lib/ORM/Meta/ORM/History.pm blib/lib/ORM/Db/DBI.pm blib/lib/ORM/Filter/Func.pm blib/lib/ORM.pm $(MAKEFILE_OLD) blib/lib/ORM/Tjoin.pm blib/lib/ORM/ResultSet.pm
	$(RM_F) blib/lib/ORM/History.pm blib/lib/ORM/Db/DBI/MySQL.pm blib/lib/ORM/Broken.pm blib/lib/ORM/Stat.pm blib/lib/ORM/Expr.pm blib/lib/ORM/Date.pm blib/lib/ORM/Db/DBI/SQLite.pm blib/lib/ORM/Error.pm
	$(RM_F) blib/lib/ORM/Db.pm blib/lib/ORM/MetapropBuilder.pm blib/lib/ORM/Datetime.pm blib/lib/ORM.ru.pod


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(ECHO) '# http://module-build.sourceforge.net/META-spec.html' > META.yml
	$(NOECHO) $(ECHO) '#XXXXXXX This is a prototype!!!  It will change in the future!!! XXXXX#' >> META.yml
	$(NOECHO) $(ECHO) 'name:         ORM' >> META.yml
	$(NOECHO) $(ECHO) 'version:      0.8' >> META.yml
	$(NOECHO) $(ECHO) 'version_from: lib/ORM.pm' >> META.yml
	$(NOECHO) $(ECHO) 'installdirs:  site' >> META.yml
	$(NOECHO) $(ECHO) 'requires:' >> META.yml
	$(NOECHO) $(ECHO) '    DBD::SQLite:                   1.11' >> META.yml
	$(NOECHO) $(ECHO) '' >> META.yml
	$(NOECHO) $(ECHO) 'distribution_type: module' >> META.yml
	$(NOECHO) $(ECHO) 'generated_by: ExtUtils::MakeMaker version 6.17' >> META.yml


# --- MakeMaker metafile_addtomanifest section:
metafile_addtomanifest:
	$(NOECHO) $(PERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{META.yml} => q{Module meta-data (added by MakeMaker)}}) } ' \
	-e '    or print "Could not add META.yml to MANIFEST: $${'\''@'\''}\n"'


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ *.orig */*~ */*.orig



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(PERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	-e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';'

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
distdir : metafile metafile_addtomanifest
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"



# --- MakeMaker dist_test section:

disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)


# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker install section:

install :: all pure_install doc_install

install_perl :: all pure_perl_install doc_perl_install

install_site :: all pure_site_install doc_site_install

install_vendor :: all pure_vendor_install doc_vendor_install

pure_install :: pure_$(INSTALLDIRS)_install

doc_install :: doc_$(INSTALLDIRS)_install

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE:
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:

# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	-$(MAKE) -f $(MAKEFILE_OLD) clean $(DEV_NULL) || $(NOOP)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the make command.  <=="
	false



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/local/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) -f $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE)
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE)

test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd:
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="0,8,0,0">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <TITLE>$(DISTNAME)</TITLE>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>ORM - Powerful object-relational mapper for Perl.</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Alexey V. Akimov</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DBD-SQLite" VERSION="1,11,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <OS NAME="$(OSNAME)" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="i386-freebsd" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib: $(TO_INST_PM)
	$(NOECHO) $(PERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', '\''$(PM_FILTER)'\'')'\
	  lib/ORM/Expr.pm blib/lib/ORM/Expr.pm \
	  lib/ORM/Error.pm blib/lib/ORM/Error.pm \
	  lib/ORM/TjoinNull.pm blib/lib/ORM/TjoinNull.pm \
	  lib/ORM/DbResultSet.pm blib/lib/ORM/DbResultSet.pm \
	  lib/ORM/Filter/Case.pm blib/lib/ORM/Filter/Case.pm \
	  lib/ORM/Meta/ORM/History.pm blib/lib/ORM/Meta/ORM/History.pm \
	  lib/ORM/Cache.pm blib/lib/ORM/Cache.pm \
	  lib/ORM/Filter/Func.pm blib/lib/ORM/Filter/Func.pm \
	  lib/ORM/Db/DBIResultSetFull.pm blib/lib/ORM/Db/DBIResultSetFull.pm \
	  lib/ORM/Db/DBI.pm blib/lib/ORM/Db/DBI.pm \
	  lib/ORM/ResultSet.pm blib/lib/ORM/ResultSet.pm \
	  lib/ORM/Const.pm blib/lib/ORM/Const.pm \
	  lib/ORM/Ident.pm blib/lib/ORM/Ident.pm \
	  lib/ORM/Base.pm blib/lib/ORM/Base.pm \
	  lib/ORM/Tjoin.pm blib/lib/ORM/Tjoin.pm \
	  lib/ORM/Filter/Interval.pm blib/lib/ORM/Filter/Interval.pm \
	  lib/ORM/History.pm blib/lib/ORM/History.pm \
	  lib/ORM/Broken.pm blib/lib/ORM/Broken.pm \
	  lib/ORM/Meta/ORM/Datetime.pm blib/lib/ORM/Meta/ORM/Datetime.pm \
	  lib/ORM/Db/DBI/SQLite.pm blib/lib/ORM/Db/DBI/SQLite.pm \
	  lib/ORM/Date.pm blib/lib/ORM/Date.pm \
	  lib/ORM.pm blib/lib/ORM.pm \
	  lib/ORM/StatResultSet.pm blib/lib/ORM/StatResultSet.pm \
	  lib/ORM/Db.pm blib/lib/ORM/Db.pm \
	  lib/ORM/MetapropBuilder.pm blib/lib/ORM/MetapropBuilder.pm \
	  lib/ORM/Metaprop.pm blib/lib/ORM/Metaprop.pm \
	  lib/ORM/Filter/Group.pm blib/lib/ORM/Filter/Group.pm \
	  lib/ORM/Order.pm blib/lib/ORM/Order.pm \
	  lib/ORM/Filter/Cmp.pm blib/lib/ORM/Filter/Cmp.pm \
	  lib/ORM/Meta/ORM/Date.pm blib/lib/ORM/Meta/ORM/Date.pm \
	  lib/ORM/Db/DBI/MySQL.pm blib/lib/ORM/Db/DBI/MySQL.pm \
	  lib/ORM/Filter.pm blib/lib/ORM/Filter.pm \
	  lib/ORM.ru.pod blib/lib/ORM.ru.pod \
	  lib/ORM/Ta.pm blib/lib/ORM/Ta.pm \
	  lib/ORM/DbLog.pm blib/lib/ORM/DbLog.pm \
	  lib/ORM/Datetime.pm blib/lib/ORM/Datetime.pm \
	  lib/ORM/Stat.pm blib/lib/ORM/Stat.pm \
	  lib/ORM/Db/DBIResultSet.pm blib/lib/ORM/Db/DBIResultSet.pm \
	  lib/ORM/Db/Replicated.pm blib/lib/ORM/Db/Replicated.pm 
	$(NOECHO) $(TOUCH) $@

# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
