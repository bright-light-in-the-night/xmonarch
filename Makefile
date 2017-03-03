OPT_LEVEL ?=

CFLAGS = -Wall $(OPT_LEVEL)
CXXFLAGS = -Wall --std=c++11 $(OPT_LEVEL)

PROGS = hash_test hash_test.js hash_test2 hash_test2.js
all: $(PROGS)

OBJS = keccak.o jh_ansi_opt64.o blake.o skein.o groestl.o \
	   oaes_lib.o cryptonight.o
EM_OBJS = $(OBJS:.o=.js.o)

# emscripten docker
EM_DOCKER = docker run -v $(CURDIR):/src \
	trzeci/emscripten:sdk-tag-1.37.3-64bit
EMCC = $(EM_DOCKER) emcc
EM++ = $(EM_DOCKER) em++

$(EM_OBJS): %.js.o: %.c
	$(EMCC) $(CFLAGS) -o $@ $<

%.js: %.cc
	$(EM++) $(CXXFLAGS) -o $@ $^

%.js: %.c
	$(EMCC) $(CFLAGS) -o $@ $^

hash_test: $(OBJS)

hash_test.js: $(EM_OBJS)

hash_test2: $(OBJS)

hash_test2.js: $(EM_OBJS)

clean:
	rm -f $(OBJS) $(EM_OBJS) $(PROGS)
