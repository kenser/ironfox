
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#ifndef _NGINX_H_INCLUDED_
#define _NGINX_H_INCLUDED_


#define IRON_FOX "ironfox"
#define IRON_FOX_VERSION "0.0.5"


#define nginx_version      1018000
#define NGINX_VERSION      "1.18.0"
#define IRONFOX_VERSION     "0.0.5"

#ifdef IRON_FOX
#define NGINX_VER          "ironfox/" IRONFOX_VERSION
#else
#define NGINX_VER          "nginx/" NGINX_VERSION
#endif

#ifdef NGX_BUILD
#define NGINX_VER_BUILD    NGINX_VER " (" NGX_BUILD ")"
#else
#define NGINX_VER_BUILD    NGINX_VER
#endif

#define NGINX_VAR          "NGINX"
#define NGX_OLDPID_EXT     ".oldbin"


#endif /* _NGINX_H_INCLUDED_ */
