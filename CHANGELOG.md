# Changelog

<!-- changes - write changes below -->
Fix filenames

## v0.8.0

Move all the images from the hexdocs to an external webpage.
This way we don't hit the maximum space limits on hexdocs.
The documentatino of Quartz is now divided in two parts:

  1. The API documentation, which is kept on hexdocs.
  2. The narrative documentation with examples, which is kept in the
     [GitHub pages of the GitHub repository](https://tmbb.github.io/quartz/plot_types.html).
     In the future, this will probably moved to its own domain.

The webpage is heavily inspired by the
[Matplotlib webpage](https://matplotlib.org/stable/).

The webpage is built with a custom mix task based on
[NimblePublisher](https://hexdocs.pm/nimble_publisher/NimblePublisher.html).
Not that while it looks like the webpage generation depends on Phoenix,
it only depends on the Phoenix utilities to generate HTML.
The webpage is 100% static HTML.

## v0.7.0

Minor tweaks.

## v0.6.0

Test release (not published to Hex)

## v0.5.0

Test release (not published to Hex)

## v0.4.0

Test release (not published to Hex)

## v0.3.0

Move the font files to a github archive and download them at compile-time
to avoid Hex's package limits.

## v0.2.0

First version available on Hex.

Main items on the road map:

  1. Support more plot types
  2. Add support for a better kernel density estimation (KDE) algorithm,
     ideally something based on the diffusion-based algorithm in Botev 2010
  3. Define a data protocol that objects can implement if they can be used
     as sources of data for plots (this would allow us to support Explorer
     data frames, lists, arrays and other sources of data)

## v0.1.0

First public version.