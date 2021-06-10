
DTC ?= dtc
CPP ?= cpp
DESTDIR ?=

DTCVERSION ?= $(shell $(DTC) --version | grep ^Version | sed 's/^.* //g')

MAKEFLAGS += -rR --no-print-directory

# Do not:
# o  use make's built-in rules and variables
#    (this increases performance and avoids hard-to-debug behaviour);
# o  print "Entering directory ...";
MAKEFLAGS += -rR --no-print-directory

# To put more focus on warnings, be less verbose as default
# Use 'make V=1' to see the full commands

DTC_FLAGS += -Wno-unit_address_vs_reg
#http://snapshot.debian.org/binary/device-tree-compiler/
#http://snapshot.debian.org/package/device-tree-compiler/1.4.4-1/#device-tree-compiler_1.4.4-1
#http://snapshot.debian.org/archive/debian/20170925T220404Z/pool/main/d/device-tree-compiler/device-tree-compiler_1.4.4-1_amd64.deb

ifeq "$(DTCVERSION)" "1.4.5"
	#GIT BROKEN!!!! Ubuntu Bionic has patches..
	DTC_FLAGS += -Wno-dmas_property
	DTC_FLAGS += -Wno-gpios_property
	DTC_FLAGS += -Wno-pwms_property
	DTC_FLAGS += -Wno-interrupts_property
endif

ifeq "$(DTCVERSION)" "1.4.6"
	#http://snapshot.debian.org/package/device-tree-compiler/1.4.6-1/#device-tree-compiler_1.4.6-1
	#http://snapshot.debian.org/archive/debian/20180426T224735Z/pool/main/d/device-tree-compiler/device-tree-compiler_1.4.6-1_amd64.deb
	#Debian: 1.4.6
	DTC_FLAGS += -Wno-chosen_node_is_root
	DTC_FLAGS += -Wno-alias_paths
	DTC_FLAGS += -Wno-avoid_unnecessary_addr_size
endif

ifeq "$(DTCVERSION)" "1.4.7"
	#http://snapshot.debian.org/package/device-tree-compiler/1.4.7-3/#device-tree-compiler_1.4.7-3
	#http://snapshot.debian.org/archive/debian/20180911T215003Z/pool/main/d/device-tree-compiler/device-tree-compiler_1.4.7-3_amd64.deb
	#Debian: 1.4.6
	DTC_FLAGS += -Wno-chosen_node_is_root
	DTC_FLAGS += -Wno-alias_paths
	DTC_FLAGS += -Wno-avoid_unnecessary_addr_size
endif

ifeq "$(DTCVERSION)" "1.5.0"
	#http://snapshot.debian.org/package/device-tree-compiler/1.5.0-1/#device-tree-compiler_1.5.0-1
	#http://snapshot.debian.org/archive/debian/20190313T032949Z/pool/main/d/device-tree-compiler/device-tree-compiler_1.5.0-1_amd64.deb
	#Debian: 1.4.6
	DTC_FLAGS += -Wno-chosen_node_is_root
	DTC_FLAGS += -Wno-alias_paths
	DTC_FLAGS += -Wno-avoid_unnecessary_addr_size
endif

ifeq "$(DTCVERSION)" "2.0.0"
	#BUILDBOT...http://gfnd.rcn-ee.org:8080/job/beagleboard_overlays/job/master/
	DTC_FLAGS += -Wno-chosen_node_is_root
	DTC_FLAGS += -Wno-alias_paths
endif


ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

# If the user is running make -s (silent mode), suppress echoing of
# commands

export quiet Q KBUILD_VERBOSE

clean:
	$(Q)$(MAKE) PLATFORM=jetsonnano clean_arch

ifeq ($(PLATFORM),)

ALL_DTS		:= $(shell find overlays/* -name \*.dts)

ALL_DTB		:= $(patsubst %.dts,%.dtbo,$(ALL_DTS))

$(ALL_DTB): PLATFORM=$(word 2,$(subst /, ,$@))
$(ALL_DTB):
	$(Q)$(MAKE) PLATFORM=$(PLATFORM) $@

else

PLATFORM_DTS	:= $(shell find overlays/$(PLATFORM) -name \*.dts)

PLATFORM_DTB	:= $(patsubst %.dts,%.dtbo,$(PLATFORM_DTS))

src	:= overlays/$(PLATFORM)
obj	:= overlays/$(PLATFORM)

include scripts/Kbuild.include

cmd_files := $(wildcard $(foreach f,$(PLATFORM_DTB),$(dir $(f)).$(notdir $(f)).cmd))

ifneq ($(cmd_files),)
  include $(cmd_files)
endif

quiet_cmd_clean    = CLEAN   $(obj)
      cmd_clean    = rm -f $(__clean-files)

dtc-tmp = $(subst $(comma),_,$(dot-target).dts.tmp)

dtc_cpp_flags  = -Wp,-MD,$(depfile).pre.tmp -nostdinc		\
                 -Iinclude -I$(src) -Ioverlays -Itestcase-data	\
                 -undef -D__DTS__

quiet_cmd_dtc = DTC     $@
cmd_dtc = $(CPP) $(dtc_cpp_flags) -x assembler-with-cpp -o $(dtc-tmp) $< ; \
        $(DTC) -O dtb -o $@ -b 0 -@ \
                -i $(src) -iinclude $(DTC_FLAGS) \
                -d $(depfile).dtc.tmp $(dtc-tmp) ; \
        cat $(depfile).pre.tmp $(depfile).dtc.tmp > $(depfile)

$(obj)/%.dtbo: $(src)/%.dts
	$(call if_changed_dep,dtc)

clean_arch: __clean-files = $(PLATFORM_DTB)
clean_arch: 
	$(call cmd,clean)
	@find . $(RCS_FIND_IGNORE) \
		\( -name '.*.cmd' \
		-o -name '.*.d' \
		-o -name '.*.tmp' \
		\) -type f -print | xargs rm -f

endif

