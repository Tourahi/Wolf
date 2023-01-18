#include "main.h"
#include <gio/gio.h>


#define STRINGIFY(s) #s
#define TOSTRING(s) STRINGIFY(s)


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

  //printf( TOSTRING(GLIB_CHECK_VERSION(2, 36, 0)) );
  printf("The value of root is: %s\n",  root);

  return 0;
}