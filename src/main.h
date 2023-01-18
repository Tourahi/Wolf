
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include <glib.h>
#include <gtk/gtk.h>


#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>


/* Hookups */
int luaopen_lpeg (lua_State *L);