#ifndef LUA_HPP
#define LUA_HPP

// Stub lua header for compilation
// This would normally include the full Lua C++ interface

extern "C" {
    // Basic Lua types
    typedef struct lua_State lua_State;
    typedef int (*lua_CFunction) (lua_State *L);
    
    // Basic Lua functions
    lua_State *luaL_newstate(void);
    void luaL_openlibs(lua_State *L);
    void lua_close(lua_State *L);
    
    int luaL_dostring(lua_State *L, const char *str);
    int luaL_dofile(lua_State *L, const char *filename);
    
    void lua_pushnil(lua_State *L);
    void lua_pushboolean(lua_State *L, int b);
    void lua_pushinteger(lua_State *L, int n);
    void lua_pushnumber(lua_State *L, double n);
    void lua_pushstring(lua_State *L, const char *s);
    
    int lua_gettop(lua_State *L);
    void lua_settop(lua_State *L, int idx);
    void lua_pop(lua_State *L, int n);
    
    int lua_type(lua_State *L, int idx);
    int lua_isnil(lua_State *L, int idx);
    int lua_isboolean(lua_State *L, int idx);
    int lua_isnumber(lua_State *L, int idx);
    int lua_isstring(lua_State *L, int idx);
    
    int lua_toboolean(lua_State *L, int idx);
    int lua_tointeger(lua_State *L, int idx);
    double lua_tonumber(lua_State *L, int idx);
    const char *lua_tostring(lua_State *L, int idx);
    
    void lua_getglobal(lua_State *L, const char *name);
    void lua_setglobal(lua_State *L, const char *name);
    
    void lua_pushcclosure(lua_State *L, lua_CFunction fn, int n);
    void lua_register(lua_State *L, const char *name, lua_CFunction f);
    
    int lua_pcall(lua_State *L, int nargs, int nresults, int errfunc);
    
    // Lua types
    #define LUA_TNONE           (-1)
    #define LUA_TNIL            0
    #define LUA_TBOOLEAN        1
    #define LUA_TLIGHTUSERDATA  2
    #define LUA_TNUMBER         3
    #define LUA_TSTRING         4
    #define LUA_TTABLE          5
    #define LUA_TFUNCTION       6
    #define LUA_TUSERDATA       7
    #define LUA_TTHREAD         8
    
    // Lua status
    #define LUA_OK              0
    #define LUA_YIELD           1
    #define LUA_ERRRUN          2
    #define LUA_ERRSYNTAX       3
    #define LUA_ERRMEM          4
    #define LUA_ERRERR          5
}

#endif // LUA_HPP