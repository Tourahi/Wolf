#include "main.h"
#include <gio/gio.h>


#define STRINGIFY(s) #s
#define TOSTRING(s) STRINGIFY(s)

// TODO: shared dir
static gchar *get_app_root(const gchar *in_path) {
    gchar *called = (g_file_test("/proc/self/exe", G_FILE_TEST_IS_SYMLINK)) ?
                    g_file_read_link("/proc/self/exe", NULL) :
                    g_strdup(in_path);
    
    gchar *path;
    GFile *root, *app, *parent;

    app = g_file_new_for_path(called);
    parent = g_file_get_parent(app);
    root = g_file_get_parent(parent);

    path = g_file_get_path(root);
    g_free(called);
    g_object_unref(app);
    g_object_unref(parent);
    g_object_unref(root);

    return path;
}

static lua_State *open_state(const gchar *root)
{
  lua_State *l = luaL_newstate();
  luaL_openlibs(l);

  luaopen_lpeg(l);
  lua_pop(l, 1);

  return l;
}

static void run_lua(int argc, char *argv[], const gchar *app_root, lua_State *L)
{

  gchar *init_script;
  int status, i;

  init_script = g_build_filename(app_root, "src", "lib", "wolf", "init.lua", NULL);
  status = luaL_loadfile(L, init_script);
  g_free(init_script);

  if (status) {
    fprintf(stderr, "Couldn't load file: %s\n", lua_tostring(L, -1));
    exit(1);
  }
  
  lua_pushstring(L, (char *)app_root);
  lua_newtable(L);
  for(i = 0; i < argc; ++i) {
    lua_pushnumber(L, i + 1);
    lua_pushstring(L, argv[i]);
    lua_settable(L, -3);
  }
  status = lua_pcall(L, 2, 0, 0);

  if (status) {
    g_critical("Failed to run script: %s\n", lua_tostring(L, -1));
    exit(1);
  }
}

int main(int argc, char *argv[])
{
  if (argc >= 2 && strcmp(argv[1], "--compile") == 0)
  {
// see : https://docs.gtk.org/gobject/func.type_init.html
#if !GLIB_CHECK_VERSION(2, 36, 0)
    g_type_init();
#endif
  }
  else {
    gtk_init(&argc, &argv);
  }

  gchar *root = get_app_root(argv[0]);
  lua_State *L = open_state(root);
  run_lua(argc, argv, root, L);

  lua_close(L);
  g_free(root);

  return 0;
}