PREFIX ?= /usr/local
SUNIX_NAME := $(shell uname -s)

# GTK
GTK = gtk+-3.0
GTK_CFLAGS = $(shell pkg-config --cflags $(GTK))
GTK_LIBS = $(shell pkg-config --libs $(GTK) gmodule-2.0 gio-unix-2.0)

# LuaJIT