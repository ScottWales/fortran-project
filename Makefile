all:
.PHONY: all check clean doc

LD=$(FC)
MKDIR=mkdir -p
FFLAGS+=-warn all
FFLAGS+=-module include

ALL_SRC:=$(shell find src -type f)
BIN_SRC:=$(shell find src/bin -type f)
TEST_SRC:=$(shell find src/test -type f)

BIN:=$(patsubst src/bin/%,bin/%,$(basename $(BIN_SRC)))
TEST:=$(patsubst src/test/%,test/%,$(basename $(TEST_SRC)))
LIBS:=$(patsubst src/lib/%,lib/lib%.a,$(shell find src/lib -mindepth 1 -maxdepth 1 -type d))

F90_SRC=$(filter %.f90, $(ALL_SRC))

all:$(BIN) $(TEST)
	echo $(LIBS)
check:$(TEST)
	failed=0;for test in $^; do ./$$test || failed=$$(($$failed+1)); done;\
	    if [ $$failed -gt 0 ]; then echo "$$failed tests failed"; exit 1; fi
clean:
	$(RM) -r build bin test doc lib
doc:doxyfile $(ALL_SRC)
	doxygen $<

build/%.o:src/%.f90
	@$(MKDIR) $(dir $@)
	@$(MKDIR) include
	$(FC) $(FCFLAGS) -c -o $@ $<
build/%.o:src/%.c
	@$(MKDIR) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

bin/%:build/bin/%.o $(LIBS)
	@$(MKDIR) $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)
test/%:build/test/%.o $(LIBS)
	@$(MKDIR) $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

libsrc=$(patsubst src/lib/%,build/lib/%.o,$(basename $(filter src/lib/$(1)/%,$(ALL_SRC))))
lib/lib%.a:$(call libsrc,%)
	@$(MKDIR) $(dir $@)
	$(AR) cr  $@ $<

build/%.d:src/%.f90
	@$(MKDIR) $(dir $@)
	./module_dependencies $< > $@
-include $(patsubst src/%.f90,build/%.d,$(F90_SRC))
