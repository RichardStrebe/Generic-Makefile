#--------------------------------------------------------------------------------#
# Names & Directories                                                            #
#--------------------------------------------------------------------------------#

# Name of the executable
PROJECT_NAME := casetrack

# Working directory
WORKING_DIR := .

# Dir of source files
SRC_DIR := $(WORKING_DIR)/src

# Dir for build files
BUILD_DIR := $(WORKING_DIR)/build

# Additional dependencies (header-only libraries)
DEP_DIR :=

# System path for installation 
PREFIX := /usr/local

# Destination directory for installation in $(DESTDIR)$(PREFIX): Usually empty
# Set variable via command-line input:  e.g.  make DESTDIR=$(WORKING_DIR)/temp install
DESTDIR ?=

#--------------------------------------------------------------------------------#
# Configurations                                                                 #
#--------------------------------------------------------------------------------#

# C++ compiler
CXX := g++

# C compiler
CC := gcc

# Assembly compiler
AS := as

# Compiler flags
CXXFLAGS := -std=c++20 -Wall
CFLAGS :=
ASFLAGS :=

# Linker flags (e.g. -l[lib]  links (static) libraries)
LDFLAGS :=

# Suffix of C++ files
CXXSUFFIX := cpp

# Suffix of C files
CSUFFIX := c

# Suffix of header files
HSUFFIX := h

# Suffix of Assembly files
ASSUFFIX := s

