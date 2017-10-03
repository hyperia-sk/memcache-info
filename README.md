## Memcache Simple Info

[![Build Status](https://travis-ci.org/hyperia-sk/memcache-info.svg?branch=master)](https://travis-ci.org/hyperia-sk/memcache-info) [![codecov](https://codecov.io/gh/hyperia-sk/memcache-info/branch/master/graph/badge.svg)](https://codecov.io/gh/hyperia-sk/memcache-info)

> `memcache-info` is a simple and efficient way to show info about Memcached.

![screenshot](https://user-images.githubusercontent.com/6382002/31081331-d382066e-a78b-11e7-8979-cd3faf33629b.png)

## Usage

```bash
memcache-info
```

or execute periodicaly `watch --interval=1 "memcache-info -r"` 

#### Parameters

```bash
memcache-info [ -n | -p | -h | -r ]

-n <ip|hostname>
Name of the host or IP address (default: 127.0.0.1).

-p <port>
Port number (default: 11211).

-h
Prints this help.

-r
Disable interpret ANSI color and style sequences. (default: 0)
```

## Installation

```bash
git clone https://github.com/hyperia-sk/memcache-info.git && cd memcache-info
```

Open up the cloned directory and run:

#### Unix like OS

```bash
sudo make install
```

For uninstalling

```bash
sudo make uninstall
```

For update/reinstall

```bash
sudo make reinstall
```

#### OS X (homebrew)

@todo

#### Windows (cygwin)

@todo


## System requirements

* Unix like OS with a proper shell
* Tools we use: nc ; mktemp ; basename ; seq ; bc ; awk ; tr ; printf


## Contribution 

Want to contribute? Great! First, read this page.

#### Code reviews

All submissions, including submissions by project members, require review. 
We use Github pull requests for this purpose.

#### Some tips for good pull requests:
* Use our code
  When in doubt, try to stay true to the existing code of the project.
* Write a descriptive commit message. What problem are you solving and what
  are the consequences? Where and what did you test? Some good tips:
  [here](http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message)
  and [here](https://www.kernel.org/doc/Documentation/SubmittingPatches).
* If your PR consists of multiple commits which are successive improvements /
  fixes to your first commit, consider squashing them into a single commit
  (`git rebase -i`) such that your PR is a single commit on top of the current
  HEAD. This make reviewing the code so much easier, and our history more
  readable.

#### Formatting

This documentation is written using standard [markdown syntax](https://help.github.com/articles/markdown-basics/). Please submit your changes using the same syntax.

#### Tests

```bash
make test
```

## Licensing
MIT see [LICENSE][] for the full license text.

   [read this page]: https://github.com/hyperia-sk/memcache-info/blob/master/CONTRIBUTING.md
   [landing page]: https://github.com/hyperia-sk/memcache-info
   [LICENSE]: https://github.com/hyperia-sk/memcache-info/blob/master/LICENSE


