# Amiga includes

This repository contains my include files for amiga assembly development. Everything is still very much a work in progress, but once it's complete, the goal is to obviate the need to pull in the entire NDK when most of it concerns features that are practically useless in modern "retro-dev." The following includes will be available:

- `prologue.i`: Register definitions and descriptions, as well as utilities to interact with Exec.
- `interface.i`: All the tools needed to interface with the most commonly used OS facilities such as `dos.library`.
- `startup.i`: A pair of macros intended to enclose your program so that you don't have to worry about taking OS control and returning it.
- `utility.i`: Miscellaneous useful macros and procedures.