# Recursive wildcard function, $1: list of directories, $2: list of patterns to match
# sorting the files results in reproducible build order (https://reproducible-builds.org/docs/stable-inputs/#fn:sorted-wildcard)
# override system locale with byte-based locale => sorting independent of local settings
LC_ALL=C
rwildcard = $(foreach d,$(sort $(wildcard $(1:=/*))),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

# C++, C and Assembly files (full path, recursive search)
CXXSRC = $(call rwildcard,$(SRC_DIR),*.$(CXXSUFFIX))
CSRC = $(call rwildcard,$(SRC_DIR),*.$(CSUFFIX))
ASSRC = $(call rwildcard,$(SRC_DIR),*.$(ASSUFFIX))

# All directories in src which contain header files; append additional paths
HSRC = $(call rwildcard,$(SRC_DIR),*.$(HSUFFIX))
INC_DIR = $(sort $(dir $(HSRC))) $(DEP_DIR)

# Include flag
INC_FLAGS := $(addprefix -I,$(INC_DIR))

# Generate Make dependency files
M_FLAGS := -MMD -MP

# Append to compiler flags
CXXFLAGS := $(CXXFLAGS) $(INC_FLAGS) $(M_FLAGS)

#--------------------------------------------------------------------------------#
# General Rules                                                                  #
#--------------------------------------------------------------------------------#

.PHONY : all debug release

all : release

#--------------------------------------------------------------------------------#
# Debug Rules                                                                    #
#--------------------------------------------------------------------------------#

DBG_PROJECT_NAME = $(BUILD_DIR)/debug/$(PROJECT_NAME)
DBG_CXXFLAGS = $(CXXFLAGS) -O0 -g
DBG_CFLAGS = $(CFLAGS)
DBG_ASFLAGS = $(ASFLAGS) -O0 -g
DBG_BUILD_DIR = $(BUILD_DIR)/debug/objs
# Path for object files in build folder
DBG_OBJ = $(patsubst ./%.$(CXXSUFFIX),$(DBG_BUILD_DIR)/%.o,$(CXXSRC)) \
			 $(patsubst ./%.$(CSUFFIX),$(DBG_BUILD_DIR)/%.o,$(CSRC)) \
			 $(patsubst ./%.$(ASSUFFIX),$(DBG_BUILD_DIR)/%.o,$(ASSRC))
# Path to dependency files
DBG_DEPS := $(DBG_OBJ:.o=.d)

debug: $(DBG_PROJECT_NAME)
	@cp $(DBG_PROJECT_NAME) $(WORKING_DIR)

# Linking
$(DBG_PROJECT_NAME) : $(DBG_OBJ)
	@mkdir -p $(@D)
	@$(CXX) -o $@ $^ $(LDFLAGS)
	$(info >> BUILT TARGET: $(PROJECT_NAME))

# Rule for C++ files
$(DBG_BUILD_DIR)/%.o: $(WORKING_DIR)/%.$(CXXSUFFIX)
	@mkdir -p $(@D)
	@$(CXX) $(DBG_CXXFLAGS) $(DBG_CFLAGS) -o $@ -c $<
	$(info >  + $*.$(CXXSUFFIX))

# Rule for C files
$(DBG_BUILD_DIR)/%.o: $(WORKING_DIR)/%.$(CSUFFIX)
	@mkdir -p $(@D)
	@$(CXX) $(DBG_CFLAGS) $(DBG_CXXFLAGS) -o $@ -c $<
	$(info >  + $*.$(CSUFFIX))

# Rule for assembly files
$(DBG_BUILD_DIR)/%.o: $(WORKING_DIR)/%.$(ASSUFFIX)
	@mkdir -p $(@D)
	@$(CXX) $(DBG_ASFLAGS) -o $@ -c $<
	$(info >  + $*.$(ASSUFFIX))

#--------------------------------------------------------------------------------#
# Release Rules                                                                  #
#--------------------------------------------------------------------------------#

REL_PROJECT_NAME = $(BUILD_DIR)/release/$(PROJECT_NAME)
REL_CXXFLAGS = $(CXXFLAGS) -O3
REL_CFLAGS = $(CFLAGS)
REL_ASFLAGS = $(ASFLAGS) -O3
REL_BUILD_DIR = $(BUILD_DIR)/release/objs
# Path for object files in build folder
REL_OBJ = $(patsubst ./%.$(CXXSUFFIX),$(REL_BUILD_DIR)/%.o,$(CXXSRC)) \
			 $(patsubst ./%.$(CSUFFIX),$(REL_BUILD_DIR)/%.o,$(CSRC)) \
			 $(patsubst ./%.$(ASSUFFIX),$(REL_BUILD_DIR)/%.o,$(ASSRC))
# Path to dependency files
REL_DEPS := $(REL_OBJ:.o=.d)

release: $(REL_PROJECT_NAME)
	@cp $(REL_PROJECT_NAME) $(WORKING_DIR)

# Linking
$(REL_PROJECT_NAME) : $(REL_OBJ)
	@mkdir -p $(@D)
	@$(CXX) -o $@ $^ $(LDFLAGS)
	$(info >> BUILT TARGET: $(PROJECT_NAME))

# Rule for C++ files
$(REL_BUILD_DIR)/%.o: $(WORKING_DIR)/%.$(CXXSUFFIX)
	@mkdir -p $(@D)
	@$(CXX) $(REL_CXXFLAGS) $(REL_CFLAGS) -o $@ -c $<
	$(info >  + $*.$(CXXSUFFIX))

# Rule for C files
$(REL_BUILD_DIR)/%.o: $(WORKING_DIR)/%.$(CSUFFIX)
	@mkdir -p $(@D)
	@$(CXX) $(REL_CFLAGS) $(REL_CXXFLAGS) -o $@ -c $<
	$(info >  + $*.$(CSUFFIX))

# Rule for assembly files
$(REL_BUILD_DIR)/%.o: $(WORKING_DIR)/%.$(ASSUFFIX)
	@mkdir -p $(@D)
	@$(CXX) $(REL_ASFLAGS) -o $@ -c $<
	$(info >  + $*.$(ASSUFFIX))

#--------------------------------------------------------------------------------#
# Include Dependencies                                                           #
#--------------------------------------------------------------------------------#

-include $(DBG_DEPS) $(REL_DEPS)

#--------------------------------------------------------------------------------#
# Installation                                                                   #
#--------------------------------------------------------------------------------#

.PHONY: install uninstall

# install in release mode
install: $(REL_PROJECT_NAME)
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp $< $(DESTDIR)$(PREFIX)/bin/$(PROJECT_NAME)
	$(info >> INSTALLED TARGET: $(PROJECT_NAME))

uninstall:
	@rm -f $(DESTDIR)$(PREFIX)/bin/$(PROJECT_NAME)
	$(info >> UNINSTALLED TARGET: $(PROJECT_NAME))

#--------------------------------------------------------------------------------#
# Cleaning Rules                                                                 #
#--------------------------------------------------------------------------------#

.PHONY: clean-obj clean print-obj print-dir

clean-obj: 
	@rm -rf $(dir $(DBG_OBJ)) $(dir $(REL_OBJ)) $(DBG_PROJECT_NAME) $(REL_PROJECT_NAME)
	$(info >> OBJECT FILES DELEATED)	

clean: clean-obj
	@rm -f ./$(PROJECT_NAME)
	@rm -f ./*.o
	$(info >> BUILD CLEANED: $(PROJECT_NAME))

remake: clean all

#--------------------------------------------------------------------------------#
# Else                                                                           #
#--------------------------------------------------------------------------------#

print-obj: 
	$(info OBJ is $(OBJ))

print-dir: 
	$(info SRC is $(REL_DEPS))

#--------------------------------------------------------------------------------#
# Example Structure of the generated build directory for a given src:
#
#	+--Project
#		+--build
#		   +--debug
#			   +--objs
#					+--src
#						+testfile1.o
#						+--sub
#							+testfile2.o
#			   +executable
#		   +--release
#			   +--objs
#					+--src
#						+testfile1.o
#						+--sub
#							+testfile2.o
#				+executable
#		+--src
#		   +testfile1.cpp
#		   +--sub
#			   +testfile2.cpp
#		+Makefile
#--------------------------------------------------------------------------------#