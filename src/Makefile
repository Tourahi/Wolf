PREFIX ?= /usr/local
SUNIX_NAME := $(shell uname -s)

INIT_SCRIPT = lib/wolf

# GTK
GTK = gtk+-3.0
GTK_CFLAGS = $(shell pkg-config --cflags $(GTK))
GTK_LIBS = $(shell pkg-config --libs $(GTK) gmodule-2.0 gio-unix-2.0)

# LuaJIT
# https://luajit.org/download.html
LUAJIT_V = LuaJIT-2.1.0-beta3
LUAJIT_CHECKSUM = 1ad2e34b111c802f9d0cdf019e986909123237a28c746b21295b63c9e785d9c3
LUAJIT = deps/${LUAJIT_V}
LUAJIT_SRC_DIR = $(realpath $(LUAJIT)/src)
LUAJIT_CFLAGS = -I$(LUAJIT_SRC_DIR)
LUAJIT_ARCHIVE = $(LUAJIT)/src/libluajit.a
LUAJIT_URL = http://luajit.org/download/$(LUAJIT_V).tar.gz

# LPEG
LPEG_V = lpeg-0.10.2
LPEG_CHECKSUM = d1a7698e4bcd0ac305633774062d22b27300a41673c3d733ea9993244a64ea6f
LPEG = deps/$(LPEG_V)
LPEG_OBJECT = $(LPEG)/lpeg.o
LPEG_URL = http://nordman.org/mirror/lpeg/$(LPEG_V).tar.gz

CFLAGS = -Wall -O2 -g $(LUAJIT_CFLAGS) $(GTK_CFLAGS) -DWOLF_PREFIX=$(PREFIX)
ARCHIVES = $(LUAJIT_ARCHIVE)
LIBS = -lm -ldl ${GTK_LIBS}
LD_FLAGS = -Wl,-E
OBJECTS = main.o process_helpers.o
DEP_OBJECTS = $(LPEG_OBJECT)

all: wolf bytecode

init-script:
	@find $(INIT_SCRIPT) -name 'init.moon' | xargs moonc

wolf: init-script ${OBJECTS} main.h $(ARCHIVES) $(DEP_OBJECTS) Makefile
	${CC} -o wolf ${OBJECTS} $(DEP_OBJECTS) ${ARCHIVES} ${LIBS} ${LD_FLAGS}


${OBJECTS}: %.o : %.c main.h $(LUAJIT)
	${CC} -c $< ${CFLAGS}

$(LPEG):
	@bin/download $(LPEG_URL) $(LPEG_CHECKSUM) tar xzf {file} -C deps

$(LPEG_OBJECT): $(LPEG) $(LUAJIT)
	cd ${LPEG} && $(MAKE) lpeg.o LUADIR=../../$(LUAJIT)/src

$(LUAJIT):
	@tools/download $(LUAJIT_URL) $(LUAJIT_CHECKSUM) tar xzf {file} -C deps
	@perl -piorig -e 's/LUA_IDSIZE\s*\d+/LUA_IDSIZE 120/' $(LUAJIT)/src/luaconf.h

$(LUAJIT_ARCHIVE): $(LUAJIT)
	cd ${LUAJIT} && $(MAKE) XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT"


deps-download: $(LUAJIT) $(LPEG)

deps-purge:
	rm -rf $(LUAJIT) $(LPEG)

bytecode: wolf
	-@find lib -name '*.bc' | xargs rm
	@find lib -name '*.lua' -o -name '*.moon' | xargs ./wolf --compile

clean:
	-rm -f ${OBJECTS} $(INIT_SCRIPT)/init.lua