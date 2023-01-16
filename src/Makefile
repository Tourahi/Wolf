PREFIX ?= /usr/local
SUNIX_NAME := $(shell uname -s)

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
LPEG = deps/$(LPEG_VER)
LPEG_OBJECT = $(LPEG)/lpeg.o
LPEG_URL = http://nordman.org/mirror/lpeg/$(LPEG_VER).tar.gz

