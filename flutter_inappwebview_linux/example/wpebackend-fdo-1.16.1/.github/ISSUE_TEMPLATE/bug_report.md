---
name: Bug report
about: Create a report to help us improve
title: "[BUG]"
labels: bug
assignees: ''

---

**Bug description**
A clear and concise description of what the bug is.

**How To Reproduce**

Ordered steps to reproduce the behavior:

1. Step 1
1. ...

Relevant information and input files to reproduce the behavior:

* Envars of the user during the execution of the command (`env`)
* Base system: [e.g. Yocto (kirkstone), Buildroot, Linux distribution and
   version, local build, ...]
* Hardware target: [e.g. rpi4 64bits]
* Version of the relevant components: [e.g. cog 0.16.1, wpewebkit 2.36.8,
   mesa 22, weston 11, wayland 1.30, libinput ...]
* In case of a build error
  * The build command line causing the error
  *  The error output
* In case of a runtime error
  * The execution command line causing the error
  * Description of  the error
  * Backtrace of the coredump (in case of)

**Expected behavior**
A clear and concise description of what you expected to happen.

**Actual behavior**
A clear and concise description of what it actually happened.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Additional context**
Add any other context about the problem here.

* For the case of issues on Weston/Wayland, attach the weston log.
* For the case of memory issues, a
  [Valgrind](https://valgrind.org/docs/manual/quick-start.html) report can be
  useful to narrow down the problem.
